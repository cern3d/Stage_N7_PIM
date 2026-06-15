-- Spécification du module Stocks_Materiel
-- Gestion d'un stock de matériel informatique représenté par un tableau

package Stocks_Materiel is

   -- =========================================================
   -- Types
   -- =========================================================

   -- Nature possible d'un matériel informatique
   type Nature_Materiel is (Unite_Centrale, Disque, Ecran, Clavier, Imprimante);

   -- Numéro de série (entier, mais prévu pour évoluer vers String)
   subtype Numero_Serie is Integer;

   -- Année d'achat
   subtype Annee is Integer range 1900 .. 2100;

   -- Capacité maximale du stock
   Capacite_Max : constant := 100;

   -- Type représentant un matériel informatique
   -- Invariant : Numero > 0, Annee_Achat dans [1900..2100]
   type Materiel is record
      Numero      : Numero_Serie;
      Nature      : Nature_Materiel;
      Annee_Achat : Annee;
      Fonctionnel : Boolean;
   end record;

   -- Tableau interne du stock
   type Tableau_Materiels is array (1 .. Capacite_Max) of Materiel;

   -- Type Stock
   -- Invariant :
   --   * Nb_Materiels dans [0 .. Capacite_Max]
   --   * Les entrées d'indice 1 .. Nb_Materiels sont valides
   --   * Tous les numéros de série sont distincts
   type Stock is record
      Materiels    : Tableau_Materiels;
      Nb_Materiels : Natural range 0 .. Capacite_Max;
   end record;

   -- =========================================================
   -- Opérations
   -- =========================================================

   -- Initialise le stock (doit être appelé avant toute utilisation)
   -- Post : Nb_Materiels = 0
   procedure Creer (S : out Stock);

   -- Retourne le nombre de matériels enregistrés dans le stock
   -- Pre  : S a été créé
   -- Post : résultat = S.Nb_Materiels
   function Nombre_Materiels (S : in Stock) return Natural;

   -- Enregistre un nouveau matériel dans le stock
   -- Pre  : Nombre_Materiels(S) < Capacite_Max
   --        Aucun matériel avec ce Numero n'existe déjà dans S
   -- Post : Nombre_Materiels(S) = Nombre_Materiels(S)' + 1
   --        Le nouveau matériel est fonctionnel
   procedure Enregistrer (S           : in out Stock;
                          Numero      : in     Numero_Serie;
                          Nature      : in     Nature_Materiel;
                          Annee_Achat : in     Annee);

   -- Met à jour l'état (fonctionnel <-> hors service) d'un matériel
   -- Pre  : Il existe un matériel avec ce Numero dans S
   -- Post : Le matériel correspondant a son état inversé
   procedure Mettre_A_Jour_Etat (S      : in out Stock;
                                  Numero : in     Numero_Serie);

   -- Retourne le nombre de matériels hors d'état de fonctionnement
   -- Pre  : S a été créé
   function Nombre_Hors_Service (S : in Stock) return Natural;

   -- Supprime un matériel du stock à partir de son numéro de série
   -- Pre  : Il existe un matériel avec ce Numero dans S
   -- Post : Nombre_Materiels(S) = Nombre_Materiels(S)' - 1
   procedure Supprimer (S      : in out Stock;
                        Numero : in     Numero_Serie);

   -- Affiche tous les matériels du stock dans le terminal
   -- Pre  : S a été créé
   procedure Afficher (S : in Stock);

   -- Supprime tous les matériels hors d'état de fonctionnement
   -- Pre  : S a été créé
   -- Post : Tous les matériels restants sont fonctionnels
   procedure Supprimer_Hors_Service (S : in out Stock);

end Stocks_Materiel;