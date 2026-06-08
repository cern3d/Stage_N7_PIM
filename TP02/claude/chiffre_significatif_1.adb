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