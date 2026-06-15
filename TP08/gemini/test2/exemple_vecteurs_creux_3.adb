with Ada.Text_IO; use Ada.Text_IO;
with Vecteurs_Creux; use Vecteurs_Creux;

procedure Exemple_Vecteurs_Creux is
   V, W : T_Vecteur_Creux;
   Norme : Float;
   PS    : Float;
begin
   Put_Line ("--- 1. Initialiser un vecteur creux ---");
   Initialiser (V);
   Afficher (V);

   Put_Line ("--- 2. Determiner si le vecteur est nul ---");
   if Est_Nul (V) then
      Put_Line ("Le vecteur V est nul.");
   else
      Put_Line ("Erreur: Le vecteur V devrait etre nul.");
   end if;

   Put_Line ("--- 5. Modifier une composante d'un vecteur creux ---");
   Modifier (V, 5, 10.5);
   Modifier (V, 2, 3.2);  -- L'indice 2 doit s'insérer avant le 5 (invariant)
   Modifier (V, 18, 7.0);
   Afficher (V);

   Put_Line ("--- 4. Obtenir une composante de V ---");
   Put_Line ("Composante 18 (iterative): " & Float'Image (Composante_Iterative (V, 18)));
   Put_Line ("Composante 2 (recursive): " & Float'Image (Composante_Recursive (V, 2)));
   Put_Line ("Composante 10 (inexistante): " & Float'Image (Composante_Iterative (V, 10)));

   Put_Line ("--- 6. Determiner si deux vecteurs sont egaux ---");
   Initialiser (W);
   Modifier (W, 2, 3.2);
   Modifier (W, 5, 10.5);
   Modifier (W, 18, 7.0);
   
   if Sont_Egaux_Iterative (V, W) then
      Put_Line ("V et W sont egaux (test iteratif : OK).");
   end if;

   Put_Line ("--- 7. Additionner a un vecteur un autre vecteur ---");
   Additionner (V, W); 
   Put_Line ("V après V := V + W :");
   Afficher (V);

   Put_Line ("--- 8. Calculer le carre de la norme ---");
   Norme := Norme_Carree (W);
   Put_Line ("Norme carree de W : " & Float'Image (Norme));

   Put_Line ("--- 9. Calculer le produit scalaire ---");
   PS := Produit_Scalaire (V, W);
   Put_Line ("Produit scalaire V.W : " & Float'Image (PS));

   Put_Line ("--- 3. Detruire un vecteur creux ---");
   Detruire (V);
   Detruire (W);
   if Est_Nul (V) then
      Put_Line ("V a ete detruit avec succes.");
   end if;

end Exemple_Vecteurs_Creux;