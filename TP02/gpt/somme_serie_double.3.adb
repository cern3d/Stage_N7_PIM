with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Somme_Serie_Double is

   Somme      : Integer := 0;
   Valeur     : Integer;
   Precedente : Integer;

begin
   -- Lire la première valeur
   Get(Valeur);
   Somme := Valeur;
   Precedente := Valeur;

   loop
      Get(Valeur);
      
      exit when Valeur = Precedente;  -- fin de série (valeur doublée)

      Somme := Somme + Valeur;
      Precedente := Valeur;
   end loop;

   -- Afficher la somme
   Put("Somme : ");
   Put(Somme, 1);
   New_Line;

end Somme_Serie_Double;




--  Début

--      Lire une valeur → precedent
--      Somme ← precedent

--      Répéter

--          Lire une valeur → courant

--          Si courant ≠ precedent alors
--              Somme ← Somme + courant
--          Fin Si

--          precedent ← courant

--      Jusqu’à courant = precedent

--      Afficher "Somme :", Somme

--  Fin