with Ada.Text_IO;      use Ada.Text_IO;
with Stocks_Materiel;  use Stocks_Materiel;

-- Scénario de test du module Stocks_Materiel.
-- Chaque opération est vérifiée avec pragma Assert.

procedure Scenario is

    S : T_Stock;

begin
    Put_Line ("=== SCENARIO DE TEST ===");
    New_Line;

    -- ------------------------------------------------------------
    -- 1. Création du stock
    -- ------------------------------------------------------------
    Put_Line ("-- Creer --");
    Creer (S);
    pragma Assert (Nb_Materiels (S) = 0,
                   "Erreur : le stock créé doit être vide");
    Put_Line ("Stock créé, taille = 0 : OK");
    New_Line;

    -- ------------------------------------------------------------
    -- 2. Enregistrement de matériels
    -- ------------------------------------------------------------
    Put_Line ("-- Enregistrer --");
    Enregistrer (S, Numero_Serie => 1001, Nature => ECRAN,         Annee_Achat => 2019);
    Enregistrer (S, Numero_Serie => 1002, Nature => CLAVIER,       Annee_Achat => 2020);
    Enregistrer (S, Numero_Serie => 1003, Nature => UNITE_CENTRALE,Annee_Achat => 2018);
    Enregistrer (S, Numero_Serie => 1004, Nature => DISQUE,        Annee_Achat => 2021);
    Enregistrer (S, Numero_Serie => 1005, Nature => IMPRIMANTE,    Annee_Achat => 2017);

    pragma Assert (Nb_Materiels (S) = 5,
                   "Erreur : le stock doit contenir 5 matériels");
    Put_Line ("5 matériels enregistrés, taille = 5 : OK");
    New_Line;

    -- ------------------------------------------------------------
    -- 3. Affichage du stock initial
    -- ------------------------------------------------------------
    Put_Line ("-- Afficher (état initial) --");
    Afficher (S);
    New_Line;

    -- ------------------------------------------------------------
    -- 4. Nb_Hors_Service (doit être 0 au départ)
    -- ------------------------------------------------------------
    Put_Line ("-- Nb_Hors_Service (avant pannes) --");
    pragma Assert (Nb_Hors_Service (S) = 0,
                   "Erreur : aucun matériel ne doit être hors service");
    Put_Line ("Nb_Hors_Service = 0 : OK");
    New_Line;

    -- ------------------------------------------------------------
    -- 5. Maj_Etat : mettre 1002 et 1004 hors service
    -- ------------------------------------------------------------
    Put_Line ("-- Maj_Etat : 1002 et 1004 passent hors service --");
    Maj_Etat (S, 1002);
    Maj_Etat (S, 1004);

    pragma Assert (Nb_Materiels (S) = 5,
                   "Erreur : Maj_Etat ne doit pas changer le nombre de matériels");
    pragma Assert (Nb_Hors_Service (S) = 2,
                   "Erreur : 2 matériels doivent être hors service");
    Put_Line ("Nb_Materiels = 5 et Nb_Hors_Service = 2 : OK");
    New_Line;

    Put_Line ("-- Afficher (après pannes) --");
    Afficher (S);
    New_Line;

    -- ------------------------------------------------------------
    -- 6. Maj_Etat : 1002 repasse en service (bascule)
    -- ------------------------------------------------------------
    Put_Line ("-- Maj_Etat : 1002 repasse en service --");
    Maj_Etat (S, 1002);

    pragma Assert (Nb_Hors_Service (S) = 1,
                   "Erreur : 1 seul matériel doit être hors service");
    Put_Line ("Nb_Hors_Service = 1 : OK");
    New_Line;

    -- ------------------------------------------------------------
    -- 7. Supprimer un matériel fonctionnel (1001)
    -- ------------------------------------------------------------
    Put_Line ("-- Supprimer 1001 --");
    Supprimer (S, 1001);

    pragma Assert (Nb_Materiels (S) = 4,
                   "Erreur : le stock doit contenir 4 matériels après suppression");
    Put_Line ("Nb_Materiels = 4 : OK");
    New_Line;

    Put_Line ("-- Afficher (après suppression de 1001) --");
    Afficher (S);
    New_Line;

    -- ------------------------------------------------------------
    -- 8. Purger_Hors_Service
    --    Situation : 1004 est hors service, les autres sont OK
    -- ------------------------------------------------------------
    Put_Line ("-- Purger_Hors_Service --");
    declare
        Nb_Avant_Purge : Integer := Nb_Materiels (S);
        Hs_Avant_Purge : Integer := Nb_Hors_Service (S);
    begin
        Purger_Hors_Service (S);

        pragma Assert (Nb_Hors_Service (S) = 0,
                       "Erreur : plus aucun matériel ne doit être hors service");
        pragma Assert (Nb_Materiels (S) = Nb_Avant_Purge - Hs_Avant_Purge,
                       "Erreur : nombre de matériels incorrect après purge");
        Put_Line ("Nb_Hors_Service = 0 et Nb_Materiels correct après purge : OK");
    end;
    New_Line;

    Put_Line ("-- Afficher (après purge) --");
    Afficher (S);
    New_Line;

    Put_Line ("=== FIN DU SCENARIO : tous les tests passent ===");

end Scenario;