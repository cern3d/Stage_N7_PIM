with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Unchecked_Deallocation;

package body Vecteurs_Creux is

   procedure Free is new Ada.Unchecked_Deallocation (T_Cellule, T_Vecteur_Creux);

   procedure Initialiser (V : out T_Vecteur_Creux) is
   begin
      V := null;
   end Initialiser;

   function Est_Nul (V : in T_Vecteur_Creux) return Boolean is
   begin
      return V = null;
   end Est_Nul;

   procedure Detruire (V : in out T_Vecteur_Creux) is
   begin
      if V /= null then
         Detruire (V.Suivant);
         Free (V);
      end if;
   end Detruire;

   function Composante_Iterative (V : in T_Vecteur_Creux; Indice : in Integer) return Float is
      Courant : T_Vecteur_Creux := V;
   begin
      while Courant /= null and then Courant.Indice <= Indice loop
         if Courant.Indice = Indice then
            return Courant.Valeur;
         end if;
         Courant := Courant.Suivant;
      end loop;
      return 0.0;
   end Composante_Iterative;

   function Composante_Recursive (V : in T_Vecteur_Creux; Indice : in Integer) return Float is
   begin
      if V = null or else V.Indice > Indice then
         return 0.0;
      elsif V.Indice = Indice then
         return V.Valeur;
      else
         return Composante_Recursive (V.Suivant, Indice);
      end if;
   end Composante_Recursive;

   procedure Modifier (V : in out T_Vecteur_Creux; Indice : in Integer; Valeur : in Float) is
      Courant   : T_Vecteur_Creux := V;
      Precedent : T_Vecteur_Creux := null;
   begin
      while Courant /= null and then Courant.Indice < Indice loop
         Precedent := Courant;
         Courant := Courant.Suivant;
      end loop;

      if Courant /= null and then Courant.Indice = Indice then
         if Valeur = 0.0 then
            if Precedent = null then
               V := Courant.Suivant;
            else
               Precedent.Suivant := Courant.Suivant;
            end if;
            Free (Courant);
         else
            Courant.Valeur := Valeur;
         end if;
      elsif Valeur /= 0.0 then
         declare
            Nouveau : constant T_Vecteur_Creux := new T_Cellule'(Indice, Valeur, Courant);
         begin
            if Precedent = null then
               V := Nouveau;
            else
               Precedent.Suivant := Nouveau;
            end if;
         end;
      end if;
   end Modifier;

   function Sont_Egaux_Iterative (V1, V2 : in T_Vecteur_Creux) return Boolean is
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
      return C1 = null and C2 = null;
   end Sont_Egaux_Iterative;

   function Sont_Egaux_Recursive (V1, V2 : in T_Vecteur_Creux) return Boolean is
   begin
      if V1 = null and V2 = null then
         return True;
      elsif V1 = null or V2 = null then
         return False;
      elsif V1.Indice /= V2.Indice or else V1.Valeur /= V2.Valeur then
         return False;
      else
         return Sont_Egaux_Recursive (V1.Suivant, V2.Suivant);
      end if;
   end Sont_Egaux_Recursive;

   procedure Additionner (V1 : in out T_Vecteur_Creux; V2 : in T_Vecteur_Creux) is
      C2 : T_Vecteur_Creux := V2;
      Val_Courante : Float;
   begin
      while C2 /= null loop
         Val_Courante := Composante_Iterative (V1, C2.Indice);
         Modifier (V1, C2.Indice, Val_Courante + C2.Valeur);
         C2 := C2.Suivant;
      end loop;
   end Additionner;

   function Norme_Carree (V : in T_Vecteur_Creux) return Float is
      Courant : T_Vecteur_Creux := V;
      Somme   : Float := 0.0;
   begin
      while Courant /= null loop
         Somme := Somme + (Courant.Valeur * Courant.Valeur);
         Courant := Courant.Suivant;
      end loop;
      return Somme;
   end Norme_Carree;

   function Produit_Scalaire (V1, V2 : in T_Vecteur_Creux) return Float is
      C1 : T_Vecteur_Creux := V1;
      C2 : T_Vecteur_Creux := V2;
      PS : Float := 0.0;
   begin
      while C1 /= null and C2 /= null loop
         if C1.Indice = C2.Indice then
            PS := PS + (C1.Valeur * C2.Valeur);
            C1 := C1.Suivant;
            C2 := C2.Suivant;
         elsif C1.Indice < C2.Indice then
            C1 := C1.Suivant;
         else
            C2 := C2.Suivant;
         end if;
      end loop;
      return PS;
   end Produit_Scalaire;

   procedure Afficher (V : in T_Vecteur_Creux) is
      Courant : T_Vecteur_Creux := V;
   begin
      Put ("[ ");
      while Courant /= null loop
         Put ("(");
         Put (Courant.Indice, 0);
         Put (", ");
         Put (Courant.Valeur, Exp => 0, Aft => 2);
         Put (") ");
         Courant := Courant.Suivant;
      end loop;
      Put_Line ("]");
   end Afficher;

end Vecteurs_Creux;