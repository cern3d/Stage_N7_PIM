with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Table_Pythagore is

    Taille: Integer;
begin
    -- Demander la taille
    Put ("Taille de la table : ");
    Get (Taille);

    -- Afficher l'en-tête
    Put ("X");
    for J in 1 .. Taille loop
        Put (J, Width => 3);
    end loop;
    New_Line;

    -- Afficher les lignes
    for I in 1 .. Taille loop
        Put (I, Width => 1);
        for J in 1 .. Taille loop
            Put (I * J, Width => 3);
        end loop;
        New_Line;
    end loop;

end Table_Pythagore;