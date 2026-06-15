-- vecteurs_creux.adb
-- Corps du module vecteurs creux
-- Représentation : liste chaînée triée par ordre croissant d'indice,
-- ne contenant que les composantes non nulles.

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;
with Ada.Unchecked_Deallocation;

package body Vecteurs_Creux is

   procedure Free is new Ada.Unchecked_Deallocation (T_Cellule, T_Vecteur_Creux);


   ---------------------------------------------------------------------------
   -- 1. Initialiser
   --    Un vecteur nul est représenté par un pointeur null.
   ---------------------------------------------------------------------------
   procedure Initialiser (V : out T_Vecteur_Creux) is
   begin
      V := null;
   end Initialiser;


   ---------------------------------------------------------------------------
   -- 2. Est_Nul
   --    Le vecteur est nul ssi la liste est vide.
   ---------------------------------------------------------------------------
   function Est_Nul (V : in T_Vecteur_Creux) return Boolean is
   begin
      return V = null;
   end Est_Nul;


   ---------------------------------------------------------------------------
   -- 3. Detruire
   --    Libère toutes les cellules et remet V à null.
   ---------------------------------------------------------------------------
   procedure Detruire (V : in out T_Vecteur_Creux) is
      Courant : T_Vecteur_Creux;
   begin
      while V /= null loop
         Courant := V;
         V       := V.Suivant;
         Free (Courant);
      end loop;
      -- V vaut déjà null ici
   end Detruire;


   ---------------------------------------------------------------------------
   -- 4a. Obtenir (version itérative)
   --     Parcourt la liste tant que l'indice courant < I.
   --     Retourne 0.0 si I n'est pas dans la liste.
   ---------------------------------------------------------------------------
   function Obtenir (V : in T_Vecteur_Creux; I : in Integer) return Float is
      Courant : T_Vecteur_Creux := V;
   begin
      while Courant /= null and then Courant.Indice < I loop
         Courant := Courant.Suivant;
      end loop;
      if Courant /= null and then Courant.Indice = I then
         return Courant.Valeur;
      else
         return 0.0;
      end if;
   end Obtenir;


   ---------------------------------------------------------------------------
   -- 4b. Obtenir_Rec (version récursive, interne)
   --     Même logique, exprimée récursivement.
   ---------------------------------------------------------------------------
   function Obtenir_Rec (V : in T_Vecteur_Creux; I : in Integer) return Float is
   begin
      if V = null or else V.Indice > I then
         -- I absent de la liste
         return 0.0;
      elsif V.Indice = I then
         return V.Valeur;
      else
         return Obtenir_Rec (V.Suivant, I);
      end if;
   end Obtenir_Rec;


   ---------------------------------------------------------------------------
   -- 5. Modifier
   --    Trois cas :
   --      a) Valeur = 0.0  → supprimer la cellule d'indice I si elle existe
   --      b) I existe déjà → mettre à jour la valeur
   --      c) I absent      → insérer une nouvelle cellule au bon endroit
   --    On utilise un pointeur « précédent » pour gérer les insertions/
   --    suppressions en tête et en milieu de liste de façon uniforme.
   ---------------------------------------------------------------------------
   procedure Modifier (V : in out T_Vecteur_Creux; I : in Integer; Valeur : in Float) is
      Prec    : T_Vecteur_Creux := null;
      Courant : T_Vecteur_Creux := V;
      Nouvelle : T_Vecteur_Creux;
   begin
      -- Avancer jusqu'à trouver l'indice I ou dépasser
      while Courant /= null and then Courant.Indice < I loop
         Prec    := Courant;
         Courant := Courant.Suivant;
      end loop;

      if Courant /= null and then Courant.Indice = I then
         -- L'indice I existe déjà dans la liste
         if Valeur = 0.0 then
            -- Supprimer la cellule
            if Prec = null then
               V := Courant.Suivant;
            else
               Prec.Suivant := Courant.Suivant;
            end if;
            Free (Courant);
         else
            -- Mettre à jour la valeur
            Courant.Valeur := Valeur;
         end if;
      elsif Valeur /= 0.0 then
         -- Insérer une nouvelle cellule avant Courant
         Nouvelle := new T_Cellule'(Indice  => I,
                                    Valeur  => Valeur,
                                    Suivant => Courant);
         if Prec = null then
            V := Nouvelle;        -- insertion en tête
         else
            Prec.Suivant := Nouvelle;
         end if;
      end if;
      -- Si Valeur = 0.0 et I absent : rien à faire
   end Modifier;


   ---------------------------------------------------------------------------
   -- 6a. Sont_Egaux (version itérative)
   --     Parcourt les deux listes en parallèle.
   --     Grâce au tri, deux listes égales ont les mêmes cellules dans le même
   --     ordre ; la comparaison est donc en O(n+m).
   ---------------------------------------------------------------------------
   function Sont_Egaux (V1 : in T_Vecteur_Creux; V2 : in T_Vecteur_Creux) return Boolean is
      C1 : T_Vecteur_Creux := V1;
      C2 : T_Vecteur_Creux := V2;
   begin
      while C1 /= null and C2 /= null loop
         if C1.Indice /= C2.Indice or else C1.Valeur /= C2.Valeur then
            return False;
         end if;
         C1 := C1.Suivant;
         C2 := C2.Suivant;
      end loop;
      -- Les deux listes doivent être épuisées en même temps
      return C1 = null and C2 = null;
   end Sont_Egaux;


   ---------------------------------------------------------------------------
   -- 6b. Sont_Egaux_Rec (version récursive, exposée via le même nom grâce
   --     à la surcharge, ou appelable séparément)
   ---------------------------------------------------------------------------
   -- Version récursive interne (on pourrait la rendre visible dans le .ads
   -- sous un autre nom si souhaité)
   function Sont_Egaux_Rec (C1 : T_Vecteur_Creux; C2 : T_Vecteur_Creux) return Boolean is
   begin
      if C1 = null and C2 = null then
         return True;
      elsif C1 = null or C2 = null then
         return False;
      elsif C1.Indice /= C2.Indice or else C1.Valeur /= C2.Valeur then
         return False;
      else
         return Sont_Egaux_Rec (C1.Suivant, C2.Suivant);
      end if;
   end Sont_Egaux_Rec;


   ---------------------------------------------------------------------------
   -- 7. Additionner  (V1 := V1 + V2)
   --    Fusion des deux listes triées.  Trois cas par étape :
   --      • indice V1 < indice V2 → avancer dans V1
   --      • indice V1 > indice V2 → insérer la cellule de V2 dans V1
   --      • indices égaux         → additionner les valeurs
   --                                (supprimer si résultat nul)
   --    On utilise un pointeur « prec » pour gérer insertions / suppressions.
   ---------------------------------------------------------------------------
   procedure Additionner (V1 : in out T_Vecteur_Creux; V2 : in T_Vecteur_Creux) is
      Prec     : T_Vecteur_Creux := null;   -- dernier nœud validé de V1
      C1       : T_Vecteur_Creux := V1;
      C2       : T_Vecteur_Creux := V2;
      Nouvelle : T_Vecteur_Creux;
      Temp     : T_Vecteur_Creux;
   begin
      while C2 /= null loop

         -- Avancer dans V1 tant que son indice est strictement inférieur
         while C1 /= null and then C1.Indice < C2.Indice loop
            Prec := C1;
            C1   := C1.Suivant;
         end loop;

         if C1 /= null and then C1.Indice = C2.Indice then
            -- Même indice : additionner
            declare
               Somme : constant Float := C1.Valeur + C2.Valeur;
            begin
               if Somme = 0.0 then
                  -- Supprimer C1
                  Temp := C1;
                  C1   := C1.Suivant;
                  if Prec = null then
                     V1 := C1;
                  else
                     Prec.Suivant := C1;
                  end if;
                  Free (Temp);
               else
                  C1.Valeur := Somme;
                  Prec := C1;
                  C1   := C1.Suivant;
               end if;
            end;
         else
            -- Indice de C2 absent de V1 : insérer une copie de C2
            Nouvelle := new T_Cellule'(Indice  => C2.Indice,
                                       Valeur  => C2.Valeur,
                                       Suivant => C1);
            if Prec = null then
               V1 := Nouvelle;
            else
               Prec.Suivant := Nouvelle;
            end if;
            Prec := Nouvelle;
         end if;

         C2 := C2.Suivant;
      end loop;
   end Additionner;


   ---------------------------------------------------------------------------
   -- 8. Carre_Norme  (||V||² = somme des vi²)
   ---------------------------------------------------------------------------
   function Carre_Norme (V : in T_Vecteur_Creux) return Float is
      Courant : T_Vecteur_Creux := V;
      Somme   : Float := 0.0;
   begin
      while Courant /= null loop
         Somme   := Somme + Courant.Valeur ** 2;
         Courant := Courant.Suivant;
      end loop;
      return Somme;
   end Carre_Norme;


   ---------------------------------------------------------------------------
   -- 9. Produit_Scalaire  (V1 · V2 = somme des v1i * v2i)
   --    Parcours en parallèle grâce au tri → O(n+m).
   ---------------------------------------------------------------------------
   function Produit_Scalaire (V1 : in T_Vecteur_Creux; V2 : in T_Vecteur_Creux) return Float is
      C1    : T_Vecteur_Creux := V1;
      C2    : T_Vecteur_Creux := V2;
      Somme : Float := 0.0;
   begin
      while C1 /= null and C2 /= null loop
         if C1.Indice = C2.Indice then
            Somme := Somme + C1.Valeur * C2.Valeur;
            C1    := C1.Suivant;
            C2    := C2.Suivant;
         elsif C1.Indice < C2.Indice then
            C1 := C1.Suivant;
         else
            C2 := C2.Suivant;
         end if;
      end loop;
      return Somme;
   end Produit_Scalaire;


   ---------------------------------------------------------------------------
   -- Afficher  (déjà fourni, inclus ici pour complétude)
   --   Affiche les composantes non nulles sous la forme "(i, v) "
   ---------------------------------------------------------------------------
   procedure Afficher (V : in T_Vecteur_Creux) is
      Courant : T_Vecteur_Creux := V;
   begin
      if Courant = null then
         Put_Line ("(vecteur nul)");
      else
         while Courant /= null loop
            Put ("(");
            Put (Courant.Indice, Width => 1);
            Put (", ");
            Put (Courant.Valeur, Fore => 1, Aft => 2, Exp => 0);
            Put (") ");
            Courant := Courant.Suivant;
         end loop;
         New_Line;
      end if;
   end Afficher;

end Vecteurs_Creux;
