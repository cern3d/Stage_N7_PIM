-- Gérer un stock de matériel informatique.
package Stocks_Materiel is

    CAPACITE : constant Integer := 10;
    -- Nombre maximum de matériels dans un stock

    -- Nature possible d'un matériel informatique.
    type T_Nature is (UNITE_CENTRALE, DISQUE, ECRAN, CLAVIER, IMPRIMANTE);

    -- Type Stock : limité privé (les détails sont cachés à l'utilisateur).
    -- Invariants de type T_Stock :
    --   - Taille est dans [0 .. CAPACITE]
    --   - Les cases utilisées du tableau sont les indices 1 .. Taille
    --   - Chaque matériel présent a un numéro de série unique
    --   - Annee_Achat est une année positive
    type T_Stock is limited private;

    -- Créer un stock vide.
    procedure Creer (Stock : out T_Stock) with
        Post => Nb_Materiels (Stock) = 0;

    -- Obtenir le nombre de matériels enregistrés dans le stock.
    function Nb_Materiels (Stock : in T_Stock) return Integer with
        Post => Nb_Materiels'Result >= 0 and Nb_Materiels'Result <= CAPACITE;

    -- Enregistrer un nouveau matériel dans le stock.
    procedure Enregistrer (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer;
            Nature       : in     T_Nature;
            Annee_Achat  : in     Integer
        ) with
            Pre  => Nb_Materiels (Stock) < CAPACITE,
            Post => Nb_Materiels (Stock) = Nb_Materiels (Stock)'Old + 1;

    -- Mettre à jour l'état d'un matériel du stock (bascule fonctionnel <-> hors service).
    procedure Maj_Etat (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer
        ) with
            Post => Nb_Materiels (Stock) = Nb_Materiels (Stock)'Old;

    -- Obtenir le nombre de matériels hors d'état de fonctionnement dans le stock.
    function Nb_Hors_Service (Stock : in T_Stock) return Integer with
        Post => Nb_Hors_Service'Result >= 0 and Nb_Hors_Service'Result <= Nb_Materiels (Stock);

    -- Supprimer un matériel du stock à partir de son numéro de série.
    procedure Supprimer (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer
        ) with
            Post => Nb_Materiels (Stock) = Nb_Materiels (Stock)'Old - 1;

    -- Afficher tous les matériels du stock dans le terminal.
    procedure Afficher (Stock : in T_Stock);

    -- Supprimer tous les matériels hors d'état de fonctionnement du stock.
    procedure Purger_Hors_Service (Stock : in out T_Stock) with
        Post => Nb_Hors_Service (Stock) = 0;

private

    -- Un matériel informatique.
    type T_Materiel is record
        Numero_Serie : Integer;
        Nature       : T_Nature;
        Annee_Achat  : Integer;
        Fonctionnel  : Boolean; -- True = en état de fonctionnement
    end record;

    -- Tableau interne du stock.
    type T_Tableau is array (1 .. CAPACITE) of T_Materiel;

    -- Le stock lui-même.
    type T_Stock is record
        Tableau : T_Tableau;
        Taille  : Integer := 0;
    end record;

end Stocks_Materiel;