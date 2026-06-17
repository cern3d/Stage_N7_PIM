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