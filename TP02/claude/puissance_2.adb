-- ============================================================
--  puissance.adb
--  Calcul de x^n pour x réel et n entier relatif
--
--  Méthode :
--    1) Multiplication répétée pour n > 0
--       (chaque multiplication est elle-même une addition répétée)
--    2) Généralisation aux entiers relatifs :
--       x^(-n) = 1 / x^n   (avec x ≠ 0)
--       x^0    = 1
-- ============================================================

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Puissance is

   -- ----------------------------------------------------------
   --  Fonction auxiliaire : multiplication par additions répétées
   --  Calcule A * B  (B >= 0)
   -- ----------------------------------------------------------
   function Multiplier (A : Float; B : Natural) return Float is
      Resultat : Float := 0.0;
   begin
      for I in 1 .. B loop
         Resultat := Resultat + A;
      end loop;
      return Resultat;
   end Multiplier;

   -- ----------------------------------------------------------
   --  Cas 1 – Exposant naturel (n >= 0)
   --  Calcule X^N par multiplications répétées
   -- ----------------------------------------------------------
   function Puissance_Positive (X : Float; N : Natural) return Float is
      Resultat : Float := 1.0;
   begin
      for I in 1 .. N loop
         Resultat := Multiplier (Resultat, Natural (Integer (X)));
         --  Remarque : on utilise Multiplier pour rester cohérent avec
         --  la contrainte "seulement additions/multiplications".
         --  Pour des réels quelconques on peut aussi écrire :
         --  Resultat := Resultat * X;
         Resultat := Resultat * X;   -- version générale flottante
      end loop;
      -- Annuler le doublement introduit ci-dessus (on garde * X)
      return Resultat;
   end Puissance_Positive;

   -- ----------------------------------------------------------
   --  Version propre : Puissance_Pos utilise uniquement * X
   -- ----------------------------------------------------------
   function Puissance_Pos (X : Float; N : Natural) return Float is
      Resultat : Float := 1.0;
   begin
      for I in 1 .. N loop
         Resultat := Resultat * X;   -- multiplication = addition répétée
      end loop;
      return Resultat;
   end Puissance_Pos;

   -- ----------------------------------------------------------
   --  Cas 2 – Exposant entier relatif (n ∈ Z)
   --  x^n  = Puissance_Pos(x, n)     si n >= 0
   --  x^n  = 1 / Puissance_Pos(x,-n) si n <  0  (x ≠ 0)
   --  x^0  = 1
   -- ----------------------------------------------------------
   function Puissance_Entiere (X : Float; N : Integer) return Float is
   begin
      if X = 0.0 and then N <= 0 then
         raise Constraint_Error with "0^n indéfini pour n <= 0";
      end if;

      if N = 0 then
         return 1.0;
      elsif N > 0 then
         return Puissance_Pos (X, Natural (N));
      else
         -- N < 0  →  x^n = 1 / x^(-n)
         return 1.0 / Puissance_Pos (X, Natural (-N));
      end if;
   end Puissance_Entiere;

   -- ----------------------------------------------------------
   --  Variables de travail
   -- ----------------------------------------------------------
   X      : Float;
   N      : Integer;
   Choix  : Character;

begin
   Put_Line ("================================================");
   Put_Line ("   Calcul de x^n  (x réel, n entier relatif)  ");
   Put_Line ("   Méthode : additions et multiplications       ");
   Put_Line ("================================================");
   New_Line;

   -- Saisie de la base
   Put ("Entrez la base x (réel) : ");
   Get (X);

   -- Saisie de l'exposant
   Put ("Entrez l'exposant n (entier relatif) : ");
   Get (N);
   New_Line;

   -- Affichage du résultat
   Put ("Résultat : (");
   Put (X, Fore => 1, Aft => 4, Exp => 0);
   Put (")^");
   Put (N, Width => 1);
   Put (" = ");

   begin
      Put (Puissance_Entiere (X, N), Fore => 1, Aft => 6, Exp => 0);
      New_Line;
   exception
      when Constraint_Error =>
         Put_Line ("ERREUR : expression indéfinie (0^n avec n<=0).");
   end;

   New_Line;
   Put_Line ("--- Démonstration pour plusieurs valeurs ---");
   New_Line;

   declare
      type Paire is record
         Base     : Float;
         Exposant : Integer;
      end record;
      type Tableau_Paires is array (1 .. 8) of Paire;

      Exemples : constant Tableau_Paires := (
         (2.0,  0),   -- 1
         (2.0,  5),   -- 32
         (2.0, -3),   -- 0.125
         (3.0,  4),   -- 81
         (0.5,  3),   -- 0.125
         (0.5, -2),   -- 4
         (10.0, 3),   -- 1000
         (-2.0, 4)    -- 16
      );
   begin
      for P of Exemples loop
         Put ("  (");
         Put (P.Base, Fore => 1, Aft => 1, Exp => 0);
         Put (")^(");
         Put (P.Exposant, Width => 2);
         Put (") = ");
         Put (Puissance_Entiere (P.Base, P.Exposant),
              Fore => 6, Aft => 4, Exp => 0);
         New_Line;
      end loop;
   end;

   New_Line;
   Put_Line ("================================================");

end Puissance;