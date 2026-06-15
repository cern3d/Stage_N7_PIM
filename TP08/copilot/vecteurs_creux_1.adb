with Ada.Text_IO;                 use Ada.Text_IO;
with Ada.Integer_Text_IO;         use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;           use Ada.Float_Text_IO;
with Ada.Unchecked_Deallocation;

package body Vecteurs_Creux is


	procedure Free is
		new Ada.Unchecked_Deallocation (T_Cellule, T_Vecteur_Creux);


	procedure Initialiser (V : out T_Vecteur_Creux) is
	begin
		V := Null;
	end Initialiser;


	procedure Detruire (V: in out T_Vecteur_Creux) is

		procedure Liberer (P : in out T_Vecteur_Creux) is
		begin
			if P /= Null then
				Liberer (P.all.Suivant);
				Free (P);
				P := Null;
			end if;
		end Liberer;

	begin
		Liberer (V);
	end Detruire;


	function Est_Nul (V : in T_Vecteur_Creux) return Boolean is
	begin
		return V = Null;
	end Est_Nul;


	function Composante_Recursif (V : in T_Vecteur_Creux ; Indice : in Integer) return Float is
	begin
		if V = Null or else V.all.Indice > Indice then
			return 0.0;
		elsif V.all.Indice = Indice then
			return V.all.Valeur;
		else
			return Composante_Recursif (V.all.Suivant, Indice);
		end if;
	end Composante_Recursif;


	function Composante_Iteratif (V : in T_Vecteur_Creux ; Indice : in Integer) return Float is
		Courant : T_Vecteur_Creux := V;
	begin
		while Courant /= Null and then Courant.all.Indice < Indice loop
			Courant := Courant.all.Suivant;
		end loop;

		if Courant = Null or else Courant.all.Indice /= Indice then
			return 0.0;
		else
			return Courant.all.Valeur;
		end if;
	end Composante_Iteratif;


	procedure Modifier (V : in out T_Vecteur_Creux ;
				       Indice : in Integer ;
					   Valeur : in Float ) is
		Courant : T_Vecteur_Creux := V;
		Precedent : T_Vecteur_Creux := Null;
		Nouvelle_Cellule : T_Vecteur_Creux;
	begin
		while Courant /= Null and then Courant.all.Indice < Indice loop
			Precedent := Courant;
			Courant := Courant.all.Suivant;
		end loop;

		if Courant /= Null and then Courant.all.Indice = Indice then
			if Valeur = 0.0 then
				if Precedent = Null then
					V := Courant.all.Suivant;
				else
					Precedent.all.Suivant := Courant.all.Suivant;
				end if;
				Free (Courant);
			else
				Courant.all.Valeur := Valeur;
			end if;
		elsif Valeur /= 0.0 then
			Nouvelle_Cellule := new T_Cellule'(Indice => Indice,
								      Valeur => Valeur,
								      Suivant => Courant);
			if Precedent = Null then
				V := Nouvelle_Cellule;
			else
				Precedent.all.Suivant := Nouvelle_Cellule;
			end if;
		end if;
	end Modifier;

	function Sont_Egaux_Recursif (V1, V2 : in T_Vecteur_Creux) return Boolean is
	begin
		if V1 = Null and V2 = Null then
			return True;
		elsif V1 = Null or V2 = Null then
			return False;
		elsif V1.all.Indice /= V2.all.Indice then
			return False;
		elsif V1.all.Valeur /= V2.all.Valeur then
			return False;
		else
			return Sont_Egaux_Recursif (V1.all.Suivant, V2.all.Suivant);
		end if;
	end Sont_Egaux_Recursif;


	function Sont_Egaux_Iteratif (V1, V2 : in T_Vecteur_Creux) return Boolean is
		Courant1 : T_Vecteur_Creux := V1;
		Courant2 : T_Vecteur_Creux := V2;
	begin
		while Courant1 /= Null and then Courant2 /= Null loop
			if Courant1.all.Indice /= Courant2.all.Indice or else
			   Courant1.all.Valeur /= Courant2.all.Valeur then
				return False;
			end if;
			Courant1 := Courant1.all.Suivant;
			Courant2 := Courant2.all.Suivant;
		end loop;
		return Courant1 = Null and Courant2 = Null;
	end Sont_Egaux_Iteratif;


	procedure Additionner (V1 : in out T_Vecteur_Creux; V2 : in T_Vecteur_Creux) is
		Courant1 : T_Vecteur_Creux := V1;
		Precedent1 : T_Vecteur_Creux := Null;
		Courant2 : T_Vecteur_Creux := V2;
		Somme : Float;
		Nouvelle_Cellule : T_Vecteur_Creux;
	begin
		while Courant2 /= Null loop
			if Courant1 = Null or else Courant1.all.Indice > Courant2.all.Indice then
				if Courant2.all.Valeur /= 0.0 then
					Nouvelle_Cellule := new T_Cellule'(Indice => Courant2.all.Indice,
								      Valeur => Courant2.all.Valeur,
								      Suivant => Courant1);
					if Precedent1 = Null then
						V1 := Nouvelle_Cellule;
					else
						Precedent1.all.Suivant := Nouvelle_Cellule;
					end if;
					Precedent1 := Nouvelle_Cellule;
				end if;
				Courant2 := Courant2.all.Suivant;
			elsif Courant1.all.Indice < Courant2.all.Indice then
				Precedent1 := Courant1;
				Courant1 := Courant1.all.Suivant;
			else
				Somme := Courant1.all.Valeur + Courant2.all.Valeur;
				if Somme = 0.0 then
					if Precedent1 = Null then
						V1 := Courant1.all.Suivant;
					else
						Precedent1.all.Suivant := Courant1.all.Suivant;
					end if;
					Free (Courant1);
					Courant1 := (if Precedent1 = Null then V1 else Precedent1.all.Suivant);
				else
					Courant1.all.Valeur := Somme;
					Precedent1 := Courant1;
					Courant1 := Courant1.all.Suivant;
				end if;
				Courant2 := Courant2.all.Suivant;
			end if;
		end loop;
	end Additionner;


	function Norme2 (V : in T_Vecteur_Creux) return Float is
	begin
		if V = Null then
			return 0.0;
		else
			return V.all.Valeur * V.all.Valeur + Norme2 (V.all.Suivant);
		end if;
	end Norme2;


	Function Produit_Scalaire (V1, V2: in T_Vecteur_Creux) return Float is
		Courant1 : T_Vecteur_Creux := V1;
		Courant2 : T_Vecteur_Creux := V2;
		Produit : Float := 0.0;
	begin
		while Courant1 /= Null and then Courant2 /= Null loop
			if Courant1.all.Indice < Courant2.all.Indice then
				Courant1 := Courant1.all.Suivant;
			elsif Courant2.all.Indice < Courant1.all.Indice then
				Courant2 := Courant2.all.Suivant;
			else
				Produit := Produit + Courant1.all.Valeur * Courant2.all.Valeur;
				Courant1 := Courant1.all.Suivant;
				Courant2 := Courant2.all.Suivant;
			end if;
		end loop;
		return Produit;
	end Produit_Scalaire;


	procedure Afficher (V : T_Vecteur_Creux) is
	begin
		if V = Null then
			Put ("--E");
		else
			-- Afficher la composante V.all
			Put ("-->[ ");
			Put (V.all.Indice, 0);
			Put (" | ");
			Put (V.all.Valeur, Fore => 0, Aft => 1, Exp => 0);
			Put (" ]");

			-- Afficher les autres composantes
			Afficher (V.all.Suivant);
		end if;
	end Afficher;


	function Nombre_Composantes_Non_Nulles (V: in T_Vecteur_Creux) return Integer is
	begin
		if V = Null then
			return 0;
		else
			return 1 + Nombre_Composantes_Non_Nulles (V.all.Suivant);
		end if;
	end Nombre_Composantes_Non_Nulles;


end Vecteurs_Creux;
