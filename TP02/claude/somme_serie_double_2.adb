with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Somme_Serie_Double is

    Somme      : Integer := 0;
    Valeur     : Integer;
    Precedente : Integer;

begin
    Get (Precedente);
    Somme := Precedente;

    Get (Valeur);
    while Valeur /= Precedente loop
        Somme      := Somme + Valeur;
        Precedente := Valeur;
        Get (Valeur);
    end loop;

    Put ("Somme : ");
    Put (Somme, 1);
    New_Line;

end Somme_Serie_Double;