with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;

procedure Newton is
   X         : Float;
   Precision : Float;
   
   -- Variables pour la première approche (Critère Distance)
   A_Courant_1 : Float;
   A_Suivant_1 : Float;
   
   -- Variables pour la seconde approche (Critère Résidu)
   A_Courant_2 : Float;
begin
   -- 1. Lecture des entrées utilisateur
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

   -------------------------------------------------------------------
   -- PREMIÈRE APPROCHE : Distance entre a_k+1 et a_k
   -------------------------------------------------------------------
   A_Courant_1 := 1.0;
   loop
      A_Suivant_1 := (A_Courant_1 + X / A_Courant_1) / 2.0;
      
      -- Le exit est placé immédiatement avant le end loop
      exit when abs (A_Suivant_1 - A_Courant_1) < Precision;
      
      A_Courant_1 := A_Suivant_1;
   end loop;

   Put ("1. Approche (Distance entre a_k+1 et a_k) : ");
   Put (A_Suivant_1, Fore => 1, Aft => 6, Exp => 0);
   New_Line;

   -------------------------------------------------------------------
   -- SECONDE APPROCHE : Proximité de a_k^2 avec x
   -------------------------------------------------------------------
   A_Courant_2 := 1.0;
   loop
      -- On vérifie d'abord si la valeur actuelle convient
      exit when abs ((A_Courant_2 * A_Courant_2) - X) < Precision;
      
      -- Sinon on calcule la suivante
      A_Courant_2 := (A_Courant_2 + X / A_Courant_2) / 2.0;
   end loop;

   Put ("2. Approche (Proximité de a_k^2 avec x)  : ");
   Put (A_Courant_2, Fore => 1, Aft => 6, Exp => 0);
   New_Line;

end Newton;