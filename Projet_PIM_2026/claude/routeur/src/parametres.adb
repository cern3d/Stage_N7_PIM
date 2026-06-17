with Ada.Command_Line;  use Ada.Command_Line;
with Ada.Text_IO;       use Ada.Text_IO;

package body Parametres is

   ---------------
   -- Analyser  --
   ---------------
   procedure Analyser (Params : out T_Parametres) is
      I : Positive := 1;

      -- Retourner l'argument suivant et avancer I ; erreur si absent
      function Arg_Suivant (Option : String) return String is
      begin
         if I > Argument_Count then
            Put_Line (Standard_Error,
                      "Option " & Option & " attend un argument.");
            raise Constraint_Error;
         end if;
         declare
            S : constant String := Argument (I);
         begin
            I := I + 1;
            return S;
         end;
      end Arg_Suivant;

   begin
      -- Valeurs par défaut
      Params.Taille_Cache      := 10;
      Params.Politique         := FIFO;
      Params.Afficher_Stats    := True;
      Params.Fichier_Table     := new String'("table.txt");
      Params.Fichier_Paquets   := new String'("paquets.txt");
      Params.Fichier_Resultats := new String'("resultats.txt");

      while I <= Argument_Count loop
         declare
            Opt : constant String := Argument (I);
         begin
            I := I + 1;

            if    Opt = "-c" then
               Params.Taille_Cache := Natural'Value (Arg_Suivant ("-c"));

            elsif Opt = "-p" then
               declare
                  Pol : constant String := Arg_Suivant ("-p");
               begin
                  if    Pol = "FIFO" then Params.Politique := FIFO;
                  elsif Pol = "LRU"  then Params.Politique := LRU;
                  elsif Pol = "LFU"  then Params.Politique := LFU;
                  else
                     Put_Line (Standard_Error,
                               "Politique inconnue : " & Pol
                               & " (FIFO|LRU|LFU attendu)");
                     raise Constraint_Error;
                  end if;
               end;

            elsif Opt = "-s" then
               Params.Afficher_Stats := True;

            elsif Opt = "-S" then
               Params.Afficher_Stats := False;

            elsif Opt = "-t" then
               Params.Fichier_Table := new String'(Arg_Suivant ("-t"));

            elsif Opt = "-q" then
               Params.Fichier_Paquets := new String'(Arg_Suivant ("-q"));

            elsif Opt = "-r" then
               Params.Fichier_Resultats := new String'(Arg_Suivant ("-r"));

            else
               Put_Line (Standard_Error, "Option inconnue : " & Opt);
               raise Constraint_Error;
            end if;
         end;
      end loop;
   end Analyser;

end Parametres;
