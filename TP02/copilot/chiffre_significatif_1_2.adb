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


-- Début
-- 1. Lire l'entier Entier depuis l'entrée.
-- 2. Si Entier = 0 alors
-- Chiffre_Significatif := 0
-- Sinon
-- Temp := abs(Entier) -- prendre la valeur absolue
-- -- (si abs risque de déborder pour Min_Int, traiter ce cas séparément)
-- Tant que Temp > 9 faire
-- Temp := Temp / 10 -- division entière pour supprimer le chiffre des unités
-- Fin Tant que
-- Chiffre_Significatif := Temp
-- Fin Si
-- 3. Afficher Chiffre_Significatif
-- Fin

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
		declare
			Temp : Integer := Entier;
		begin
			if Temp < 0 then
				Temp := -Temp;
			end if;
			while Temp > 9 loop
				Temp := Temp / 10;
			end loop;
			Chiffre_Significatif := Temp;
		end;
	end if;

	-- Afficher le tarif
	Put ("Chiffre significatif : ");
	Put (Chiffre_Significatif, 1);
	New_Line;

end Chiffre_Significatif;
