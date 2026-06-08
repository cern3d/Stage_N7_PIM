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


--  ALGORITHME Table_De_Pythagore
--  VARIABLES
--      taille, i, j : ENTIER

--  DEBUT
--      // 1. Saisie utilisateur
--      AFFICHER "Taille de la table : "
--      SAISIR taille

--      // 2. Affichage de la ligne d'en-tête (X  1  2  3...)
--      AFFICHER "X"
--      POUR j ALLANT DE 1 A taille FAIRE
--          AFFICHER j (avec formatage/espace)
--      FIN_POUR
--      PASSER_A_LA_LIGNE_SUIVANTE()

--      // 3. Affichage du corps de la table
--      POUR i ALLANT DE 1 A taille FAIRE
--          // Afficher le premier nombre de la ligne actuelle
--          AFFICHER i (avec formatage/espace)
        
--          // Afficher les résultats des multiplications sur cette ligne
--          POUR j ALLANT DE 1 A taille FAIRE
--              AFFICHER (i * j) (avec formatage/espace)
--          FIN_POUR
        
--          // Une fois la ligne finie, on passe à la suivante
--          PASSER_A_LA_LIGNE_SUIVANTE()
--      FIN_POUR
--  FIN