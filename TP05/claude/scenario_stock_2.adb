-- Scénario de démonstration et de test du module Stocks_Materiel
-- Chaque opération est vérifiée avec pragma Assert

with Ada.Text_IO;    use Ada.Text_IO;
with Stocks_Materiel; use Stocks_Materiel;

procedure Scenario is

   S : Stock;

begin

   -- ----------------------------------------------------------
   -- 1. Création du stock
   -- ----------------------------------------------------------
   Put_Line ("--- Creation du stock ---");
   Creer (S);
   pragma Assert (Nombre_Materiels (S) = 0, "Echec : stock non vide apres creation");
   Put_Line ("Stock cree : " & Natural'Image (Nombre_Materiels (S)) & " materiel(s)");

   -- ----------------------------------------------------------
   -- 2. Enregistrement de matériels
   -- ----------------------------------------------------------
   Put_Line ("--- Enregistrement ---");

   Enregistrer (S, 1001, Unite_Centrale, 2020);
   pragma Assert (Nombre_Materiels (S) = 1, "Echec enregistrement 1001");

   Enregistrer (S, 1002, Ecran, 2021);
   pragma Assert (Nombre_Materiels (S) = 2, "Echec enregistrement 1002");

   Enregistrer (S, 1003, Clavier, 2019);
   pragma Assert (Nombre_Materiels (S) = 3, "Echec enregistrement 1003");

   Enregistrer (S, 1004, Disque, 2022);
   pragma Assert (Nombre_Materiels (S) = 4, "Echec enregistrement 1004");

   Enregistrer (S, 1005, Imprimante, 2018);
   pragma Assert (Nombre_Materiels (S) = 5, "Echec enregistrement 1005");

   Put_Line ("Apres enregistrements :");
   Afficher (S);

   -- ----------------------------------------------------------
   -- 3. Nombre de matériels hors service (tous fonctionnels au départ)
   -- ----------------------------------------------------------
   pragma Assert (Nombre_Hors_Service (S) = 0,
                  "Echec : des materiels hors service au debut");
   Put_Line ("Hors service (attendu 0) : "
             & Natural'Image (Nombre_Hors_Service (S)));

   -- ----------------------------------------------------------
   -- 4. Mise à jour d'état
   -- ----------------------------------------------------------
   Put_Line ("--- Mise a jour etat ---");

   Mettre_A_Jour_Etat (S, 1002);   -- Ecran -> hors service
   Mettre_A_Jour_Etat (S, 1004);   -- Disque -> hors service
   pragma Assert (Nombre_Hors_Service (S) = 2,
                  "Echec : mauvais nombre hors service apres MAJ");
   Put_Line ("Hors service (attendu 2) : "
             & Natural'Image (Nombre_Hors_Service (S)));
   Afficher (S);

   -- Remettre 1004 en service pour tester l'inversion
   Mettre_A_Jour_Etat (S, 1004);
   pragma Assert (Nombre_Hors_Service (S) = 1,
                  "Echec : 1004 devrait etre remis en service");
   Put_Line ("Hors service apres remise en service 1004 (attendu 1) : "
             & Natural'Image (Nombre_Hors_Service (S)));

   -- ----------------------------------------------------------
   -- 5. Suppression d'un matériel par numéro de série
   -- ----------------------------------------------------------
   Put_Line ("--- Suppression de 1003 (Clavier) ---");
   Supprimer (S, 1003);
   pragma Assert (Nombre_Materiels (S) = 4,
                  "Echec : mauvais nb apres suppression 1003");
   Afficher (S);

   -- ----------------------------------------------------------
   -- 6. Suppression de tous les matériels hors service
   -- ----------------------------------------------------------
   Put_Line ("--- Suppression des materiels hors service ---");
   -- 1002 (Ecran) est toujours hors service
   pragma Assert (Nombre_Hors_Service (S) = 1,
                  "Echec : attendu 1 hors service avant suppression globale");
   Supprimer_Hors_Service (S);
   pragma Assert (Nombre_Hors_Service (S) = 0,
                  "Echec : il reste des materiels hors service");
   Put_Line ("Apres suppression des hors service :");
   Afficher (S);

   Put_Line ("=== Scenario termine avec succes ===");

end Scenario;