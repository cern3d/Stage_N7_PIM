with Ada.Text_IO;          use Ada.Text_IO;

-- Permuter deux caractères lus au clavier
procedure Permuter_Caracteres is

	C1, C2 : Character;  -- Les deux caractères à permuter
	Tmp    : Character;  -- Variable temporaire pour stocker la valeur de C1

begin
	-- Demander les deux caractères C1 et C2
	Get (C1);
	Skip_Line;
	Get (C2);
	Skip_Line;

	-- Afficher C1 et C2 avant permutation
	Put_Line ("C1 = '" & C1 & "'");
	Put_Line ("C2 = '" & C2 & "'");

	-- Permuter C1 et C2
	Tmp := C1;  -- Étape 1 : On sauvegarde C1
	C1  := C2;  -- Étape 2 : C1 prend la valeur de C2
	C2  := Tmp; -- Étape 3 : C2 prend l'ancienne valeur de C1 (stockée dans Tmp)

	-- Afficher C1 et C2 après permutation
	Put_Line ("C1 = '" & C1 & "'");
	Put_Line ("C2 = '" & C2 & "'");

end Permuter_Caracteres;


--  ALGORITHME Permuter_Deux_Caracteres
--  VARIABES
--      c1, c2 : CARACTERE
--      temp   : CARACTERE

--  DEBUT
--      // 1. Lecture du premier caractère
--      AFFICHER "Entrez le premier caractère : "
--      LIRE c1
--      VIDER_LIGNE // Équivalent du Skip_line pour vider le tampon (notamment le 'Entrée')

--      // 2. Lecture du deuxième caractère
--      AFFICHER "Entrez le deuxième caractère : "
--      LIRE c2
--      VIDER_LIGNE // On vide à nouveau le tampon pour laisser propre

--      // Affichage avant permutation (pour vérification)
--      AFFICHER "Avant permutation : c1 = ", c1, " et c2 = ", c2

--      // 3. Logique de permutation
--      temp <- c1  // On sauvegarde la valeur de c1 dans temp
--      c1   <- c2  // On Écrase c1 avec la valeur de c2
--      c2   <- temp // On donne à c2 la valeur sauvegardée dans temp

--      // 4. Affichage après permutation
--      AFFICHER "Après permutation : c1 = ", c1, " et c2 = ", c2
--  FIN