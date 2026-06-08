
-- Auteur: 
-- Gérer un stock de matériel informatique.

package Stocks_Materiel is

    CAPACITE : constant Integer := 10;      -- nombre maximum de matériels dans un stock

    type T_Nature is (UNITE_CENTRALE, DISQUE, ECRAN, CLAVIER, IMPRIMANTE);
    type T_Etat is (EN_FONCTIONNEMENT, HORS_FONCTIONNEMENT);

    type T_Stock is limited private;

    -- Créer un stock vide.
    --
    -- paramètres
    --     Stock : le stock à créer
    --
    -- Assure
    --     Nb_Materiels (Stock) = 0
    --
    procedure Creer (Stock : out T_Stock) with
        Post => Nb_Materiels (Stock) = 0;

    -- Obtenir le nombre de matériels dans le stock Stock.
    --
    -- Paramètres
    --    Stock : le stock dont ont veut obtenir la taille
    --
    -- Nécessite
    --     Vrai
    --
    -- Assure
    --     Résultat >= 0 Et Résultat <= CAPACITE
    --
    function Nb_Materiels (Stock: in T_Stock) return Integer with
        Post => Nb_Materiels'Result >= 0 and Nb_Materiels'Result <= CAPACITE;

    -- Enregistrer un nouveau matériel dans le stock.
    -- Il est initialement en fonctionnement.
    --
    -- Paramètres
    --    Stock : le stock à compléter
    --    Numero_Serie : le numéro de série du nouveau matériel
    --    Nature       : la nature du nouveau matériel
    --    Annee_Achat  : l'année d'achat du nouveau matériel
    --
    -- Nécessite
    --    Nb_Materiels (Stock) < CAPACITE
    --
    -- Assure
    --    Nouveau matériel ajouté
    --    Nb_Materiels (Stock) = Nb_Materiels (Stock)'Avant + 1
    procedure Enregistrer (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer;
            Nature       : in     T_Nature;
            Annee_Achat  : in     Integer
        ) with
            Pre => Nb_Materiels (Stock) < CAPACITE,
            Post => Nb_Materiels (Stock) = Nb_Materiels (Stock)'Old + 1;

    -- Mettre à jour l'état d'un matériel identifié par son numéro de série.
    -- Retourne True si le matériel est trouvé.
    function Mettre_A_Jour_Etat (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer;
            Nouveau_Etat : in     T_Etat
        ) return Boolean;

    -- Obtenir le nombre de matériels hors d'état de fonctionnement.
    function Nb_Hors_Fonctionnement (Stock : in T_Stock) return Integer;

    -- Supprimer du stock un matériel identifié par son numéro de série.
    -- Retourne True si le matériel a été retiré.
    function Supprimer (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer
        ) return Boolean;

    -- Afficher le contenu du stock dans le terminal.
    procedure Afficher (Stock : in T_Stock);

    -- Supprimer tous les matériels hors d'état de fonctionnement.
    procedure Supprimer_Hors_Fonctionnement (Stock : in out T_Stock)
        with Post => Nb_Materiels (Stock) <= Nb_Materiels (Stock)'Old;

private

    type T_Materiel is record
        Numero_Serie : Integer;
        Nature       : T_Nature;
        Annee_Achat  : Integer;
        Etat         : T_Etat;
    end record;

    type T_Tableau_Materiels is array (1 .. CAPACITE) of T_Materiel;

    type T_Stock is limited record
        Donnees : T_Tableau_Materiels;
        Nb      : Integer := 0;
    end record;

end Stocks_Materiel;
