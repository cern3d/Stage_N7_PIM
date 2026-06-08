with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Chiffre_Significatif is

    Entier               : Integer;
    Chiffre_Significatif : Integer;

begin
    -- Demander l'entier naturel
    Put ("Entier : ");
    Get (Entier);

    -- Déterminer le chiffre significatif
    Chiffre_Significatif := Entier;
    while Chiffre_Significatif >= 10 loop
        Chiffre_Significatif := Chiffre_Significatif / 10;
    end loop;

    -- Afficher le chiffre significatif
    Put ("Chiffre significatif : ");
    Put (Chiffre_Significatif, 1);
    New_Line;

end Chiffre_Significatif;


--  PROGRAMME Chiffre_Significatif

--    VARIABLES
--      entier             : entier naturel
--      chiffre_significatif : entier naturel

--    DÉBUT
--      ÉCRIRE "Entier : "
--      LIRE entier

--      chiffre_significatif ← entier

--      TANT QUE chiffre_significatif >= 10 FAIRE
--        chiffre_significatif ← chiffre_significatif / 10
--      FIN TANT QUE

--      ÉCRIRE "Chiffre significatif : "
--      ÉCRIRE chiffre_significatif

--    FIN