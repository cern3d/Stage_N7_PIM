with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with Types_Definitions; use Types_Definitions;

package Pack_Cache_Liste is

   type T_Cache is private;

   ----------------------------------------------------------------------------
   -- FONCTIONS DE CONSULTATION POUR LES CONTRATS
   ----------------------------------------------------------------------------
   function Obtenir_Taille (Cache : in T_Cache) return Natural;
   function Obtenir_Capacite (Cache : in T_Cache) return Natural;
   function Obtenir_Politique (Cache : in T_Cache) return T_Politique;

   ----------------------------------------------------------------------------
   -- PROCEDURES DU CACHE EN LISTE
   ----------------------------------------------------------------------------

   -- Initialiser le cache avec sa capacité maximale et sa politique de remplacement.
   --
   -- Paramètres
   --     Cache     : le cache en liste à initialiser
   --     Capacite  : le nombre maximal de lignes autorisées dans le cache
   --     Politique : la politique de gestion (FIFO, LRU, LFU)
   --
   -- Assure
   --     Obtenir_Taille (Cache) = 0 and
   --     Obtenir_Capacite (Cache) = Capacite and
   --     Obtenir_Politique (Cache) = Politique
   --
   procedure Initialiser (Cache : out T_Cache; Capacite : in Natural; Politique : in T_Politique) with
       Post => Obtenir_Taille (Cache) = 0 and
               Obtenir_Capacite (Cache) = Capacite and
               Obtenir_Politique (Cache) = Politique;

   -- Chercher une correspondance exacte d'IP dans le cache.
   -- Modifie potentiellement l'état interne selon la politique (ex: LRU/LFU).
   --
   -- Paramètres
   --     Cache       : le cache dans lequel chercher
   --     IP          : l'adresse IP à rechercher
   --     Interface_R : l'interface réseau associée si elle est trouvée
   --     Trouve      : vrai si une correspondance exacte existe, faux sinon
   --
   -- Assure
   --     Obtenir_Taille (Cache) = Obtenir_Taille (Cache)'Old and
   --     Obtenir_Capacite (Cache) = Obtenir_Capacite (Cache)'Old
   --
   procedure Chercher (
      Cache       : in out T_Cache;
      IP          : in T_Adresse_IP;
      Interface_R : out Unbounded_String;
      Trouve      : out Boolean
   ) with
       Post => Obtenir_Taille (Cache) = Obtenir_Taille (Cache)'Old and
               Obtenir_Capacite (Cache) = Obtenir_Capacite (Cache)'Old;

   -- Enregistrer une nouvelle route apprise dans le cache (gère l'éjection si plein).
   --
   -- Paramètres
   --     Cache       : le cache où enregistrer la route
   --     Destination : l'adresse IP réseau cible de la route
   --     Masque      : le masque de sous-réseau
   --     Interface_R : l'interface réseau correspondante
   --
   -- Assure
   --     Obtenir_Taille (Cache) <= Obtenir_Capacite (Cache)
   --
   procedure Enregistrer (
      Cache       : in out T_Cache;
      Destination : in T_Adresse_IP;
      Masque      : in T_Adresse_IP;
      Interface_R : in Unbounded_String
   ) with
       Post => Obtenir_Taille (Cache) <= Obtenir_Capacite (Cache);

   -- Libérer l'intégralité de la mémoire occupée par les cellules du cache.
   --
   -- Paramètres
   --     Cache : le cache à vider
   --
   -- Assure
   --     Obtenir_Taille (Cache) = 0
   --
   procedure Vider (Cache : in out T_Cache) with
       Post => Obtenir_Taille (Cache) = 0;

   -- Afficher le contenu actuel du cache sur la sortie standard.
   --
   -- Paramètres
   --     Cache : le cache à afficher
   --
   procedure Afficher_Cache (Cache : in T_Cache);

private

   type T_Cellule_Cache;
   type T_Lien_Cache is access T_Cellule_Cache;

   type T_Cellule_Cache is record
      Destination : T_Adresse_IP;
      Masque      : T_Adresse_IP;
      Interface_R : Unbounded_String;
      Frequence   : Natural := 1; 
      Suivant     : T_Lien_Cache;
   end record;

   type T_Cache is record
      Tete      : T_Lien_Cache := null;
      Taille    : Natural := 0;
      Capacite  : Natural := 10;
      Politique : T_Politique := FIFO;
   end record;

   -- Implémentation des fonctions expressions pour les contrats du cache
   function Obtenir_Taille (Cache : in T_Cache) return Natural is (Cache.Taille);
   function Obtenir_Capacite (Cache : in T_Cache) return Natural is (Cache.Capacite);
   function Obtenir_Politique (Cache : in T_Cache) return T_Politique is (Cache.Politique);

end Pack_Cache_Liste;