with Stocks_Materiel; use Stocks_Materiel;
with Ada.Text_IO;     use Ada.Text_IO;

procedure Main is
   Mon_Stock : Stock;
begin
   Put_Line("Initialisation du scénario de test...");
   
   -- Initialisation
   Creer_Stock(Mon_Stock);
   pragma Assert (Nombre_Materiels(Mon_Stock) = 0);

   -- 1 & 2. Enregistrement de matériels
   Enregistrer_Materiel(Mon_Stock, 101, Unite_Centrale, 2023);
   Enregistrer_Materiel(Mon_Stock, 102, Ecran, 2024);
   Enregistrer_Materiel(Mon_Stock, 103, Imprimante, 2022);
   pragma Assert (Nombre_Materiels(Mon_Stock) = 3);

   -- 3 & 4. Modification d'état (Mise HS du 102 et 103)
   Modifier_Etat(Mon_Stock, 102, False);
   Modifier_Etat(Mon_Stock, 103, False);
   pragma Assert (Nombre_Hors_Service(Mon_Stock) = 2);

   -- 6. Affichage avant nettoyage
   Put_Line("Avant suppression du 102 :");
   Afficher_Stock(Mon_Stock);

   -- 5. Suppression d'un matériel précis (le 102)
   Supprimer_Materiel(Mon_Stock, 102);
   pragma Assert (Nombre_Materiels(Mon_Stock) = 2);
   pragma Assert (Nombre_Hors_Service(Mon_Stock) = 1); -- Reste le 103 qui est HS

   -- 7. Suppression de tous les matériels HS restants (le 103)
   Supprimer_Tous_HS(Mon_Stock);
   pragma Assert (Nombre_Materiels(Mon_Stock) = 1);    -- Ne doit rester que le 101
   pragma Assert (Nombre_Hors_Service(Mon_Stock) = 0);

   -- Affichage final
   Put_Line("Après exécution de tous les nettoyages (Seul le 101 doit rester) :");
   Afficher_Stock(Mon_Stock);

   Put_Line("Tous les tests (Assert) sont passés avec succès !");
end Main;