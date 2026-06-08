with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Somme_Serie_Double is

   Somme      : Integer := 0;
   Valeur     : Integer;
   Precedente : Integer;
   Fin        : Boolean := False;

begin
   -- Lire la première valeur
   Get(Valeur);
   Somme := Valeur;
   Precedente := Valeur;

   -- Boucle sans exit
   while not Fin loop
      Get(Valeur);

      if Valeur = Precedente then
         Fin := True;  -- fin de la série
      else
         Somme := Somme + Valeur;
         Precedente := Valeur;
      end if;
   end loop;

   -- Affichage
   Put("Somme : ");
   Put(Somme, 1);
   New_Line;

end Somme_Serie_Double;