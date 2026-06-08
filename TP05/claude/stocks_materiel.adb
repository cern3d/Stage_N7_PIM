with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

-- Auteur: 
-- Gérer un stock de matériel informatique.

package body Stocks_Materiel is

    -- -----------------------------------------------------------------------
    -- Retourne l'indice dans Tableau du matériel dont le numéro de série est
    -- Numero_Serie, ou 0 si ce matériel n'existe pas dans le stock.
    -- Sous-programme interne (non visible depuis la spécification).
    -- -----------------------------------------------------------------------
    function Indice_De (Stock : in T_Stock; Numero_Serie : in Integer)
        return Integer
    is
        Indice : Integer := 0;
    begin
        for I in 1 .. Stock.Taille loop
            if Stock.Tableau (I).Numero_Serie = Numero_Serie then
                Indice := I;
            end if;
        end loop;
        return Indice;
    end Indice_De;


    -- -----------------------------------------------------------------------
    procedure Creer (Stock : out T_Stock) is
    begin
        -- Il suffit de mettre Taille à 0 ; le contenu du tableau n'a pas
        -- d'importance puisque seules les cases 1..Taille sont valides.
        Stock.Taille := 0;
    end Creer;


    -- -----------------------------------------------------------------------
    function Nb_Materiels (Stock : in T_Stock) return Integer is
    begin
        return Stock.Taille;
    end Nb_Materiels;


    -- -----------------------------------------------------------------------
    procedure Enregistrer (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer;
            Nature       : in     T_Nature;
            Annee_Achat  : in     Integer
        ) is
        Nouveau : T_Materiel;
    begin
        -- Construire le nouvel enregistrement (fonctionnel par définition)
        Nouveau.Numero_Serie := Numero_Serie;
        Nouveau.Nature       := Nature;
        Nouveau.Annee_Achat  := Annee_Achat;
        Nouveau.Fonctionnel  := True;

        -- Ajouter en fin de tableau et incrémenter la taille
        Stock.Taille               := Stock.Taille + 1;
        Stock.Tableau (Stock.Taille) := Nouveau;
    end Enregistrer;


    -- -----------------------------------------------------------------------
    procedure Maj_Etat (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer
        ) is
        I : Integer;
    begin
        I := Indice_De (Stock, Numero_Serie);
        -- Précondition implicite : I /= 0 (le matériel existe)
        Stock.Tableau (I).Fonctionnel := not Stock.Tableau (I).Fonctionnel;
    end Maj_Etat;


    -- -----------------------------------------------------------------------
    function Nb_Hors_Service (Stock : in T_Stock) return Integer is
        Compteur : Integer := 0;
    begin
        for I in 1 .. Stock.Taille loop
            if not Stock.Tableau (I).Fonctionnel then
                Compteur := Compteur + 1;
            end if;
        end loop;
        return Compteur;
    end Nb_Hors_Service;


    -- -----------------------------------------------------------------------
    procedure Supprimer (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer
        ) is
        I : Integer;
    begin
        I := Indice_De (Stock, Numero_Serie);
        -- Précondition implicite : I /= 0

        -- Décaler toutes les cases après I d'un rang vers la gauche
        for J in I .. Stock.Taille - 1 loop
            Stock.Tableau (J) := Stock.Tableau (J + 1);
        end loop;

        Stock.Taille := Stock.Taille - 1;
    end Supprimer;


    -- -----------------------------------------------------------------------
    procedure Afficher (Stock : in T_Stock) is
    begin
        Put_Line ("=== Stock (" & Integer'Image (Stock.Taille)
                    & " matériel(s)) ===");
        for I in 1 .. Stock.Taille loop
            declare
                M : T_Materiel renames Stock.Tableau (I);
            begin
                Put ("  [");
                Put (M.Numero_Serie, Width => 0);
                Put ("] ");
                Put (T_Nature'Image (M.Nature));
                Put ("  Achat : ");
                Put (M.Annee_Achat, Width => 0);
                if M.Fonctionnel then
                    Put_Line ("  Etat : OK");
                else
                    Put_Line ("  Etat : HORS SERVICE");
                end if;
            end;
        end loop;
        Put_Line ("==============================");
    end Afficher;


    -- -----------------------------------------------------------------------
    procedure Purger_Hors_Service (Stock : in out T_Stock) is
        I : Integer := 1;
    begin
        -- Parcours avec index variable : on n'avance que si on n'a pas supprimé
        while I <= Stock.Taille loop
            if not Stock.Tableau (I).Fonctionnel then
                -- Décaler les cases suivantes d'un rang vers la gauche
                for J in I .. Stock.Taille - 1 loop
                    Stock.Tableau (J) := Stock.Tableau (J + 1);
                end loop;
                Stock.Taille := Stock.Taille - 1;
                -- Ne pas incrémenter I : la case I contient maintenant
                -- l'ancien élément I+1 qui doit encore être testé
            else
                I := I + 1;
            end if;
        end loop;
    end Purger_Hors_Service;


end Stocks_Materiel;