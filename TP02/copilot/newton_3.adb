with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure newton is
	X, Prec, A, A_next : Float;
	Choice             : Integer := 1;
	Max_Iter           : constant Integer := 100000;
	Iter               : Integer := 0;
begin
	Put_Line("Approximation de la racine carree par la methode de Newton");

	Put("Entrez le nombre x (>= 0) : ");
	begin
		Get(X);
	exception
		when Data_Error | End_Error =>
			Put_Line("Entree invalide.");
			return;
	end;

	if X < 0.0 then
		Put_Line("x doit etre non-negatif.");
		return;
	end if;

	Put("Entrez la precision positive (ex: 1E-6) : ");
	begin
		Get(Prec);
	exception
		when Data_Error | End_Error =>
			Put_Line("Entrée de la precision invalide.");
			return;
	end;

	if Prec <= 0.0 then
		Put_Line("Precision doit etre positive.");
		return;
	end if;

	Put_Line("Choisissez le critere d'arret :");
	Put_Line("  1 - |a_{k+1} - a_k| < precision");
	Put_Line("  2 - |a_k^2 - x| < precision");
	Put("Votre choix (1 ou 2) [1] : ");
	begin
		Get(Choice);
	exception
		when Data_Error | End_Error =>
			Choice := 1;
	end;

	if Choice /= 1 and Choice /= 2 then
		Put_Line("Choix invalide, on prend 1.");
		Choice := 1;
	end if;

	A := 1.0;

	declare
		Done : Boolean := False;
	begin
		loop
			A_next := (A + X / A) / 2.0;
			Iter := Iter + 1;

			if Choice = 1 then
				if abs(A_next - A) < Prec or Iter >= Max_Iter then
					Done := True;
				end if;
			else
				if abs(A_next * A_next - X) < Prec or Iter >= Max_Iter then
					Done := True;
				end if;
			end if;

			if not Done then
				A := A_next;
			end if;

			if Done then
				exit;
			end if;
		end loop;
	end;

	Put("Approximation : ");
	Put(Item => A_next, Fore => 0, Aft => 10);
	New_Line;
	Put("Iterations : ");
	Put(Iter);
	New_Line;
end newton;

