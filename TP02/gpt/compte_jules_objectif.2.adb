with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Compte_Jules is

   Objectif : Integer;  -- Somme souhaitée sur le compte de Jules
   Age      : Integer;  -- Age de Jules
   Solde    : Integer;  -- Solde du compte de Jules

begin
   -- Demander la somme souhaitée
   Put ("Somme attendue : ");
   Get (Objectif);

   -- Initialisation : versement à la naissance (âge 0)
   Age   := 0;
   Solde := 100;

   -- Déterminer l'âge de Jules pour avoir au moins Objectif sur son compte
   while Solde < Objectif loop
      Age   := Age + 1;
      Solde := Solde + 100 + 2 * Age;
   end loop;

   -- Afficher l'âge que doit avoir Jules
   Put ("Age : ");
   Put (Age, 1);
   New_Line;

end Compte_Jules;

--  DEBUT

--      Afficher "Entrer l'âge :"
--      Lire age

--      SI age < 14 ALORS
--          tarif ← 7.0
--      SINON SI age >= 65 ALORS
--          tarif ← 10.30
--      SINON
--          tarif ← 12.60
--      FIN SI

--      Afficher "Tarif :", tarif

--  FIN