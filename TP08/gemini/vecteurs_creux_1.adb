with Ada.Text_IO;                 use Ada.Text_IO;
with Ada.Integer_Text_IO;         use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;           use Ada.Float_Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Numerics.Elementary_Functions; -- Requis pour la racine carrée (Norme2)

package body Vecteurs_Creux is

	procedure Free is
		new Ada.Unchecked_Deallocation (T_Cellule, T_Vecteur_Creux);


	procedure Initialiser (V : out T_Vecteur_Creux) is
	begin
		V := null;
	end Initialiser;


	procedure Detruire (V: in out T_Vecteur_Creux) is
		A_Liberer : T_Vecteur_Creux;
	begin
		while V /= null loop
			A_Liberer := V;
			V := V.all.Suivant;
			Free (A_Liberer);
		end loop;
	end Detruire;


	function Est_Nul (V : in T_Vecteur_Creux) return Boolean is
	begin
		return V = null;
	end Est_Nul;


	function Composante_Recursif (V : in T_Vecteur_Creux ; Indice : in Integer) return Float is
	begin
		if V = null or else V.all.Indice > Indice then
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
		while Courant /= null loop
			if Courant.all.Indice = Indice then
				return Courant.all.Valeur;
			elsif Courant.all.Indice > Indice then
				-- Inutile d'aller plus loin si la liste est triée
				return 0.0;
			end if;
			Courant := Courant.all.Suivant;
		end loop;
		return 0.0;
	end Composante_Iteratif;


	procedure Modifier (V : in out T_Vecteur_Creux ;
						Indice : in Integer ;
						Valeur : in Float ) is
		A_Detruire : T_Vecteur_Creux;
	begin
		if V = null or else V.all.Indice > Indice then
			-- Insertion si la valeur n'est pas nulle
			if Valeur /= 0.0 then
				V := new T_Cellule'(Indice => Indice, Valeur => Valeur, Suivant => V);
			end if;
		elsif V.all.Indice = Indice then
			-- Modification ou suppression
			if Valeur = 0.0 then
				A_Detruire := V;
				V := V.all.Suivant;
				Free (A_Detruire);
			else
				V.all.Valeur := Valeur;
			end if;
		else
			-- Parcours récursif pour trouver le bon emplacement
			Modifier (V.all.Suivant, Indice, Valeur);
		end if;
	end Modifier;


	function Sont_Egaux_Recursif (V1, V2 : in T_Vecteur_Creux) return Boolean is
	begin
		if V1 = null and V2 = null then
			return True;
		elsif V1 = null or else V2 = null then
			return False;
		elsif V1.all.Indice /= V2.all.Indice or else V1.all.Valeur /= V2.all.Valeur then
			return False;
		else
			return Sont_Egaux_Recursif (V1.all.Suivant, V2.all.Suivant);
		end if;
	end Sont_Egaux_Recursif;


	function Sont_Egaux_Iteratif (V1, V2 : in T_Vecteur_Creux) return Boolean is
		C1 : T_Vecteur_Creux := V1;
		C2 : T_Vecteur_Creux := V2;
	begin
		while C1 /= null and C2 /= null loop
			if C1.all.Indice /= C2.all.Indice or else C1.all.Valeur /= C2.all.Valeur then
				return False;
			end if;
			C1 := C1.all.Suivant;
			C2 := C2.all.Suivant;
		end loop;
		-- Ils sont égaux uniquement si on a atteint la fin des deux listes en même temps
		return C1 = null and C2 = null;
	end Sont_Egaux_Iteratif;


	procedure Additionner (V1 : in out T_Vecteur_Creux; V2 : in T_Vecteur_Creux) is
		A_Detruire : T_Vecteur_Creux;
		Somme      : Float;
	begin
		-- Algorithme de fusion récursive (Merge) en O(N+M)
		if V2 = null then
			null; -- Rien à ajouter
		elsif V1 = null or else V1.all.Indice > V2.all.Indice then
			-- Insérer la cellule de V2 dans V1
			V1 := new T_Cellule'(Indice => V2.all.Indice, Valeur => V2.all.Valeur, Suivant => V1);
			Additionner (V1.all.Suivant, V2.all.Suivant);
		elsif V1.all.Indice = V2.all.Indice then
			Somme := V1.all.Valeur + V2.all.Valeur;
			if Somme = 0.0 then
				-- La somme s'annule, on supprime la cellule
				A_Detruire := V1;
				V1 := V1.all.Suivant;
				Free (A_Detruire);
				Additionner (V1, V2.all.Suivant);
			else
				-- On met à jour et on avance
				V1.all.Valeur := Somme;
				Additionner (V1.all.Suivant, V2.all.Suivant);
			end if;
		else
			-- On avance uniquement V1
			Additionner (V1.all.Suivant, V2);
		end if;
	end Additionner;


	function Norme2 (V : in T_Vecteur_Creux) return Float is
		Courant      : T_Vecteur_Creux := V;
		Somme_Carres : Float := 0.0;
	begin
		while Courant /= null loop
			Somme_Carres := Somme_Carres + (Courant.all.Valeur * Courant.all.Valeur);
			Courant := Courant.all.Suivant;
		end loop;
		return Ada.Numerics.Elementary_Functions.Sqrt (Somme_Carres);
	end Norme2;


	function Produit_Scalaire (V1, V2: in T_Vecteur_Creux) return Float is
		C1    : T_Vecteur_Creux := V1;
		C2    : T_Vecteur_Creux := V2;
		Somme : Float := 0.0;
	begin
		-- Parcours simultané optimisé (O(N+M))
		while C1 /= null and C2 /= null loop
			if C1.all.Indice = C2.all.Indice then
				Somme := Somme + (C1.all.Valeur * C2.all.Valeur);
				C1 := C1.all.Suivant;
				C2 := C2.all.Suivant;
			elsif C1.all.Indice < C2.all.Indice then
				C1 := C1.all.Suivant;
			else
				C2 := C2.all.Suivant;
			end if;
		end loop;
		return Somme;
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