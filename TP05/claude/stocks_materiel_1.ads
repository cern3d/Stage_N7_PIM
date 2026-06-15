-- Auteur: 
-- Gérer un stock de matériel informatique.

package Stocks_Materiel is

    CAPACITE : constant Integer := 10;  -- nombre maximum de matériels dans un stock

    -- Nature possible d'un matériel informatique.
    type T_Nature is (UNITE_CENTRALE, DISQUE, ECRAN, CLAVIER, IMPRIMANTE);

    -- Type Stock : limité privé (les détails sont cachés à l'utilisateur).
    --
    -- Invariants de type T_Stock :
    --   - Taille est dans [0 .. CAPACITE]
    --   - Les cases utilisées du tableau sont les indices 1 .. Taille
    --   - Chaque matériel présent a un numéro de série unique
    --   - Annee_Achat est une année positive
    type T_Stock is limited private;


    -- -----------------------------------------------------------------------
    -- Créer un stock vide.
    --
    -- Paramètres
    --     Stock : le stock à créer (out)
    --
    -- Nécessite
    --     Vrai
    --
    -- Assure
    --     Nb_Materiels (Stock) = 0
    -- -----------------------------------------------------------------------
    procedure Creer (Stock : out T_Stock) with
        Post => Nb_Materiels (Stock) = 0;


    -- -----------------------------------------------------------------------
    -- Obtenir le nombre de matériels enregistrés dans le stock.
    --
    -- Paramètres
    --     Stock : le stock interrogé (in)
    --
    -- Nécessite
    --     Vrai
    --
    -- Assure
    --     Résultat >= 0  Et  Résultat <= CAPACITE
    -- -----------------------------------------------------------------------
    function Nb_Materiels (Stock : in T_Stock) return Integer with
        Post => Nb_Materiels'Result >= 0 and Nb_Materiels'Result <= CAPACITE;


    -- -----------------------------------------------------------------------
    -- Enregistrer un nouveau matériel dans le stock.
    -- Le nouveau matériel est supposé en état de fonctionnement.
    -- Le stock ne doit pas être plein.
    --
    -- Paramètres
    --     Stock        : le stock à compléter (in out)
    --     Numero_Serie : numéro de série du nouveau matériel (in)
    --     Nature       : nature du nouveau matériel (in)
    --     Annee_Achat  : année d'achat du nouveau matériel (in)
    --
    -- Nécessite
    --     Nb_Materiels (Stock) < CAPACITE
    --
    -- Assure
    --     Nb_Materiels (Stock) = Nb_Materiels (Stock)'Avant + 1
    --     Le nouveau matériel est en état de fonctionnement
    -- -----------------------------------------------------------------------
    procedure Enregistrer (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer;
            Nature       : in     T_Nature;
            Annee_Achat  : in     Integer
        ) with
            Pre  => Nb_Materiels (Stock) < CAPACITE,
            Post => Nb_Materiels (Stock) = Nb_Materiels (Stock)'Old + 1;


    -- -----------------------------------------------------------------------
    -- Mettre à jour l'état d'un matériel du stock (bascule fonctionnel <-> hors service).
    -- Le matériel identifié par Numero_Serie doit exister dans le stock.
    --
    -- Paramètres
    --     Stock        : le stock (in out)
    --     Numero_Serie : numéro de série du matériel à mettre à jour (in)
    --
    -- Nécessite
    --     Le matériel de numéro Numero_Serie est dans le stock
    --
    -- Assure
    --     Nb_Materiels (Stock) = Nb_Materiels (Stock)'Avant   (pas d'ajout/suppression)
    --     L'état du matériel est l'inverse de son état précédent
    -- -----------------------------------------------------------------------
    procedure Maj_Etat (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer
        ) with
            Post => Nb_Materiels (Stock) = Nb_Materiels (Stock)'Old;


    -- -----------------------------------------------------------------------
    -- Obtenir le nombre de matériels hors d'état de fonctionnement dans le stock.
    --
    -- Paramètres
    --     Stock : le stock interrogé (in)
    --
    -- Nécessite
    --     Vrai
    --
    -- Assure
    --     Résultat >= 0  Et  Résultat <= Nb_Materiels (Stock)
    -- -----------------------------------------------------------------------
    function Nb_Hors_Service (Stock : in T_Stock) return Integer with
        Post => Nb_Hors_Service'Result >= 0
            and Nb_Hors_Service'Result <= Nb_Materiels (Stock);


    -- -----------------------------------------------------------------------
    -- Supprimer un matériel du stock à partir de son numéro de série.
    -- Le matériel doit exister dans le stock.
    --
    -- Paramètres
    --     Stock        : le stock (in out)
    --     Numero_Serie : numéro de série du matériel à supprimer (in)
    --
    -- Nécessite
    --     Le matériel de numéro Numero_Serie est dans le stock
    --
    -- Assure
    --     Nb_Materiels (Stock) = Nb_Materiels (Stock)'Avant - 1
    --     Le matériel Numero_Serie n'est plus dans le stock
    -- -----------------------------------------------------------------------
    procedure Supprimer (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer
        ) with
            Post => Nb_Materiels (Stock) = Nb_Materiels (Stock)'Old - 1;


    -- -----------------------------------------------------------------------
    -- Afficher tous les matériels du stock dans le terminal.
    -- (Ce sous-programme est le seul à faire des entrées/sorties.)
    --
    -- Paramètres
    --     Stock : le stock à afficher (in)
    --
    -- Nécessite
    --     Vrai
    --
    -- Assure
    --     Tous les matériels du stock sont affichés
    --     Nb_Materiels (Stock) inchangé
    -- -----------------------------------------------------------------------
    procedure Afficher (Stock : in T_Stock);


    -- -----------------------------------------------------------------------
    -- Supprimer tous les matériels hors d'état de fonctionnement du stock.
    --
    -- Paramètres
    --     Stock : le stock (in out)
    --
    -- Nécessite
    --     Vrai
    --
    -- Assure
    --     Nb_Hors_Service (Stock) = 0
    --     Nb_Materiels (Stock) = Nb_Materiels (Stock)'Avant - Nb_Hors_Service (Stock)'Avant
    -- -----------------------------------------------------------------------
    procedure Purger_Hors_Service (Stock : in out T_Stock) with
        Post => Nb_Hors_Service (Stock) = 0;


private

    -- Un matériel informatique.
    --
    -- Invariants de type T_Materiel :
    --   - Numero_Serie > 0
    --   - Annee_Achat  > 0
    type T_Materiel is record
        Numero_Serie : Integer;
        Nature       : T_Nature;
        Annee_Achat  : Integer;
        Fonctionnel  : Boolean;   -- True = en état de fonctionnement
    end record;

    -- Tableau interne du stock.
    -- Seules les cases d'indices 1 .. Taille sont utilisées.
    type T_Tableau is array (1 .. CAPACITE) of T_Materiel;

    -- Le stock lui-même.
    --
    -- Invariants de type T_Stock :
    --   - 0 <= Taille <= CAPACITE
    --   - Les matériels valides occupent les cases Tableau (1 .. Taille)
    --   - Tous les numéros de série des matériels de Tableau (1 .. Taille) sont distincts
    type T_Stock is record
        Tableau : T_Tableau;
        Taille  : Integer := 0;
    end record;

end Stocks_Materiel;