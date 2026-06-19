with Types_Definitions; use Types_Definitions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Pack_Cache_Arbre is

   type T_Cache is limited private;

   ----------------------------------------------------------------------------
   -- FONCTIONS DE CONSULTATION POUR LES CONTRATS
   ----------------------------------------------------------------------------
   function Obtenir_Taille (Cache : in T_Cache) return Integer;
   function Obtenir_Taille_Max (Cache : in T_Cache) return Integer;
   function Obtenir_Politique (Cache : in T_Cache) return T_Politique;

   ----------------------------------------------------------------------------
   -- PROCEDURES DU CACHE EN ARBRE (TRIE)
   ----------------------------------------------------------------------------

   -- Initialiser le cache en arbre avec sa taille maximale et sa politique.
   --
   -- Paramètres
   --     Cache      : le cache en arbre à initialiser
   --     Taille_Max : le nombre maximum de nœuds routes autorisés
   --     Politique  : la politique de remplacement (FIFO, LRU, LFU)
   --
   -- Assure
   --     Obtenir_Taille (Cache) = 0 and
   --     Obtenir_Taille_Max (Cache) = Taille_Max and
   --     Obtenir_Politique (Cache) = Politique
   --
   procedure Initialiser (Cache      : out T_Cache; 
                          Taille_Max : in Integer; 
                          Politique  : in T_Politique) with
       Post => Obtenir_Taille (Cache) = 0 and
               Obtenir_Taille_Max (Cache) = Taille_Max and
               Obtenir_Politique (Cache) = Politique;

   -- Chercher une IP dans le cache en arbre (recherche du plus long préfixe correspondant).
   --
   -- Paramètres
   --     Cache   : le cache en arbre à interroger
   --     IP_Dest : l'adresse IP recherchée
   --     Interf  : l'interface réseau de sortie si trouvée
   --     Trouve  : vrai si l'IP correspond à une route présente dans l'arbre, faux sinon
   --
   -- Assure
   --     Obtenir_Taille (Cache) = Obtenir_Taille (Cache)'Old and
   --     Obtenir_Taille_Max (Cache) = Obtenir_Taille_Max (Cache)'Old
   --
   procedure Chercher_Cache (Cache   : in out T_Cache; 
                             IP_Dest : in T_Adresse_IP; 
                             Interf  : out Unbounded_String;
                             Trouve  : out Boolean) with
       Post => Obtenir_Taille (Cache) = Obtenir_Taille (Cache)'Old and
               Obtenir_Taille_Max (Cache) = Obtenir_Taille_Max (Cache)'Old;

   -- Ajouter une route dans l'arbre à la profondeur correspondant à son masque (gère l'éjection).
   --
   -- Paramètres
   --     Cache : le cache en arbre
   --     Route : le record de la route à insérer (contenant les métadonnées)
   --
   -- Assure
   --     Obtenir_Taille (Cache) <= Obtenir_Taille_Max (Cache)
   --
   procedure Ajouter_Cache (Cache : in out T_Cache; Route : in T_Route_Cache) with
       Post => Obtenir_Taille (Cache) <= Obtenir_Taille_Max (Cache);

   -- Afficher le contenu du cache en réalisant un parcours complet de l'arbre.
   --
   -- Paramètres
   --     Cache : le cache en arbre à afficher
   --
   procedure Afficher_Cache (Cache : in T_Cache);

   -- Libérer récursivement toute la mémoire allouée pour les nœuds de l'arbre.
   --
   -- Paramètres
   --     Cache : le cache en arbre à vider
   --
   -- Assure
   --     Obtenir_Taille (Cache) = 0
   --
   procedure Vider (Cache : in out T_Cache) with
       Post => Obtenir_Taille (Cache) = 0;

private

   type T_Noeud;
   type T_Arbre is access T_Noeud;
   
   type T_Noeud is record
      Est_Route   : Boolean := False; -- Vrai si ce nœud contient une route valide
      Route       : T_Route_Cache;
      Fils_Gauche : T_Arbre := null;  -- Branche pour le bit 0
      Fils_Droit  : T_Arbre := null;  -- Branche pour le bit 1
   end record;

   type T_Cache is record
      Racine     : T_Arbre := null;
      Taille_Max : Integer := 10;
      Taille_Act : Integer := 0;
      Politique  : T_Politique := FIFO;
      Compteur   : Natural := 0; -- Horloge globale pour les politiques d'éviction
   end record;

   -- Implémentation des fonctions expressions pour les contrats de l'arbre
   function Obtenir_Taille (Cache : in T_Cache) return Integer is (Cache.Taille_Act);
   function Obtenir_Taille_Max (Cache : in T_Cache) return Integer is (Cache.Taille_Max);
   function Obtenir_Politique (Cache : in T_Cache) return T_Politique is (Cache.Politique);

end Pack_Cache_Arbre;