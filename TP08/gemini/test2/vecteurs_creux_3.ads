package Vecteurs_Creux is

   -- Type abstrait représentant un vecteur creux
   type T_Vecteur_Creux is private;

   -- 1. Initialiser un vecteur creux (le vecteur est nul)
   procedure Initialiser (V : out T_Vecteur_Creux);

   -- 2. Déterminer si un vecteur est nul
   function Est_Nul (V : in T_Vecteur_Creux) return Boolean;

   -- 3. Détruire un vecteur creux (libérer la mémoire)
   procedure Detruire (V : in out T_Vecteur_Creux);

   -- 4. Obtenir une composante (Itérative et Récursive)
   function Composante_Iterative (V : in T_Vecteur_Creux; Indice : in Integer) return Float;
   function Composante_Recursive (V : in T_Vecteur_Creux; Indice : in Integer) return Float;

   -- 5. Modifier une composante d'un vecteur creux
   procedure Modifier (V : in out T_Vecteur_Creux; Indice : in Integer; Valeur : in Float);

   -- 6. Déterminer si deux vecteurs creux sont égaux
   function Sont_Egaux_Iterative (V1, V2 : in T_Vecteur_Creux) return Boolean;
   function Sont_Egaux_Recursive (V1, V2 : in T_Vecteur_Creux) return Boolean;

   -- 7. Additionner à un vecteur un autre vecteur (V1 := V1 + V2)
   procedure Additionner (V1 : in out T_Vecteur_Creux; V2 : in T_Vecteur_Creux);

   -- 8. Calculer le carré de la norme d'un vecteur creux
   function Norme_Carree (V : in T_Vecteur_Creux) return Float;

   -- 9. Calculer le produit scalaire de deux vecteurs
   function Produit_Scalaire (V1, V2 : in T_Vecteur_Creux) return Float;

   -- Afficher un vecteur creux
   procedure Afficher (V : in T_Vecteur_Creux);

private

   type T_Cellule;
   type T_Vecteur_Creux is access T_Cellule;

   type T_Cellule is record
      Indice  : Integer;
      Valeur  : Float;
      Suivant : T_Vecteur_Creux;
   end record;

end Vecteurs_Creux;