with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Compte_Jules is

   Objectif : Integer;   -- Somme souhaitée sur le compte de Jules
   Age      : Integer;   -- Age de Jules
   Solde    : Integer;   -- Solde du compte de Jules

begin
   -- Demander la somme souhaitée
   Put ("Somme attendue : ");
   Get (Objectif);

   -- Initialisation à la naissance (Age = 0)
   Age := 0;
   Solde := 100; -- Les parents versent 100 euros à la naissance

   -- Déterminer l'âge de Jules pour avoir au moins la somme sur son compte
   while Solde < Objectif loop
      Age := Age + 1;                  -- Jules prend un an de plus
      Solde := Solde + 100 + (2 * Age); -- Nouveau versement
   end loop;

   -- Afficher l'âge que doit avoir Jules
   Put ("Age : ");
   Put (Age, 1);
   New_Line;

end Compte_Jules;