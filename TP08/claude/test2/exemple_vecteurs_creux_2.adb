-- exemple_vecteurs_creux.adb
-- Scénario d'utilisation des vecteurs creux (démarche pas à pas)

with Ada.Text_IO;    use Ada.Text_IO;
with Vecteurs_Creux; use Vecteurs_Creux;

procedure Exemple_Vecteurs_Creux is

   V, W, X : T_Vecteur_Creux;

begin

   Put_Line ("=== 1. Initialiser ===");
   Initialiser (V);
   Put ("V après initialisation : ");
   Afficher (V);

   Put_Line ("");
   Put_Line ("=== 2. Est_Nul ===");
   if Est_Nul (V) then
      Put_Line ("V est bien nul. OK");
   else
      Put_Line ("ERREUR : V devrait être nul !");
   end if;

   Put_Line ("");
   Put_Line ("=== 3. Détruire ===");
   Detruire (V);
   Put ("V après destruction : ");
   Afficher (V);
   if Est_Nul (V) then
      Put_Line ("V est nul après destruction. OK");
   end if;

   Put_Line ("");
   Put_Line ("=== 4. Obtenir (avant modification) ===");
   -- V est nul, donc toutes ses composantes valent 0
   declare
      Val : Float;
   begin
      Val := Obtenir (V, 18);
      if Val = 0.0 then
         Put_Line ("Composante 18 de V (nul) vaut 0.0. OK");
      else
         Put_Line ("ERREUR : composante 18 devrait valoir 0.0 !");
      end if;
   end;

   Put_Line ("");
   Put_Line ("=== 5. Modifier ===");
   -- On construit le vecteur V = (3 -> 1.0, 7 -> 2.5, 10 -> -3.0, 18 -> 5.0)
   Modifier (V, 7,  2.5);
   Modifier (V, 3,  1.0);   -- insertion en tête (indice plus petit)
   Modifier (V, 18, 5.0);
   Modifier (V, 10, -3.0);
   Put ("V = "); Afficher (V);

   -- Vérification des composantes
   Put_Line ("Obtenir(V, 3)  = " & Float'Image (Obtenir (V, 3)));   -- 1.0
   Put_Line ("Obtenir(V, 7)  = " & Float'Image (Obtenir (V, 7)));   -- 2.5
   Put_Line ("Obtenir(V, 10) = " & Float'Image (Obtenir (V, 10)));  -- -3.0
   Put_Line ("Obtenir(V, 18) = " & Float'Image (Obtenir (V, 18)));  -- 5.0
   Put_Line ("Obtenir(V, 1)  = " & Float'Image (Obtenir (V, 1)));   -- 0.0 (absent)

   -- Mettre à zéro une composante existante (doit la supprimer)
   Modifier (V, 7, 0.0);
   Put ("V après Modifier(V, 7, 0.0) : "); Afficher (V);
   -- Remettre
   Modifier (V, 7, 2.5);

   Put_Line ("");
   Put_Line ("=== 6. Sont_Egaux ===");
   Initialiser (W);
   Modifier (W, 3,  1.0);
   Modifier (W, 7,  2.5);
   Modifier (W, 10, -3.0);
   Modifier (W, 18, 5.0);
   Put ("W = "); Afficher (W);

   if Sont_Egaux (V, W) then
      Put_Line ("V = W. OK");
   else
      Put_Line ("ERREUR : V et W devraient être égaux !");
   end if;

   Modifier (W, 18, 99.0);
   if not Sont_Egaux (V, W) then
      Put_Line ("V /= W après modification de W. OK");
   else
      Put_Line ("ERREUR : V et W ne devraient pas être égaux !");
   end if;
   Modifier (W, 18, 5.0);  -- on remet W comme V

   Put_Line ("");
   Put_Line ("=== 7. Additionner ===");
   -- X = (3 -> 0.5, 7 -> -2.5, 20 -> 1.0)
   Initialiser (X);
   Modifier (X, 3,  0.5);
   Modifier (X, 7,  -2.5);
   Modifier (X, 20, 1.0);
   Put ("X = "); Afficher (X);

   -- V + X :
   --   indice 3  : 1.0 + 0.5  =  1.5
   --   indice 7  : 2.5 + (-2.5) = 0.0  → supprimé
   --   indice 10 : -3.0 (inchangé)
   --   indice 18 : 5.0  (inchangé)
   --   indice 20 : 1.0  (nouveau)
   Additionner (V, X);
   Put ("V après Additionner(V, X) : "); Afficher (V);
   -- Attendu : (3, 1.50) (10, -3.00) (18, 5.00) (20, 1.00)

   Put_Line ("");
   Put_Line ("=== 8. Carre_Norme ===");
   -- ||V||² = 1.5² + (-3)² + 5² + 1² = 2.25 + 9 + 25 + 1 = 37.25
   Put_Line ("||V||² = " & Float'Image (Carre_Norme (V)));

   Put_Line ("");
   Put_Line ("=== 9. Produit_Scalaire ===");
   -- V · W  avec V=(3->1.5, 10->-3, 18->5, 20->1)
   --             W=(3->1,   7->2.5, 10->-3, 18->5)
   -- = 1.5*1 + (-3)*(-3) + 5*5 = 1.5 + 9 + 25 = 35.5
   Put_Line ("V · W = " & Float'Image (Produit_Scalaire (V, W)));

   Put_Line ("");
   Put_Line ("=== Nettoyage ===");
   Detruire (V);
   Detruire (W);
   Detruire (X);
   Put_Line ("Tous les vecteurs détruits.");

end Exemple_Vecteurs_Creux;
