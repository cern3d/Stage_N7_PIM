with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

-- Afficher le score du jeu 21.
procedure Score_21 is

   De1, De2 : Integer;  -- les deux dés
   Score    : Integer;  -- le score obtenu avec les deux dés
begin
   -- Demander la valeur des dés
   Put ("Dé 1 : ");
   Get (De1);
   Put ("Dé 2 : ");
   Get (De2);

   -- Déterminer le score
   if (De1 = 1 and De2 = 2) or (De1 = 2 and De2 = 1) then
      -- Règle 1 : Le 21
      Score := 21;

   elsif De1 = De2 then
      -- Règle 2 : Les paires (10 + valeur d'un dé)
      Score := 10 + De1;

   elsif De1 = De2 + 1 or De2 = De1 + 1 then
      -- Règle 3 : Les suites (somme des deux dés)
      Score := De1 + De2;

   else
      -- Pas une combinaison gagnante
      Score := 0;
   end if;

   -- Afficher le score
   Put ("Score : ");
   Put (Score, 1);
   New_Line;

end Score_21;