with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Types_Definitions;     use Types_Definitions;
with Pack_Table_Routage;    use Pack_Table_Routage;

procedure Routeur_LL is

   Fichier_Table    : Unbounded_String := To_Unbounded_String("table.txt");
   Fichier_Paquets  : Unbounded_String := To_Unbounded_String("paquets.txt");
   Fichier_Resultat : Unbounded_String := To_Unbounded_String("resultats.txt");

   Table : T_Table_Routage;

   -- Fonction de robustesse pour enlever les espaces et les '\r' de Windows
   function Nettoyer_Ligne (US : Unbounded_String) return Unbounded_String is
      S : String := To_String(US);
      First : Positive := S'First;
      Last  : Natural := S'Last;
   begin
      -- Supprime les caractères invisibles à la fin (Espaces, CR, LF, Tab)
      while Last >= First and then (S(Last) = ' ' or S(Last) = ASCII.CR or S(Last) = ASCII.LF or S(Last) = ASCII.HT) loop
         Last := Last - 1;
      end loop;
      -- Supprime les espaces au début
      while First <= Last and then (S(First) = ' ' or S(First) = ASCII.HT) loop
         First := First + 1;
      end loop;
      
      if First > Last then
         return To_Unbounded_String("");
      else
         return To_Unbounded_String(S(First .. Last));
      end if;
   end Nettoyer_Ligne;

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

   Open(File_T, In_File, To_String(Fichier_Table));
   while not End_Of_File(File_T) loop
      -- Nettoyage de la ligne lue dans la table
      Ligne_Lue := Nettoyer_Ligne(To_Unbounded_String(Get_Line(File_T)));
      if Length(Ligne_Lue) > 0 then
         Parser_Ligne_Table(To_String(Ligne_Lue), Route_Tmp);
         Enregistrer(Table, Route_Tmp);
      end if;
   end loop;
   Close(File_T);

   Open(File_P, In_File, To_String(Fichier_Paquets));
   Create(File_R, Out_File, To_String(Fichier_Resultat));

   while not End_Of_File(File_P) loop
      -- Nettoyage de la ligne lue dans les paquets
      Ligne_Lue := Nettoyer_Ligne(To_Unbounded_String(Get_Line(File_P)));

      if Ligne_Lue = "table" then
         New_Line;
         Put_Line("table (ligne" & Integer'Image(Num_Ligne) & ")");
         Afficher_Table(Table);
      elsif Ligne_Lue = "cache" then
         New_Line;
         Put_Line("cache (ligne" & Integer'Image(Num_Ligne) & ")");
      elsif Ligne_Lue = "stat" then
         New_Line;
         Put_Line("stat (ligne" & Integer'Image(Num_Ligne) & ")");
      elsif Ligne_Lue = "fin" then
         New_Line;
         Put_Line("fin (ligne" & Integer'Image(Num_Ligne) & ")");
         exit;
      elsif Length(Ligne_Lue) > 0 then
         Chercher_Route(Table, String_To_IP(To_String(Ligne_Lue)), Interf_Sortie);
         Put_Line(File_R, To_String(Ligne_Lue) & " " & To_String(Interf_Sortie));
      end if;

      Num_Ligne := Num_Ligne + 1;
   end loop;

   Close(File_P);
   Close(File_R);
   Vider(Table);

end Routeur_LL;


--  routeur_ll_3.adb:17:07: warning: "S" is not modified, could be declared constant [-gnatwk]
--  pack_table_routage.adb:18:07: warning: "Nouveau" is not modified, could be declared constant [-gnatwk]
--  pack_table_routage.adb:74:07: warning: variable "A_Epingler" is assigned but never read [-gnatwm]
--  types_definitions.adb:28:07: warning: "O1" is not modified, could be declared constant [-gnatwk]
--  types_definitions.adb:29:07: warning: "O2" is not modified, could be declared constant [-gnatwk]
--  types_definitions.adb:30:07: warning: "O3" is not modified, could be declared constant [-gnatwk]
--  types_definitions.adb:31:07: warning: "O4" is not modified, could be declared constant [-gnatwk]
--  types_definitions.adb:34:10: warning: "S" is not modified, could be declared constant [-gnatwk]