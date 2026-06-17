with Ada.Text_IO;
with Ada.Float_Text_IO;

procedure Newton is

   package TIO renames Ada.Text_IO;
   package FIO renames Ada.Float_Text_IO;

   X         : Float;
   Precision : Float;
   Ak        : Float;
   Ak1       : Float;

begin

   -- Lecture des entrées
   TIO.Put ("Entrez le nombre dont vous voulez la racine carree : ");
   FIO.Get (X);

   TIO.Put ("Entrez la precision souhaitee : ");
   FIO.Get (Precision);

   TIO.New_Line;

   -- -------------------------------------------------------
   -- MÉTHODE 1 : arrêt quand |ak+1 - ak| < precision
   -- -------------------------------------------------------
   TIO.Put_Line ("--- Methode 1 : |a(k+1) - a(k)| < precision ---");

   Ak := 1.0;
   loop
      Ak1 := (Ak + X / Ak) / 2.0;
      exit when abs (Ak1 - Ak) < Precision;
      Ak := Ak1;
   end loop;

   TIO.Put ("Racine carree approchee de ");
   FIO.Put (X, Fore => 1, Aft => 6, Exp => 0);
   TIO.Put (" = ");
   FIO.Put (Ak1, Fore => 1, Aft => 10, Exp => 0);
   TIO.New_Line;

   -- -------------------------------------------------------
   -- MÉTHODE 2 : arrêt quand |ak^2 - x| < precision
   -- -------------------------------------------------------
   TIO.New_Line;
   TIO.Put_Line ("--- Methode 2 : |a(k)^2 - x| < precision ---");

   Ak := 1.0;
   loop
      Ak1 := (Ak + X / Ak) / 2.0;
      exit when abs (Ak1 * Ak1 - X) < Precision;
      Ak := Ak1;
   end loop;

   TIO.Put ("Racine carree approchee de ");
   FIO.Put (X, Fore => 1, Aft => 6, Exp => 0);
   TIO.Put (" = ");
   FIO.Put (Ak1, Fore => 1, Aft => 10, Exp => 0);
   TIO.New_Line;

end Newton;