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



--  DÉBUT Somme_Serie_Double

--      Somme ← 0
--      lire valeur_courante

--      TANT QUE valeur_précédente ≠ valeur_courante FAIRE
--          Somme ← Somme + valeur_courante
--          valeur_précédente ← valeur_courante
--          lire valeur_courante
--      FIN TANT QUE

--      // La dernière valeur (doublée) n'est pas ajoutée

--      Afficher "Somme : ", Somme

--  FIN Somme_Serie_Double
--  DÉBUT Somme_Serie_Double

--      Somme ← 0
--      lire précédent

--      RÉPÉTER
--          Somme ← Somme + précédent
--          lire courant
--          SI courant = précédent ALORS
--              quitter la boucle
--          FIN SI
--          précédent ← courant
--      FIN RÉPÉTER

--      Afficher "Somme : ", Somme

--  FIN Somme_Serie_Double





