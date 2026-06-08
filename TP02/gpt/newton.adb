with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;

procedure Newton is
   x        : Float;
   eps      : Float;
   a, next  : Float;
begin
   Put("Entrez un nombre x : ");
   Get(x);

   Put("Entrez la precision : ");
   Get(eps);

   -- Initialisation
   a := 1.0;

   loop
      next := (a + x / a) / 2.0;

      exit when abs(next - a) < eps;

      a := next;
   end loop;

   Put("Approximation de sqrt(x) = ");
   Put(next, Fore => 1, Aft => 6, Exp => 0);
   New_Line;
end Newton;