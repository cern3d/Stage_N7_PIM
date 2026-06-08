with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

-- Afficher la table de 7
--
-- Résultat attendu :
--
-- 1 x 7 =  7
-- 2 x 7 = 14
-- 3 x 7 = 21
-- 4 x 7 = 28
-- 5 x 7 = 35
-- 6 x 7 = 42
-- 7 x 7 = 49
-- 8 x 7 = 56
-- 9 x 7 = 63
--
-- Pseudo-code :
-- 1. Déclarer une procédure Table_7
-- 2. Pour chaque valeur I de 1 à 9 :
--    a. Calculer produit := I * 7
--    b. Afficher I
--    c. Afficher " x 7 = "
--    d. Afficher produit avec une largeur de 2
--    e. Aller à la ligne suivante
--
procedure Table_7 is
begin
   for I in 1 .. 9 loop
      Put(I);
      Put(" x 7 = ");
      Put(Item => I * 7, Width => 2);
      New_Line;
   end loop;
end Table_7;
