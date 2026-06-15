package Stocks_Materiel is

   -- Définition des types pour les caractéristiques du matériel
   type Nature_Materiel is (Unite_Centrale, Disque, Ecran, Clavier, Imprimante);
   
   subtype Annee is Positive;
   
   -- Le numéro de série est un entier (évolutif vers String plus tard)
   subtype Numero_Serie_Type is Positive;

   type Materiel is record
      Numero_Serie : Numero_Serie_Type;
      Nature       : Nature_Materiel;
      Annee_Achat  : Annee;
      En_Fonction  : Boolean;
   end record;

   -- Gestion du stock (Tableau de taille maximale fixe)
   Capacite_Max : constant Positive := 100;
   type Tab_Materiels is array (1 .. Capacite_Max) of Materiel;

   -- Structure du Stock (Invariants implicites : 0 <= Taille <= Capacite_Max)
   type Stock is record
      Elements : Tab_Materiels;
      Taille   : Natural := 0;
   end record;

   ----------------------------------------------------------------------------
   -- Opérations demandées
   ----------------------------------------------------------------------------

   -- Initialise le stock (Obligatoire avant utilisation)
   procedure Creer_Stock (S : out Stock);

   -- 2. Obtenir le nombre de matériels enregistrés
   function Nombre_Materiels (S : in Stock) return Natural;

   -- 1. Enregistrer un nouveau matériel (supposé en état de marche au départ)
   procedure Enregistrer_Materiel (
      S            : in out Stock;
      Num_Serie    : in Numero_Serie_Type;
      Nat          : in Nature_Materiel;
      Annee_Achat  : in Annee)
   with 
     Pre => Nombre_Materiels(S) < Capacite_Max,
     Post => Nombre_Materiels(S) = Nombre_Materiels(S)'Old + 1;

   -- 3. Mettre à jour l’état d’un matériel à partir de son numéro de série
   procedure Modifier_Etat (
      S         : in out Stock;
      Num_Serie : in Numero_Serie_Type;
      En_Marche : in Boolean);

   -- 4. Obtenir le nombre de matériels hors d'état de fonctionnement
   function Nombre_Hors_Service (S : in Stock) return Natural;

   -- 5. Supprimer du stock un matériel par son numéro de série
   procedure Supprimer_Materiel (
      S         : in out Stock;
      Num_Serie : in Numero_Serie_Type);

   -- 6. Afficher tous les matériels du stock (Le seul sous-programme avec E/S)
   procedure Afficher_Stock (S : in Stock);

   -- 7. Supprimer tous les matériels HS
   procedure Supprimer_Tous_HS (S : in out Stock);

end Stocks_Materiel;