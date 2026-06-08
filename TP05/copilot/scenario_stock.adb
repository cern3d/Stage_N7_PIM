with Ada.Text_IO;          use Ada.Text_IO;
-- with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with Stocks_Materiel;      use Stocks_Materiel;

-- Auteur: 
-- Gérer un stock de matériel informatique.
--
procedure Scenario_Stock is

    Mon_Stock : T_Stock;
    Trouve     : Boolean;
begin
    -- Créer un stock vide
    Creer (Mon_Stock);
    pragma Assert (Nb_Materiels (Mon_Stock) = 0);

    -- Enregistrer quelques matériels
    Enregistrer (Mon_Stock, 1012, UNITE_CENTRALE, 2016);
    pragma Assert (Nb_Materiels (Mon_Stock) = 1);

    Enregistrer (Mon_Stock, 2143, ECRAN, 2016);
    pragma Assert (Nb_Materiels (Mon_Stock) = 2);

    Enregistrer (Mon_Stock, 3001, IMPRIMANTE, 2017);
    pragma Assert (Nb_Materiels (Mon_Stock) = 3);

    Enregistrer (Mon_Stock, 3012, UNITE_CENTRALE, 2017);
    pragma Assert (Nb_Materiels (Mon_Stock) = 4);

    -- Mettre à jour l'état d'un matériel
    Trouve := Mettre_A_Jour_Etat (Mon_Stock, 3012, HORS_FONCTIONNEMENT);
    pragma Assert (Trouve);
    pragma Assert (Nb_Hors_Fonctionnement (Mon_Stock) = 1);

    -- Mise à jour d'un matériel inexistant
    Trouve := Mettre_A_Jour_Etat (Mon_Stock, 9999, HORS_FONCTIONNEMENT);
    pragma Assert (not Trouve);

    -- Supprimer un matériel existant
    Trouve := Supprimer (Mon_Stock, 2143);
    pragma Assert (Trouve);
    pragma Assert (Nb_Materiels (Mon_Stock) = 3);

    -- Supprimer un matériel absent
    Trouve := Supprimer (Mon_Stock, 2143);
    pragma Assert (not Trouve);
    pragma Assert (Nb_Materiels (Mon_Stock) = 3);

    -- Afficher le stock actuel
    Afficher (Mon_Stock);

    -- Supprimer les matériels hors d'état de fonctionnement
    Supprimer_Hors_Fonctionnement (Mon_Stock);
    pragma Assert (Nb_Materiels (Mon_Stock) = 2);
    pragma Assert (Nb_Hors_Fonctionnement (Mon_Stock) = 0);

    Put_Line ("Scénario réussi.");

end Scenario_Stock;
