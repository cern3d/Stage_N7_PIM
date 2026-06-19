with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
-- On suppose que T_Adresse_IP est défini globalement (ex: mod 2**32)
with Types_Definitions; use Types_Definitions;       -- Corrigé

package Pack_Cache_Liste is

   type T_Cache is private;

   -- Initialiser le cache avec sa capacité max et sa politique
   procedure Initialiser (Cache : out T_Cache; Capacite : in Natural; Politique : in T_Politique);

   -- Chercher une route dans le cache
   procedure Chercher (
      Cache       : in out T_Cache; -- in out car LRU/LFU modifient l'état interne (ordre/fréquence)
      IP          : in T_Adresse_IP;
      Interface_R : out Unbounded_String;
      Trouve      : out Boolean
   );

   -- Enregistrer une nouvelle route dans le cache (gère l'éjection si plein)
   procedure Enregistrer (
      Cache       : in out T_Cache;
      Destination : in T_Adresse_IP;
      Masque      : in T_Adresse_IP;
      Interface_R : in Unbounded_String
   );

   -- Libérer la mémoire du cache à la fin du programme
   procedure Vider (Cache : in out T_Cache);

private

   type T_Cellule_Cache;
   type T_Lien_Cache is access T_Cellule_Cache;

   type T_Cellule_Cache is record
      Destination : T_Adresse_IP;
      Masque      : T_Adresse_IP;
      Interface_R : Unbounded_String;
      Frequence   : Natural := 1; -- Compteur d'utilisations (essentiel pour LFU)
      Suivant     : T_Lien_Cache;
   end record;

   -- L'encapsulation (TAD) évite de manipuler directement des pointeurs nus
   type T_Cache is record
      Tete      : T_Lien_Cache := null;
      Taille    : Natural := 0;
      Capacite  : Natural := 10;
      Politique : T_Politique := FIFO;
   end record;

end Pack_Cache_Liste;