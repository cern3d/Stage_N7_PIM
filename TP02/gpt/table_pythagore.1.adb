with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Table_Pythagore is

   Taille : Integer;  -- taille de la table

begin
   -- Demander la taille
   Put ("Taille de la table : ");
   Get (Taille);

   New_Line;

   -- Ligne d'en-tête
   Put ("X ");
   for J in 1 .. Taille loop
      Put (J, Width => 3);
   end loop;
   New_Line;

   -- Corps de la table
   for I in 1 .. Taille loop
      -- Afficher le numéro de ligne
      Put (I, Width => 2);

      -- Afficher les produits
      for J in 1 .. Taille loop
         Put (I * J, Width => 3);
      end loop;

      New_Line;
   end loop;

end Table_Pythagore;
