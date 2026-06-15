-- vecteurs_creux.ads
-- Spécification du module vecteurs creux

package Vecteurs_Creux is

   -- Type opaque représentant un vecteur creux
   -- Invariant : les cellules sont triées par ordre croissant d'indice
   --             et ne contiennent que des composantes non nulles
   type T_Vecteur_Creux is limited private;

   -- Initialiser un vecteur creux (vecteur nul)
   -- Nécessite : /
   -- Assure    : V est initialisé et nul
   procedure Initialiser (V : out T_Vecteur_Creux);

   -- Détruire un vecteur creux (libère la mémoire)
   -- Nécessite : V est initialisé
   -- Assure    : V est détruit (nul)
   procedure Detruire (V : in out T_Vecteur_Creux);

   -- Afficher un vecteur creux
   -- Nécessite : V est initialisé
   -- Assure    : /
   procedure Afficher (V : in T_Vecteur_Creux);

   -- Est-ce que V est nul ?
   -- Nécessite : V est initialisé
   function Est_Nul (V : in T_Vecteur_Creux) return Boolean;

   -- Obtenir la i-ème composante de V
   -- Nécessite : V est initialisé, I >= 1
   function Obtenir (V : in T_Vecteur_Creux; I : in Integer) return Float;

   -- Modifier la i-ème composante de V
   -- Nécessite : V est initialisé, I >= 1
   -- Assure    : V(I) = Valeur, invariant respecté
   procedure Modifier (V : in out T_Vecteur_Creux; I : in Integer; Valeur : in Float);

   -- Tester l'égalité de deux vecteurs creux
   -- Nécessite : V1 et V2 sont initialisés
   function Sont_Egaux (V1 : in T_Vecteur_Creux; V2 : in T_Vecteur_Creux) return Boolean;

   -- Additionner V2 à V1 (V1 := V1 + V2)
   -- Nécessite : V1 et V2 sont initialisés
   -- Assure    : V1 contient la somme, invariant respecté
   procedure Additionner (V1 : in out T_Vecteur_Creux; V2 : in T_Vecteur_Creux);

   -- Calculer le carré de la norme de V
   -- Nécessite : V est initialisé
   function Carre_Norme (V : in T_Vecteur_Creux) return Float;

   -- Calculer le produit scalaire de V1 et V2
   -- Nécessite : V1 et V2 sont initialisés
   function Produit_Scalaire (V1 : in T_Vecteur_Creux; V2 : in T_Vecteur_Creux) return Float;

private

   -- Cellule d'un vecteur creux : stocke un indice et une valeur non nulle
   type T_Cellule;
   type T_Vecteur_Creux is access T_Cellule;

   type T_Cellule is record
      Indice   : Integer;        -- indice de la composante (>= 1)
      Valeur   : Float;          -- valeur non nulle
      Suivant  : T_Vecteur_Creux; -- cellule suivante (indice strictement supérieur)
   end record;

end Vecteurs_Creux;
