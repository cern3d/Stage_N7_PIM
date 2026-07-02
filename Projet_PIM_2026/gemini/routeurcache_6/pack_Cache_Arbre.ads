with Types_Definitions; use Types_Definitions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Pack_Cache_Arbre is

   type T_Cache is limited private;

   ----------------------------------------------------------------------------
   -- FONCTIONS ET PROCEDURES DU CACHE EN ARBRE
   ----------------------------------------------------------------------------

   -- Rôle : Initialise l'arbre de cache à vide et configure ses limites. [cite: 39]
   procedure Initialiser (Cache      : out T_Cache; 
                          Taille_Max : in Integer; 
                          Politique  : in T_Politique);

   -- Rôle : Recherche le plus long préfixe correspondant à l'IP au sein de l'arbre. [cite: 40]
   -- Paramètres     : Cache (in out) -> Le compteur interne/horloge de l'arbre est incrémenté, [cite: 51]
   --                                    et les métadonnées LRU/LFU du nœud trouvé sont mises à jour.
   procedure Chercher_Cache (Cache   : in out T_Cache; 
                             IP_Dest : in T_Adresse_IP; 
                             Interf  : out Unbounded_String;
                             Trouve  : out Boolean);

   -- Rôle : Insère un nœud de route dans l'arbre en descendant selon les bits du masque. [cite: 42]
   -- Éjection       : Si Taille_Act = Taille_Max, l'arbre effectue un parcours préalable 
   --                  pour trouver le nœud obsolète à éjecter selon la politique active. [cite: 50]
   procedure Ajouter_Cache (Cache : in out T_Cache; Route : in T_Route_Cache);

   -- Rôle : Réalise un parcours de l'arbre pour lister à l'écran toutes les routes valides. [cite: 43]
   procedure Afficher_Cache (Cache : in T_Cache);

   -- Rôle : Libère récursivement la mémoire de tous les nœuds de l'arbre (Post-fixe). [cite: 44]
   procedure Vider (Cache : in out T_Cache);

private

   type T_Noeud;
   type T_Arbre is access T_Noeud;
   
   type T_Noeud is record
      Est_Route   : Boolean := False; -- Détermine si le nœud courant est une destination finale [cite: 45, 46]
      Route       : T_Route_Cache;    -- Contient l'interface et les métadonnées de remplacement [cite: 46]
      Fils_Gauche : T_Arbre := null;  -- Branche empruntée si le bit analysé de l'IP vaut 0 [cite: 47]
      Fils_Droit  : T_Arbre := null;  -- Branche empruntée si le bit analysé de l'IP vaut 1 [cite: 47, 48]
   end record;

   type T_Cache is record
      Racine     : T_Arbre := null;
      Taille_Max : Integer := 10;
      Taille_Act : Integer := 0;
      Politique  : T_Politique := FIFO;
      Compteur   : Natural := 0;      -- Horloge ou compteur global pour dater les accès (LRU/FIFO) [cite: 51]
   end record;

end Pack_Cache_Arbre;