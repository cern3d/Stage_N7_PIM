with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure newton is
	X, Prec, A, A_next : Long_Float;
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

	loop
		A_next := (A + X / A) / 2.0;
		Iter := Iter + 1;

		if Choice = 1 then
			exit when abs(A_next - A) < Prec or Iter >= Max_Iter;
		else
			exit when abs(A_next * A_next - X) < Prec or Iter >= Max_Iter;
		end if;

		A := A_next;
	end loop;

	Put("Approximation : ");
	Put(Item => A_next, Fore => 0, Aft => 10);
	New_Line;
	Put("Iterations : ");
	Put(Iter);
	New_Line;
end newton;

--  x86_64-linux-gnu-gcc-13 -c -I./ -gnatwa -I- ./newton.adb
--  newton.adb:15:17: error: no candidate interpretations match the actuals:
--  newton.adb:15:17: error: missing argument for parameter "Item" in call to "get" declared at a-tiinio.ads:94, instance at a-inteio.ads:18
--  newton.adb:15:17: error: missing argument for parameter "Item" in call to "get" declared at a-tiinio.ads:51, instance at a-inteio.ads:18
--  newton.adb:15:17: error: missing argument for parameter "Item" in call to "get" declared at a-tiflio.ads:97, instance at a-flteio.ads:20
--  newton.adb:15:17: error: missing argument for parameter "Item" in call to "get" declared at a-tiflio.ads:52, instance at a-flteio.ads:20
--  newton.adb:15:17: error: missing argument for parameter "Item" in call to "get" declared at a-textio.ads:502
--  newton.adb:15:17: error: missing argument for parameter "Item" in call to "get" declared at a-textio.ads:419
--  newton.adb:15:21: error: expected type "Standard.Integer"
--  newton.adb:15:21: error: found type "Standard.Long_Float"
--  newton.adb:15:21: error:   ==> in call to "Get" at a-tiinio.ads:60, instance at a-inteio.ads:18
--  newton.adb:15:21: error: expected type "Standard.Float"
--  newton.adb:15:21: error: found type "Standard.Long_Float"
--  newton.adb:15:21: error:   ==> in call to "Get" at a-tiflio.ads:61, instance at a-flteio.ads:20
--  newton.adb:15:21: error: expected type "Standard.String"
--  newton.adb:15:21: error: found type "Standard.Long_Float"
--  newton.adb:15:21: error:   ==> in call to "Get" at a-textio.ads:506
--  newton.adb:15:21: error: expected type "Standard.Character"
--  newton.adb:15:21: error: found type "Standard.Long_Float"
--  newton.adb:15:21: error:   ==> in call to "Get" at a-textio.ads:423
--  newton.adb:29:17: error: no candidate interpretations match the actuals:
--  newton.adb:29:17: error: missing argument for parameter "Item" in call to "get" declared at a-tiinio.ads:94, instance at a-inteio.ads:18
--  newton.adb:29:17: error: missing argument for parameter "Item" in call to "get" declared at a-tiinio.ads:51, instance at a-inteio.ads:18
--  newton.adb:29:17: error: missing argument for parameter "Item" in call to "get" declared at a-tiflio.ads:97, instance at a-flteio.ads:20
--  newton.adb:29:17: error: missing argument for parameter "Item" in call to "get" declared at a-tiflio.ads:52, instance at a-flteio.ads:20
--  newton.adb:29:17: error: missing argument for parameter "Item" in call to "get" declared at a-textio.ads:502
--  newton.adb:29:17: error: missing argument for parameter "Item" in call to "get" declared at a-textio.ads:419
--  newton.adb:29:21: error: expected type "Standard.Integer"
--  newton.adb:29:21: error: found type "Standard.Long_Float"
--  newton.adb:29:21: error:   ==> in call to "Get" at a-tiinio.ads:60, instance at a-inteio.ads:18
--  newton.adb:29:21: error: expected type "Standard.Float"
--  newton.adb:29:21: error: found type "Standard.Long_Float"
--  newton.adb:29:21: error:   ==> in call to "Get" at a-tiflio.ads:61, instance at a-flteio.ads:20
--  newton.adb:29:21: error: expected type "Standard.String"
--  newton.adb:29:21: error: found type "Standard.Long_Float"
--  newton.adb:29:21: error:   ==> in call to "Get" at a-textio.ads:506
--  newton.adb:29:21: error: expected type "Standard.Character"
--  newton.adb:29:21: error: found type "Standard.Long_Float"
--  newton.adb:29:21: error:   ==> in call to "Get" at a-textio.ads:423
--  newton.adb:73:09: error: no candidate interpretations match the actuals:
--  newton.adb:73:09: error: missing argument for parameter "To" in call to "put" declared at a-tiinio.ads:102, instance at a-inteio.ads:18
--  newton.adb:73:09: error: missing argument for parameter "File" in call to "put" declared at a-tiinio.ads:70, instance at a-inteio.ads:18
--  newton.adb:73:09: error: missing argument for parameter "To" in call to "put" declared at a-tiflio.ads:105, instance at a-flteio.ads:20
--  newton.adb:73:09: error: missing argument for parameter "File" in call to "put" declared at a-tiflio.ads:71, instance at a-flteio.ads:20
--  newton.adb:73:09: error: missing argument for parameter "File" in call to "put" declared at a-textio.ads:512
--  newton.adb:73:09: error: missing argument for parameter "File" in call to "put" declared at a-textio.ads:429
--  newton.adb:73:21: error: expected type "Standard.Float"
--  newton.adb:73:21: error: found type "Standard.Long_Float"
--  newton.adb:73:21: error:   ==> in call to "Put" at a-tiflio.ads:85, instance at a-flteio.ads:20
--  newton.adb:73:40: error: unmatched actual "Aft" in call
--  gnatmake: "./newton.adb" compilation error