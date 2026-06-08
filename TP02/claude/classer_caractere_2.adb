with Ada.Text_IO;          use Ada.Text_IO;

-- afficher la classe à laquelle appartient un caractère lu au clavier
--
-- La classe d'un caractère peut-être 'C' pour Chiffre, 'L' pour Lettre, 'P'
-- pour Ponctuation ou 'A' pour Autre.
--
procedure Classer_Caractere is

	-- Constantes pour définir la classe des caractères
	Chiffre     : constant Character := 'C';
	Lettre      : constant Character := 'L';
	Ponctuation : constant Character := 'P';
	Autre       : constant Character := 'A';

	C : Character;		-- le caractère à classer
	Classe: Character;	-- la classe du caractère C
begin
	-- Demander le caractère
	Put ("Caractère : ");
	Get (C);

	-- Déterminer la classe du caractère c
	case C is
		when '0' .. '9' =>
			Classe := Chiffre;
            
		when 'a' .. 'z' | 'A' .. 'Z' =>
			Classe := Lettre;
            
		when '!' | ',' | ';' | '.' | '?' =>
			Classe := Ponctuation;
            
		when others =>
			Classe := Autre;
	end case;

	-- Afficher la classe du caractère
	Put_Line ("Classe : " & Classe);

end Classer_Caractere;

--  Algorithme Classification_Caractere

--  Variables:
--      c : Caractère
--      classe : Caractère

--  Début
--      // Étape 1 : Lecture du caractère au clavier
--      Écrire("Entrez un caractère : ")
--      Lire(c)

--      // Étape 2 : Détermination de la classe
--      Si (c >= '0' et c <= '9') Alors
--          classe <- 'C'
--      Sinon Si ((c >= 'a' et c <= 'z') ou (c >= 'A' et c <= 'Z')) Alors
--          classe <- 'L'
--      Sinon Si (c = '!' ou c = ',' ou c = ';' ou c = '.' ou c = '?') Alors
--          classe <- 'P'
--      Sinon
--          classe <- 'A'
--      FinSi

--      // Étape 3 : Affichage du résultat
--      Écrire("Le caractère '", c, "' appartient à la classe : '", classe, "'")
--  Fin