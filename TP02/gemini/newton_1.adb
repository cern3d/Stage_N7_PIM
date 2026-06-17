with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;

procedure Newton is
   X         : Float;
   Precision : Float;

   -- 1. Premier critère d'arrêt : |a_k+1 - a_k| < Précision
   function Racine_Critere_Distance (Valeur : Float; Eps : Float) return Float is
      A_Courant : Float := 1.0;
      A_Suivant : Float;
   -- L'équation de récurrence est : $a_{k+1} = \frac{a_k + \frac{x}{a_k}}{2}$
   begin
      loop
         A_Suivant := (A_Courant + Valeur / A_Courant) / 2.0;
         exit when Float'Abs (A_Suivant - A_Courant) < Eps;
         A_Courant := A_Suivant;
      end loop;
      return A_Suivant;
   end Racine_Critere_Distance;

   -- 2. Second critère d'arrêt : |a_k^2 - x| < Précision
   function Racine_Critere_Residu (Valeur : Float; Eps : Float) return Float is
      A_Courant : Float := 1.0;
   begin
      loop
         exit when Float'Abs ((A_Courant * A_Courant) - Valeur) < Eps;
         A_Courant := (A_Courant + Valeur / A_Courant) / 2.0;
      end loop;
      return A_Courant;
   end Racine_Critere_Residu;

begin
   -- Lecture des entrées utilisateur
   Put ("Entrez le nombre dont vous voulez la racine (x > 0) : ");
   Get (X);
   
   if X < 0.0 then
      Put_Line ("Erreur : Le nombre doit être positif ou nul.");
      return;
   elsif X = 0.0 then
      Put_Line ("La racine carrée de 0 est 0.0");
      return;
   end if;

   Put ("Entrez la précision souhaitée (ex: 0.0001) : ");
   Get (Precision);
   New_Line;

   -- Affichage des résultats
   Put ("1. Approche (Distance entre a_k+1 et a_k) : ");
   Put (Racine_Critere_Distance (X, Precision), Fore => 1, Aft => 6, Exp => 0);
   New_Line;

   Put ("2. Approche (Proximité de a_k^2 avec x)  : ");
   Put (Racine_Critere_Residu (X, Precision), Fore => 1, Aft => 6, Exp => 0);
   New_Line;

end Newton;