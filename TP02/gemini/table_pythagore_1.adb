with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

-- Afficher la table de Pythagore
procedure Table_Pythagore is

   Taille: Integer;  -- taille de la table
   
begin
   -- Demander la taille
   Put ("Taille de la table : ");
   Get (Taille);

   -- 1. Afficher l'en-tête (la première ligne : X  1  2  3...)
   Put ("  X");
   for J in 1 .. Taille loop
      Put (J, Width => 3);
   end loop;
   New_Line;

   -- 2. Afficher le corps de la table
   for I in 1 .. Taille loop
      -- Afficher le premier nombre de la ligne (l'indice multiplicateur)
      Put (I, Width => 3);
      
      -- Afficher les résultats des multiplications sur la ligne
      for J in 1 .. Taille loop
         Put (I * J, Width => 3);
      end loop;
      
      -- Passer à la ligne suivante après chaque fin de ligne numérique
      New_Line;
   end loop;

end Table_Pythagore;
