with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Types_Definitions;     use Types_Definitions;
with Pack_Table_Routage;    use Pack_Table_Routage;

procedure Routeur_LL_1 is

   -- Fichiers par défaut du cahier des charges [cite: 243, 245, 252]
   Fichier_Table    : Unbounded_String := To_Unbounded_String("table.txt");
   Fichier_Paquets  : Unbounded_String := To_Unbounded_String("paquets.txt");
   Fichier_Resultat : Unbounded_String := To_Unbounded_String("resultats.txt");

   Table : T_Table_Routage;

   -- Parseur de ligne de texte pour isoler les 3 arguments d'une route [cite: 158]
   procedure Parser_Ligne_Table (Ligne : in String; Route : out T_Route) is
      Start_Idx : Positive := Ligne'First;
      W_Start, W_End : Positive;

      procedure Extraire_Mot (Start : in out Positive; S_Mot : out Positive; E_Mot : out Positive) is
      begin
         while Start <= Ligne'Last and then (Ligne(Start) = ' ' or Ligne(Start) = ASCII.HT) loop
            Start := Start + 1;
         end loop;
         S_Mot := Start;
         while Start <= Ligne'Last and then (Ligne(Start) /= ' ' and Ligne(Start) /= ASCII.HT and Ligne(Start) /= ASCII.CR and Ligne(Start) /= ASCII.LF) loop
            Start := Start + 1;
         end loop;
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

   -- Phase 1 : Traitement dynamique des arguments de la ligne de commande [cite: 230, 231]
   procedure Analyser_Arguments is
      Idx : Positive := 1;
   begin
      while Idx <= Argument_Count loop
         if Argument(Idx) = "-t" and Idx < Argument_Count then
            Fichier_Table := To_Unbounded_String(Argument(Idx + 1));
            Idx := Idx + 2;
         elsif Argument(Idx) = "-q" and Idx < Argument_Count then
            Fichier_Paquets := To_Unbounded_String(Argument(Idx + 1));
            Idx := Idx + 2;
         elsif Argument(Idx) = "-r" and Idx < Argument_Count then
            Fichier_Resultat := To_Unbounded_String(Argument(Idx + 1));
            Idx := Idx + 2;
         -- Capture sécurisée et ignorance des options liées au cache pour cette V1 [cite: 253]
         elsif (Argument(Idx) = "-c" or Argument(Idx) = "-p") and Idx < Argument_Count then
            Idx := Idx + 2;
         elsif Argument(Idx) = "-S" or Argument(Idx) = "-s" then
            Idx := Idx + 1;
         else
            Idx := Idx + 1;
         end if;
      end loop;
   end Analyser_Arguments;

   File_T, File_P, File_R : File_Type;
   Ligne_Lue    : Unbounded_String;
   Interf_Sortie : Unbounded_String;
   Num_Ligne    : Positive := 1;
   Route_Tmp    : T_Route;

begin
   Initialiser(Table);
   Analyser_Arguments;

   -- Phase 2 : Remplissage de la structure de données (Table) 
   Open(File_T, In_File, To_String(Fichier_Table));
   while not End_Of_File(File_T) loop
      Ligne_Lue := To_Unbounded_String(Get_Line(File_T));
      if Length(Ligne_Lue) > 0 then
         Parser_Ligne_Table(To_String(Ligne_Lue), Route_Tmp);
         Enregistrer(Table, Route_Tmp);
      end if;
   end loop;
   Close(File_T);

   -- Phase 3 : Interprétation séquentielle du fichier de paquets / commandes [cite: 171, 188]
   Open(File_P, In_File, To_String(Fichier_Paquets));
   Create(File_R, Out_File, To_String(Fichier_Resultat));

   while not End_Of_File(File_P) loop
      Ligne_Lue := To_Unbounded_String(Get_Line(File_P));
      
      -- Interception des commandes standardisées [cite: 189, 190]
      if Ligne_Lue = "table" then
         New_Line;
         Put_Line("table (ligne" & Positive'Image(Num_Ligne) & ")"); [cite: 191]
         Afficher_Table(Table); [cite: 194]
         
      elsif Ligne_Lue = "cache" then
         New_Line;
         Put_Line("cache (ligne" & Positive'Image(Num_Ligne) & ")"); [cite: 191]
         -- Cache inexistant en V1 : n'affiche rien [cite: 194]
         
      elsif Ligne_Lue = "stat" then
         New_Line;
         Put_Line("stat (ligne" & Positive'Image(Num_Ligne) & ")"); [cite: 191]
         -- Pas de cache, pas de statistiques à émettre en V1 [cite: 195]
         
      elsif Ligne_Lue = "fin" then
         New_Line;
         Put_Line("fin (ligne" & Positive'Image(Num_Ligne) & ")"); [cite: 191, 226]
         exit; -- Interruption stricte du flux de traitement [cite: 196]
         
      elsif Length(Ligne_Lue) > 0 then
         -- C'est un traitement d'IP classique à router [cite: 172]
         Chercher_Route(Table, String_To_IP(To_String(Ligne_Lue)), Interf_Sortie);
         
         -- Écriture formatée dans le fichier résultat : "IP Interface" [cite: 181, 182]
         Put_Line(File_R, To_String(Ligne_Lue) & " " & To_String(Interf_Sortie));
      end if;

      Num_Ligne := Num_Ligne + 1;
   end loop;

   Close(File_P);
   Close(File_R);
   Vider(Table);

end Routeur_LL_1;



--  x86_64-linux-gnu-gcc-13 -c -I./ -gnatwa -I- ./routeur_ll_1.adb
--  routeur_ll_1.adb:100:69: error: statement expected
--  routeur_ll_1.adb:100:70: error: illegal character, replaced by "("
--  routeur_ll_1.adb:101:32: error: statement expected
--  routeur_ll_1.adb:101:33: error: illegal character, replaced by "("
--  routeur_ll_1.adb:105:69: error: statement expected
--  routeur_ll_1.adb:105:70: error: illegal character, replaced by "("
--  routeur_ll_1.adb:110:68: error: statement expected
--  routeur_ll_1.adb:110:69: error: illegal character, replaced by "("
--  routeur_ll_1.adb:115:67: error: statement expected
--  routeur_ll_1.adb:115:68: error: illegal character, replaced by "("
--  gnatmake: "./routeur_ll_1.adb" compilation error