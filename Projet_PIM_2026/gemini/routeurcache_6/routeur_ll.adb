with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

-- Tes vrais modules :
with Types_Definitions;     use Types_Definitions;
with Pack_Table_Routage;    use Pack_Table_Routage;
with Pack_Cache_Liste;      use Pack_Cache_Liste;

procedure Routeur_LL is

   Fichier_Table    : Unbounded_String := To_Unbounded_String("table.txt");
   Fichier_Paquets  : Unbounded_String := To_Unbounded_String("paquets.txt");
   Fichier_Resultat : Unbounded_String := To_Unbounded_String("resultats.txt");

   Table            : T_Table_Routage;
   Cache            : T_Cache;
   Taille_Cache     : Integer := 10;
   Politique_Cache  : T_Politique := FIFO;
   Afficher_Stats   : Boolean := True;

   Demandes_Route   : Natural := 0;
   Defauts_Cache    : Natural := 0;

   -- Fonction de nettoyage (évite les bugs avec les fichiers CRLF de Windows)
   function Nettoyer_Ligne (US : Unbounded_String) return Unbounded_String is
      S     : constant String := To_String(US);
      First : Positive := S'First;
      Last  : Natural := S'Last;
   begin
      while Last >= First and then (S(Last) = ' ' or S(Last) = ASCII.CR or S(Last) = ASCII.LF or S(Last) = ASCII.HT) loop
         Last := Last - 1;
      end loop;
      while First <= Last and then (S(First) = ' ' or S(First) = ASCII.HT) loop
         First := First + 1;
      end loop;
      if First > Last then return To_Unbounded_String("");
      else return To_Unbounded_String(S(First .. Last));
      end if;
   end Nettoyer_Ligne;

   -- Extraction d'une route depuis le texte de la table
   procedure Parser_Ligne_Table (Ligne : in String; Route : out T_Route) is
      Start_Idx : Positive := Ligne'First;
      W_Start, W_End : Positive;
      procedure Extraire_Mot (Start : in out Positive; S_Mot : out Positive; E_Mot : out Positive) is
      begin
         while Start <= Ligne'Last and then (Ligne(Start) = ' ' or Ligne(Start) = ASCII.HT) loop Start := Start + 1; end loop;
         S_Mot := Start;
         while Start <= Ligne'Last and then (Ligne(Start) /= ' ' and Ligne(Start) /= ASCII.HT and Ligne(Start) /= ASCII.CR and Ligne(Start) /= ASCII.LF) loop Start := Start + 1; end loop;
         E_Mot := Start - 1;
      end Extraire_Mot;
   begin
      Extraire_Mot(Start_Idx, W_Start, W_End);
      Route.Destination := String_To_IP(Ligne(W_Start .. W_End));
      Extraire_Mot(Start_Idx, W_Start, W_End);
      Route.Masque := String_To_IP(Ligne(W_Start .. W_End));
      Extraire_Mot(Start_Idx, W_Start, W_End);
      Route.Interface_R := To_Unbounded_String(Ligne(W_Start .. W_End));
   end Parser_Ligne_Table;

   procedure Analyser_Arguments is
      Idx : Positive := 1;
   begin
      while Idx <= Argument_Count loop
         if Argument(Idx) = "-t" and Idx < Argument_Count then
            Fichier_Table := To_Unbounded_String(Argument(Idx + 1)); Idx := Idx + 2;
         elsif Argument(Idx) = "-q" and Idx < Argument_Count then
            Fichier_Paquets := To_Unbounded_String(Argument(Idx + 1)); Idx := Idx + 2;
         elsif Argument(Idx) = "-r" and Idx < Argument_Count then
            Fichier_Resultat := To_Unbounded_String(Argument(Idx + 1)); Idx := Idx + 2;
         elsif Argument(Idx) = "-c" and Idx < Argument_Count then
            Taille_Cache := Integer'Value(Argument(Idx + 1)); Idx := Idx + 2;
         elsif Argument(Idx) = "-p" and Idx < Argument_Count then
            if Argument(Idx + 1) = "LRU" then Politique_Cache := LRU;
            elsif Argument(Idx + 1) = "LFU" then Politique_Cache := LFU;
            else Politique_Cache := FIFO; end if;
            Idx := Idx + 2;
         elsif Argument(Idx) = "-S" then Afficher_Stats := True; Idx := Idx + 1;
         elsif Argument(Idx) = "-s" then Afficher_Stats := False; Idx := Idx + 1;
         else Idx := Idx + 1;
         end if;
      end loop;
   end Analyser_Arguments;

   File_T, File_P, File_R : File_Type;
   Ligne_Lue        : Unbounded_String;
   Interf_Sortie    : Unbounded_String;
   IP_Cible         : T_Adresse_IP;
   Num_Ligne        : Positive := 1;
   Route_Tmp        : T_Route;
   
   -- Variables pour le cache
   Cache_Hit        : Boolean;
   Masque_Cache     : T_Adresse_IP;
   Dest_Cache       : T_Adresse_IP;

begin
   Initialiser(Table);
   Analyser_Arguments;
   Initialiser(Cache, Taille_Cache, Politique_Cache);

   -- Lecture de la table de routage
   Open(File_T, In_File, To_String(Fichier_Table));
   while not End_Of_File(File_T) loop
      Ligne_Lue := Nettoyer_Ligne(To_Unbounded_String(Get_Line(File_T)));
      if Length(Ligne_Lue) > 0 then
         Parser_Ligne_Table(To_String(Ligne_Lue), Route_Tmp);
         Enregistrer(Table, Route_Tmp);
      end if;
   end loop;
   Close(File_T);

   -- Traitement des paquets
   Open(File_P, In_File, To_String(Fichier_Paquets));
   Create(File_R, Out_File, To_String(Fichier_Resultat));

   while not End_Of_File(File_P) loop
      Ligne_Lue := Nettoyer_Ligne(To_Unbounded_String(Get_Line(File_P)));

      if Ligne_Lue = "table" then
         New_Line; Put_Line("table (ligne" & Integer'Image(Num_Ligne) & ")");
         Afficher_Table(Table);
      elsif Ligne_Lue = "cache" then
         New_Line; Put_Line("cache (ligne" & Integer'Image(Num_Ligne) & ")");
         -- Le cache en liste ne demande pas d'affichage formel dans le sujet initial, 
         -- mais on intercepte la commande.
         Afficher_Cache(Cache);  -- <-- L'appel magique qui affiche les routes !
      elsif Ligne_Lue = "stat" then
         New_Line; Put_Line("stat (ligne" & Integer'Image(Num_Ligne) & ")");
         Put_Line("Demandes de route : " & Natural'Image(Demandes_Route));
         Put_Line("Defauts de cache  : " & Natural'Image(Defauts_Cache));
         if Demandes_Route > 0 then
            Put_Line("Taux de defauts   : " & Float'Image(Float(Defauts_Cache) / Float(Demandes_Route)));
         end if;
      elsif Ligne_Lue = "fin" then
         New_Line; Put_Line("fin (ligne" & Integer'Image(Num_Ligne) & ")");
         exit;
      elsif Length(Ligne_Lue) > 0 then
         Demandes_Route := Demandes_Route + 1;
         
         -- On utilise ton 'String_To_IP'
         IP_Cible := String_To_IP(To_String(Ligne_Lue));
         
         -- 1. Recherche dans le cache en Liste
         Chercher(Cache, IP_Cible, Interf_Sortie, Cache_Hit);
         
         -- 2. En cas de défaut de cache, on interroge la table de routage
         if not Cache_Hit then
            Defauts_Cache := Defauts_Cache + 1;
            
            -- On utilise la procédure modifiée qui renvoie le Masque et la Dest cohérente !
            Chercher_Route_Pour_Cache(
               Table             => Table, 
               IP                => IP_Cible, 
               Interface_R       => Interf_Sortie, 
               Masque_Cache      => Masque_Cache, 
               Destination_Cache => Dest_Cache
            ); 
            
            if Length(Interf_Sortie) > 0 then
               -- On ajoute au cache en liste
               Enregistrer(Cache, Dest_Cache, Masque_Cache, Interf_Sortie);
            end if;
         end if;
         
         if Length(Interf_Sortie) > 0 then
            Put_Line(File_R, To_String(Ligne_Lue) & " " & To_String(Interf_Sortie));
         else
            Put_Line(File_R, To_String(Ligne_Lue) & " UNREACHABLE");
         end if;
      end if;

      Num_Ligne := Num_Ligne + 1;
   end loop;

   -- Affichage final des statistiques si demandé (-S)
   if Afficher_Stats then
      New_Line;
      Put_Line("--- Statistiques Finales ---");
      Put_Line("Demandes de route : " & Natural'Image(Demandes_Route));
      Put_Line("Defauts de cache  : " & Natural'Image(Defauts_Cache));
   end if;

   Close(File_P); Close(File_R);
   Vider(Table); Vider(Cache);

end Routeur_LL;