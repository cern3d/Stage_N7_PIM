with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Somme_Serie_Double is

    Somme    : Integer := 0;
    Valeur   : Integer;
    Precedente : Integer;

begin
    -- Lire la première valeur
    Get (Valeur);
    Somme := Valeur;
    Precedente := Valeur;

    -- Lire les valeurs suivantes jusqu'à ce qu'une valeur soit égale à la précédente
    loop
        Get (Valeur);
        exit when Valeur = Precedente;
        Somme := Somme + Valeur;
        Precedente := Valeur;
    end loop;

    -- Afficher la somme
    Put ("Somme : ");
    Put (Somme, 1);
    New_Line;

end Somme_Serie_Double;




