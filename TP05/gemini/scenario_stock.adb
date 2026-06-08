with Ada.Text_IO;       use Ada.Text_IO;
with Stocks_Materiel;   use Stocks_Materiel;

procedure scenario_stocks is
    Mon_Stock : T_Stock;
begin
    Put_Line ("=== Étape 1 : Initialisation du Stock ===");
    Creer (Mon_Stock);
    Put_Line ("Nombre de matériels au départ : " & Integer'Image (Nb_Materiels (Mon_Stock)));
    New_Line;

    Put_Line ("=== Étape 2 : Enregistrement de matériels ===");
    Enregistrer (Mon_Stock, 101, UNITE_CENTRALE, 2023);
    Enregistrer (Mon_Stock, 102, ECRAN, 2024);
    Enregistrer (Mon_Stock, 103, CLAVIER, 2025);
    Enregistrer (Mon_Stock, 104, IMPRIMANTE, 2022);
    Afficher (Mon_Stock);
    New_Line;

    Put_Line ("=== Étape 3 : Simulation de pannes (Mise à jour d'état) ===");
    -- L'écran (102) et l'imprimante (104) tombent en panne
    Maj_Etat (Mon_Stock, 102);
    Maj_Etat (Mon_Stock, 104);
    Afficher (Mon_Stock);
    Put_Line ("Nombre d'équipements en panne : " & Integer'Image (Nb_Hors_Service (Mon_Stock)));
    New_Line;

    Put_Line ("=== Étape 4 : Suppression ciblée d'un matériel (103 - Clavier) ===");
    Supprimer (Mon_Stock, 103);
    Afficher (Mon_Stock);
    New_Line;

    Put_Line ("=== Étape 5 : Purge complète des éléments Hors Service ===");
    Purger_Hors_Service (Mon_Stock);
    Afficher (Mon_Stock);
    Put_Line ("Nombre final d'équipements opérationnels restants : " & Integer'Image (Nb_Materiels (Mon_Stock)));
end scenario_stocks;