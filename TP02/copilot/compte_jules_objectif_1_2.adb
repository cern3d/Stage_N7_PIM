with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

-- Énoncé :
--
-- À la naissance de Jules, ses parents lui ont ouvert un compte sur lequel ils
-- ont versé 100 euros. Ensuite, à chaque anniversaire de Jules, ils ont versé
-- 100 euros et le double de son âge en euros sur ce compte.
-- 
-- Par exemple, pour les 2 ans de Jules, ses parents ont versé 104 euros sur
-- son compte (100 euros + 2 * 2 euros).
-- 
-- Quel âge devra atteindre Jules avant de disposer d'une certaine somme sur
-- son compte ?
-- 
-- On considère que le compte n'est pas rémunéré et qu'aucun retrait n'est fait
-- sur ce compte.
--
-- Exemples
--
-- objectif ->  versements
-- -----------------
-- 202      ->  1
-- 400      ->  3
--

procedure Compte_Jules is

	Objectif: Integer;	-- Somme souhaitée sur le compte de Jules
	Age: Integer;		-- Age de Jules
	Solde: Integer;		-- Solde du compte de Jules

	-- Pseudo-code :
	-- 1. Lire l'objectif de somme souhaitée.
	-- 2. Initialiser l'âge à 0 et le solde à 100 (versement à la naissance).
	-- 3. Tant que le solde est inférieur à l'objectif, faire :
	--      a. augmenter l'âge de 1.
	--      b. ajouter 100 euros au solde.
	--      c. ajouter le double de l'âge au solde.
	-- 4. Quand l'objectif est atteint ou dépassé, afficher l'âge.

begin
	-- Demander la somme souhaitée
	Put ("Somme attendue : ");
	Get (Objectif);

	-- Initialiser l'âge et le solde à la naissance
	Age := 0;
	Solde := 100;

	-- Ajouter chaque anniversaire jusqu'à atteindre l'objectif
	while Solde < Objectif loop
		Age := Age + 1;
		Solde := Solde + 100 + 2 * Age;
	end loop;

	-- Afficher l'âge que doit avoir Jule
	Put ("Age : ");
	Put (Age, 1);
	New_Line;

end Compte_Jules;
