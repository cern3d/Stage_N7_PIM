with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

-- Auteur: 
-- Gérer un stock de matériel informatique.
--
package body Stocks_Materiel is

    procedure Creer (Stock : out T_Stock) is
    begin
        Stock.Nb := 0;
    end Creer;

    function Nb_Materiels (Stock: in T_Stock) return Integer is
    begin
        return Stock.Nb;
    end Nb_Materiels;

    procedure Enregistrer (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer;
            Nature       : in     T_Nature;
            Annee_Achat  : in     Integer
        ) is
    begin
        Stock.Nb := Stock.Nb + 1;
        Stock.Donnees (Stock.Nb) := (
            Numero_Serie => Numero_Serie,
            Nature       => Nature,
            Annee_Achat  => Annee_Achat,
            Etat         => EN_FONCTIONNEMENT
        );
    end Enregistrer;

    function Rechercher_Indice (
            Stock        : in T_Stock;
            Numero_Serie : in Integer
        ) return Integer is
        Indice : Integer := 0;
    begin
        for I in 1 .. Stock.Nb loop
            if Stock.Donnees (I).Numero_Serie = Numero_Serie then
                Indice := I;
                exit;
            end if;
        end loop;
        return Indice;
    end Rechercher_Indice;

    function Mettre_A_Jour_Etat (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer;
            Nouveau_Etat : in     T_Etat
        ) return Boolean is
        Indice : Integer := Rechercher_Indice (Stock, Numero_Serie);
    begin
        if Indice /= 0 then
            Stock.Donnees (Indice).Etat := Nouveau_Etat;
            return True;
        else
            return False;
        end if;
    end Mettre_A_Jour_Etat;

    function Nb_Hors_Fonctionnement (Stock : in T_Stock) return Integer is
        Compteur : Integer := 0;
    begin
        for I in 1 .. Stock.Nb loop
            if Stock.Donnees (I).Etat = HORS_FONCTIONNEMENT then
                Compteur := Compteur + 1;
            end if;
        end loop;
        return Compteur;
    end Nb_Hors_Fonctionnement;

    function Supprimer (
            Stock        : in out T_Stock;
            Numero_Serie : in     Integer
        ) return Boolean is
        Indice : Integer := Rechercher_Indice (Stock, Numero_Serie);
    begin
        if Indice = 0 then
            return False;
        end if;
        for J in Indice .. Stock.Nb - 1 loop
            Stock.Donnees (J) := Stock.Donnees (J + 1);
        end loop;
        Stock.Nb := Stock.Nb - 1;
        return True;
    end Supprimer;

    procedure Afficher (Stock : in T_Stock) is
        procedure Afficher_Nature (Nature : in T_Nature) is
        begin
            case Nature is
                when UNITE_CENTRALE    => Put ("Unite centrale");
                when DISQUE            => Put ("Disque");
                when ECRAN             => Put ("Ecran");
                when CLAVIER           => Put ("Clavier");
                when IMPRIMANTE        => Put ("Imprimante");
            end case;
        end Afficher_Nature;

        procedure Afficher_Etat (Etat : in T_Etat) is
        begin
            case Etat is
                when EN_FONCTIONNEMENT       => Put ("En fonctionnement");
                when HORS_FONCTIONNEMENT     => Put ("Hors fonctionnement");
            end case;
        end Afficher_Etat;
    begin
        if Stock.Nb = 0 then
            Put_Line ("Stock vide.");
            return;
        end if;

        for I in 1 .. Stock.Nb loop
            Put ("Numero de serie : ");
            Put (Stock.Donnees (I).Numero_Serie, Width => 0);
            New_Line;
            Put ("Nature           : ");
            Afficher_Nature (Stock.Donnees (I).Nature);
            New_Line;
            Put ("Annee d'achat    : ");
            Put (Stock.Donnees (I).Annee_Achat, Width => 0);
            New_Line;
            Put ("Etat             : ");
            Afficher_Etat (Stock.Donnees (I).Etat);
            New_Line;
            Put_Line ("-------------------------------");
        end loop;
    end Afficher;

    procedure Supprimer_Hors_Fonctionnement (Stock : in out T_Stock) is
        J : Integer := 0;
    begin
        for I in 1 .. Stock.Nb loop
            if Stock.Donnees (I).Etat = EN_FONCTIONNEMENT then
                J := J + 1;
                Stock.Donnees (J) := Stock.Donnees (I);
            end if;
        end loop;
        Stock.Nb := J;
    end Supprimer_Hors_Fonctionnement;

end Stocks_Materiel;
