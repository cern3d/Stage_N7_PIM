with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Vecteurs_Creux;    use Vecteurs_Creux;

procedure Exemple_Vecteurs_Creux is

	V1, V2 : T_Vecteur_Creux;

begin
	Put_Line ("=== DEBUT DU SCENARIO DE TEST ===");
	Put_Line ("");

	-- 1. Initialiser un vecteur creux
	Put_Line ("1. Initialisation de V1 :");
	Initialiser (V1);
	Afficher (V1); 
	Put_Line ("");
	Put_Line ("");

	-- 2. Déterminer si un vecteur est nul
	Put_Line ("2. Test si V1 est nul :");
	if Est_Nul (V1) then
		Put_Line ("   -> OK : V1 est bien nul.");
	else
		Put_Line ("   -> ERREUR : V1 devrait etre nul.");
	end if;
	Put_Line ("");

	-- 3. Détruire un vecteur creux
	Put_Line ("3. Destruction de V1 (actuellement vide) :");
	Detruire (V1);
	Put_Line ("   -> OK : La destruction d'un vecteur vide n'a pas cause d'erreur.");
	Put_Line ("");

	-- 4. Obtenir une composante de V (Iteratif et Recursif)
	Put_Line ("4. Obtention d'une composante (indice 18) sur vecteur vide :");
	Initialiser (V1); -- On le réinitialise par sécurité après la destruction
	Put ("   -> Composante 18 (iteratif) = ");
	Put (Composante_Iteratif(V1, 18), Fore => 1, Aft => 1, Exp => 0);
	Put_Line (" (attendu : 0.0)");
	Put ("   -> Composante 18 (recursif) = ");
	Put (Composante_Recursif(V1, 18), Fore => 1, Aft => 1, Exp => 0);
	Put_Line (" (attendu : 0.0)");
	Put_Line ("");

	-- 5. Modifier une composante d'un vecteur creux
	Put_Line ("5. Modification de composantes de V1 :");
	Modifier (V1, 18, 3.5);
	Modifier (V1, 5,  1.2);
	Modifier (V1, 20, 4.0);
	Put ("   -> V1 apres modifications : ");
	Afficher (V1);
	Put_Line ("");
	Put ("   -> Verification de la composante 18 = ");
	Put (Composante_Iteratif(V1, 18), Fore => 1, Aft => 1, Exp => 0);
	Put_Line (" (attendu : 3.5)");
	Put_Line ("");

	-- 6. Déterminer si deux vecteurs creux sont égaux
	Put_Line ("6. Test d'egalite entre deux vecteurs :");
	Initialiser (V2);
	Modifier (V2, 5,  1.2);
	Modifier (V2, 18, 3.5);
	Modifier (V2, 20, 4.0);
	Put ("   -> V2 = "); Afficher (V2); Put_Line ("");
	
	if Sont_Egaux_Iteratif (V1, V2) then
		Put_Line ("   -> OK : V1 et V2 sont egaux (test iteratif).");
	else
		Put_Line ("   -> ERREUR : V1 et V2 devraient etre egaux (test iteratif).");
	end if;

	if Sont_Egaux_Recursif (V1, V2) then
		Put_Line ("   -> OK : V1 et V2 sont egaux (test recursif).");
	else
		Put_Line ("   -> ERREUR : V1 et V2 devraient etre egaux (test recursif).");
	end if;
	Put_Line ("");

	-- 7. Additionner à un vecteur un autre vecteur
	Put_Line ("7. Addition de V2 a V1 (V1 := V1 + V2) :");
	Additionner (V1, V2);
	Put ("   -> V1 apres addition : ");
	Afficher (V1);
	Put_Line ("");
	Put_Line ("   -> (Les valeurs de V1 devraient etre le double de celles de V2)");
	Put_Line ("");

	-- 8. Calculer la norme 2 d'un vecteur creux
	Put_Line ("8. Calcul de la norme 2 de V2 :");
	Put ("   -> Norme2(V2) = ");
	Put (Norme2(V2), Fore => 1, Aft => 3, Exp => 0);
	Put_Line (" (attendu ~ 5.448)");
	Put_Line ("");

	-- 9. Calculer le produit scalaire de deux vecteurs
	Put_Line ("9. Produit scalaire de V1 et V2 :");
	Put ("   -> V1 . V2 = ");
	Put (Produit_Scalaire(V1, V2), Fore => 1, Aft => 1, Exp => 0);
	Put_Line (" (attendu : 59.38 car V1 est le double de V2)");
	Put_Line ("");

	-- Nettoyage final
	Put_Line ("=== NETTOYAGE ===");
	Detruire (V1);
	Detruire (V2);
	Put_Line ("Destruction de V1 et V2 terminee. Fin du programme.");

end Exemple_Vecteurs_Creux;