--  with Ada.Text_IO;          use Ada.Text_IO;
--  with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

--  -- Afficher la somme des valeurs d'un série dont les valeurs sont lues au
--  -- clavier. Pour marquer la fin de la série, la dernière valeur est doublée.
--  -- En conséquence, il ne peut pas y avoir deux valeurs consécutives égales dans
--  -- la série.
--  --
--  -- Exemples :
--  --
--  -- série                   ->  longueur
--  -- ------------------------------------
--  --  1  2  3  3             ->    6
--  --  1  2  1  3  1  4  1  1 ->   13
--  -- -4  8  1  3 29 29       ->   37
--  --  0  0                   ->    0
--  -- -5 -1 -5 -5             ->  -11
--  --
--  procedure Somme_Serie_Double is

--  	Somme: Integer;	    	-- Somme des valeurs de la série
--  	Valeur, Suivante: Integer;

--  begin
--  	-- Lire la première valeur de la série
--  	Get (Valeur);
--  	Somme := 0;

--  	-- Lire les valeurs suivantes jusqu'à ce que la dernière valeur soit doublée
--  	loop
--  		Get (Suivante);
--  		if Suivante = Valeur then
--  			exit;
--  		else
--  			Somme := Somme + Valeur;
--  			Valeur := Suivante;
--  		end if;
--  	end loop;

--  	-- Afficher la somme
--  	Put ("Somme : ");
--  	Put (Somme, 1);
--  	New_Line;

--  end Somme_Serie_Double;

--  with Ada.Text_IO;          use Ada.Text_IO;
--  with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

--  -- Afficher la somme des valeurs d'un série dont les valeurs sont lues au
--  -- clavier. Pour marquer la fin de la série, la dernière valeur est doublée.
--  -- En conséquence, il ne peut pas y avoir deux valeurs consécutives égales dans
--  -- la série.
--  --
--  -- Exemples :
--  --
--  -- série                   ->  longueur
--  -- ------------------------------------
--  --  1  2  3  3             ->    6
--  --  1  2  1  3  1  4  1  1 ->   13
--  -- -4  8  1  3 29 29       ->   37
--  --  0  0                   ->    0
--  -- -5 -1 -5 -5             ->  -11
--  --
--  procedure Somme_Serie_Double is

--  	Somme: Integer;	    	-- Somme des valeurs de la série
--  	Valeur, Suivante: Integer;

--  begin
--  	-- Lire la première valeur de la série
--  	Get (Valeur);
--  	Somme := 0;

--  	-- Lire la valeur suivante et continuer tant que la série n'est pas terminée
--  	Get (Suivante);
--  	while Suivante /= Valeur loop
--  		Somme := Somme + Valeur;
--  		Valeur := Suivante;
--  		Get (Suivante);
--  	end loop;

--  	-- Afficher la somme
--  	Put ("Somme : ");
--  	Put (Somme, 1);
--  	New_Line;

--  end Somme_Serie_Double;

with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

-- Afficher la somme des valeurs d'un série dont les valeurs sont lues au
-- clavier. Pour marquer la fin de la série, la dernière valeur est doublée.
-- En conséquence, il ne peut pas y avoir deux valeurs consécutives égales dans
-- la série.
--
-- Exemples :
--
-- série                   ->  longueur
-- ------------------------------------
--  1  2  3  3             ->    6
--  1  2  1  3  1  4  1  1 ->   13
-- -4  8  1  3 29 29       ->   37
--  0  0                   ->    0
-- -5 -1 -5 -5             ->  -11



---- Pseudocode :
--   Lire la première valeur de la série dans Valeur
--   Somme := 0
--   Boucler indéfiniment
--     Lire la valeur suivante dans Suivante
--     Si Suivante = Valeur alors
--       Sortir de la boucle
--     Sinon
--       Somme := Somme + Valeur
--       Valeur := Suivante
--     Fin si
--   Fin boucle
--   Afficher Somme



-- Pseudocode :
--   Lire la première valeur de la série dans Valeur
--   Somme := 0
--   Lire la valeur suivante dans Suivante
--   Tant que Suivante /= Valeur faire
--     Somme := Somme + Valeur
--     Valeur := Suivante
--     Lire la valeur suivante dans Suivante
--   Fin tant que
--   Afficher Somme



-- Pseudocode :
--   Lire la première valeur de la série dans Valeur
--   Somme := 0
--   Lire la valeur suivante dans Suivante
--   Répéter
--     Somme := Somme + Valeur
--     Valeur := Suivante
--     Lire la valeur suivante dans Suivante
--   Jusqu'à Suivante = Valeur
--   Afficher Somme



procedure Somme_Serie_Double is

	Somme: Integer;	    	-- Somme des valeurs de la série
	Valeur, Suivante: Integer;

begin
	-- Lire la première valeur de la série
	Get (Valeur);
	Somme := Valeur;

	-- Lire les valeurs suivantes jusqu'à la détection du doublon final
	loop
		Get (Suivante);
		exit when Suivante = Valeur;
		Somme := Somme + Suivante;
		Valeur := Suivante;
	end loop;

	-- Afficher la somme
	Put ("Somme : ");
	Put (Somme, 1);
	New_Line;

end Somme_Serie_Double;