with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

-- Afficher le chiffre significatif d'un entier naturel.
-- 
-- Attention à ne pas provoquer des débordement de la capacité des entiers.
-- 
-- Exemples :
--
--   entier   -> chiffre significatif
--   -------------------------------
--   25         ->  2
--   8          ->  8
--   9502       ->  9
--   0          ->  0
--   2147483647 ->  2
--
procedure Chiffre_Significatif is

   Entier: Integer;  -- l'entier naturel
   Chiffre_Significatif: Integer;   -- le chiffre significatif de Entier
   
   Temporaire: Integer; -- Variable de travail pour ne pas modifier l'original
begin
   -- Demander l'entier naturel
   Put ("Entier : ");
   Get (Entier);

   -- Déterminer le chiffre significatif
   Temporaire := Entier;
   
   -- On divise par 10 tant que le nombre a plus d'un chiffre
   while Temporaire >= 10 loop
      Temporaire := Temporaire / 10;
   end loop;
   
   Chiffre_Significatif := Temporaire;

   -- Afficher le résultat
   Put ("Chiffre significatif : ");
   Put (Chiffre_Significatif, 1);
   New_Line;

end Chiffre_Significatif;