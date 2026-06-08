with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

-- Afficher le chiffre significatif d'un entier naturel.
-- 
-- Attention à ne pas provoquer des débordement de la capacité des entiers.
-- 
-- Exemples :
--
--   entier  -> chiffre significatif
--   -------------------------------
--   25         ->  2
--   8          ->  8
--   9502       ->  9
--   0          ->  0
--   2147483647 ->  2
--
procedure Chiffre_Significatif is

	Entier: Integer;  -- l'entier naturel
	Chiffre_Significatif: Integer;   -- le chiffre significatif de Entier
begin
	-- Demander l'entier naturel
	Put ("Entier : ");
	Get (Entier);

		-- Déterminer le chiffre significatif
	if Entier = 0 then
		Chiffre_Significatif := 0;
	else
		while Entier >= 10 loop
			Entier := Entier / 10;
		end loop;
		Chiffre_Significatif := Entier;
	end if;

	-- Afficher le tarif
	Put ("Chiffre significatif : ");
	Put (Chiffre_Significatif, 1);
	New_Line;

end Chiffre_Significatif;

--  DEBUT

--      DECLARER Entier : entier
--      DECLARER Chiffre_Significatif : entier

--      AFFICHER "Entier : "
--      LIRE Entier

--      SI Entier = 0 ALORS
--          Chiffre_Significatif ← 0
--      SINON
--          TANT QUE Entier >= 10 FAIRE
--              Entier ← Entier / 10   // division entière
--          FIN TANT QUE

--          Chiffre_Significatif ← Entier
--      FIN SI

--      AFFICHER "Chiffre significatif : ", Chiffre_Significatif

--  FIN