with Ada.Strings.Unbounded; use Ada.Strings.Unbounded; 
with Ada.Text_IO; use Ada.Text_IO;
with Types_Definitions; use Types_Definitions;

package Pack_Cache_Liste is

   type T_Cache is private;

   ----------------------------------------------------------------------------
   -- FONCTIONS ET PROCEDURES DU CACHE EN LISTE
   ----------------------------------------------------------------------------

   -- Rôle : Prépare le cache en enregistrant sa capacité maximale et sa politique. [cite: 26]
   -- Paramètres     : Capacite  -> Nombre maximal de lignes autorisées dans le cache.
   --                  Politique -> FIFO, LRU ou LFU.
   procedure Initialiser (Cache : out T_Cache; Capacite : in Natural; Politique : in T_Politique);

   -- Rôle : Recherche une correspondance exacte d'IP dans le cache. [cite: 27]
   -- Paramètres     : Cache (in out) -> Mis à jour selon la politique (Ex: LRU monte la cellule en Tete, 
   --                                    LFU incrémente le compteur de fréquence). [cite: 27, 34]
   -- Postconditions : Trouve est Vrai si une correspondance existe, Faux sinon.
   procedure Chercher (
      Cache       : in out T_Cache; 
      IP          : in T_Adresse_IP;
      Interface_R : out Unbounded_String;
      Trouve      : out Boolean
   );

   -- Rôle : Insère une route apprise dans le cache. Gère l'éjection automatique si plein. [cite: 28]
   -- Détails        : Si Taille = Capacite, la procédure applique la politique (FIFO/LRU/LFU) 
   --                  pour supprimer l'élément idoine avant d'insérer le nouveau. [cite: 28, 36]
   procedure Enregistrer (
      Cache       : in out T_Cache;
      Destination : in T_Adresse_IP;
      Masque      : in T_Adresse_IP;
      Interface_R : in Unbounded_String
   );

   -- Rôle : Parcourt séquentiellement la liste du cache pour afficher son contenu à l'écran. [cite: 30]
   procedure Afficher_Cache (Cache : in T_Cache);

   -- Rôle : Parcourt le cache pour libérer chaque cellule de la mémoire. [cite: 29]
   procedure Vider (Cache : in out T_Cache); 

private

   type T_Cellule_Cache;
   type T_Lien_Cache is access T_Cellule_Cache;

   type T_Cellule_Cache is record 
      Destination : T_Adresse_IP;
      Masque      : T_Adresse_IP;
      Interface_R : Unbounded_String; 
      Frequence   : Natural := 1;     -- Indispensable pour stocker les occurrences en LFU [cite: 33, 34]
      Suivant     : T_Lien_Cache;
   end record;

   type T_Cache is record
      Tete      : T_Lien_Cache := null;
      Taille    : Natural := 0;
      Capacite  : Natural := 10;
      Politique : T_Politique := FIFO;
   end record;

end Pack_Cache_Liste;