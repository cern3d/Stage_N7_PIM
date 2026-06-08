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


--  Début

--    Déclarer Taille comme entier

--    Afficher "Taille de la table : "
--    Lire Taille

--    Saut de ligne

--    // Afficher la ligne d’en-tête
--    Afficher "X"
--    Pour colonne allant de 1 à Taille faire
--        Afficher colonne
--    FinPour

--    Saut de ligne

--    // Afficher le corps de la table
--    Pour ligne allant de 1 à Taille faire

--        Afficher ligne

--        Pour colonne allant de 1 à Taille faire
--            produit ← ligne * colonne
--            Afficher produit
--        FinPour

--        Saut de ligne

--    FinPour

--  Fin