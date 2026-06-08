with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Puissance is
   -- Déclaration des variables de saisie
   Base : Float;
   Exposant : Integer;
   
   -- Variables de travail
   Resultat : Float := 1.0;
   Abs_Exposant : Integer;
begin
   Put_Line("--- Calcul de la puissance entiere d'un reel ---");
   
   -- 1. Saisie des données
   Put("Entrez le reel (la base) : ");
   Get(Base);
   Put("Entrez l'entier (l'exposant) : ");
   Get(Exposant);

   -- 2. Traitement du cas où l'exposant est négatif (Généralisation)
   -- On extrait la valeur absolue manuellement pour la boucle
   if Exposant < 0 then
      Abs_Exposant := -Exposant;
   else
      Abs_Exposant := Exposant;
   end if;

   -- 3. Calcul de la puissance (Cas positif de base)
   -- On utilise la multiplication cumulative classique.
   -- (Pour faire une multiplication purement par somme sans fonction, 
   -- il aurait fallu imbriquer une seconde boucle, mais cela aurait détruit 
   -- la précision du Float "Resultat" à chaque étape).
   for I in 1 .. Abs_Exposant loop
      Resultat := Resultat * Base;
   end loop;

   -- 4. Finalisation pour les entiers relatifs
   -- Si l'exposant initial était négatif, on inverse le résultat.
   if Exposant < 0 then
      if Resultat /= 0.0 then
         Resultat := 1.0 / Resultat;
      else
         Put_Line("Erreur : Division par zero (0 puissance negative).");
      end if;
   end if;

   -- 5. Affichage du résultat
   Put("Resultat : ");
   Put(Resultat, Fore => 1, Aft => 4, Exp => 0);
   New_Line;

end Puissance;