with Ada.Text_IO;        use Ada.Text_IO;
with Ada.Float_Text_IO;  use Ada.Float_Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Vecteurs_Creux;     use Vecteurs_Creux;

-- Exemple d'utilisation des vecteurs creux.
procedure Exemple_Vecteurs_Creux is

	V : T_Vecteur_Creux;
	Epsilon: constant Float := 1.0e-5;
begin
	Put_Line ("Début du scénario");
	-- Initialiser le vecteur et l'afficher
	Initialiser (V);
	Put_Line ("Après Initialiser:");
	Afficher (V);
	New_Line;

	-- Vérifier si le vecteur est nul
	if Est_Nul (V) then
		Put_Line ("Est_Nul(V) = True");
	else
		Put_Line ("Est_Nul(V) = False");
	end if;

	-- Vérifier une composante (indice 18)
	Put ("Composante(18) = ");
	Put (Composante_Recursif (V, 18), Fore => 0, Aft => 1, Exp => 0);
	New_Line;

	-- Détruire le vecteur et ré-afficher
	Detruire (V);
	Put_Line ("Après Detruire:");
	Afficher (V);
	New_Line;

	-- Recréer et tester Modifier, Composantes et égalité
	Initialiser (V);
	-- Modifier plusieurs composantes
	Modifier (V, 10, 4.0);
	Modifier (V, 3, -3.0);
	Modifier (V, 1, 2.0);
	Put_Line ("Après Modifier (10,4.0), (3,-3.0), (1,2.0):");
	Afficher (V);
	New_Line;

	-- Tester Composante itérative et récursive
	Put ("Composante_Recursif(V,3) = ");
	Put (Composante_Recursif (V, 3), Fore => 0, Aft => 1, Exp => 0);
	New_Line;
	Put ("Composante_Iteratif(V,10) = ");
	Put (Composante_Iteratif (V, 10), Fore => 0, Aft => 1, Exp => 0);
	New_Line;

	-- Nombre de composantes non nulles
	Put ("Nombre_Composantes_Non_Nulles(V) = ");
	Put (Nombre_Composantes_Non_Nulles (V), 0);
	New_Line;

	-- Tester Sont_Egaux
	declare
		W : T_Vecteur_Creux;
	begin
		Initialiser (W);
		Modifier (W, 10, 4.0);
		Modifier (W, 3, -3.0);
		Modifier (W, 1, 2.0);
		if Sont_Egaux_Recursif (V, W) then
			Put_Line ("Sont_Egaux_Recursif: True");
		else
			Put_Line ("Sont_Egaux_Recursif: False");
		end if;
		if Sont_Egaux_Iteratif (V, W) then
			Put_Line ("Sont_Egaux_Iteratif: True");
		else
			Put_Line ("Sont_Egaux_Iteratif: False");
		end if;
		-- Produit scalaire et norme
		Put ("Norme2(V) = ");
		Put (Norme2 (V), Fore => 0, Aft => 1, Exp => 0);
		New_Line;
		Put ("Produit_Scalaire(V,W) = ");
		Put (Produit_Scalaire (V, W), Fore => 0, Aft => 1, Exp => 0);
		New_Line;

		-- Tester Additionner
		declare
			A, B : T_Vecteur_Creux;
		begin
			Initialiser (A);
			for I in 1..5 loop
				Modifier (A, I, Float (I));
			end loop;
			Initialiser (B);
			for I in 4..7 loop
				Modifier (B, I, Float (I));
			end loop;
			Put_Line ("A = "); Afficher (A); New_Line;
			Put_Line ("B = "); Afficher (B); New_Line;
			Additionner (A, B);
			Put_Line ("A après Additionner(A,B):"); Afficher (A); New_Line;
			-- Nettoyage
			Detruire (A);
			Detruire (B);
		end;

		-- Nettoyage W
		Detruire (W);
	end;

	-- Nettoyage final
	Detruire (V);
	Put_Line ("Fin du scénario");
end Exemple_Vecteurs_Creux;
