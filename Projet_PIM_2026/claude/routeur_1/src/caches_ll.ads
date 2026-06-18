-- Caches_LL : TAD cache de routes, représenté par une liste chaînée.
--
-- Politiques de remplacement :
--   FIFO : expulse l'entrée la plus anciennement insérée
--   LRU  : expulse l'entrée la moins récemment utilisée (lue ou insérée)
--   LFU  : expulse l'entrée la moins fréquemment utilisée
--
-- Cohérence du cache (§1.4.2) :
--   La route stockée dans le cache utilise un masque discriminant
--   (le plus long masque de la table qui ne correspond pas à Dest),
--   de sorte qu'une entrée du cache ne puisse jamais masquer une route
--   plus spécifique de la table.

with Adresses_IP;    use Adresses_IP;
with Tables_Routage; use Tables_Routage;
with Parametres;     use Parametres;

package Caches_LL is

   -- Statistiques du cache
   type T_Stats is record
      Nb_Demandes  : Natural := 0;
      Nb_Hits      : Natural := 0;
      Nb_Defauts   : Natural := 0;
      Nb_Evictions : Natural := 0;
   end record;

   -- Type opaque
   type T_Cache is limited private;

   -- Initialiser un cache vide
   -- Précondition : Taille_Max >= 0
   procedure Initialiser (Cache      : out T_Cache;
                          Taille_Max :     Natural;
                          Pol        :     T_Politique);

   -- Libérer la mémoire
   procedure Finaliser (Cache : in out T_Cache);

   -- Chercher une route dans le cache.
   -- Met à jour les compteurs (LRU/LFU) si trouvée.
   -- Postcondition : Stats.Nb_Demandes est incrémenté.
   function Chercher (Cache       : in out T_Cache;
                      Destination :        T_Adresse_IP;
                      Route       :    out T_Route) return Boolean;

   -- Construire et insérer la route correcte dans le cache (§1.4.2).
   -- Table     : table complète pour calculer le masque discriminant
   -- Dest_Orig : adresse du paquet original
   -- Route_Ok  : route retournée par la table (LPM)
   -- Si Taille_Max = 0, ne rien faire.
   procedure Inserer (Cache     : in out T_Cache;
                      Table     :        T_Table;
                      Dest_Orig :        T_Adresse_IP;
                      Route_Ok  :        T_Route);

   -- Afficher le contenu du cache (commande "cache")
   procedure Afficher (Cache : T_Cache);

   -- Retourner les statistiques
   function Statistiques (Cache : T_Cache) return T_Stats;

   -- Afficher les statistiques (commande "stat")
   procedure Afficher_Stats (Cache : T_Cache);

private

   type T_Cellule_Cache;
   type T_Ptr_Cache is access T_Cellule_Cache;

   type T_Cellule_Cache is record
      Route           : T_Route;
      Seq_Insertion   : Natural    := 0;  -- pour FIFO
      Seq_Dernier     : Natural    := 0;  -- pour LRU
      Nb_Utilisations : Natural    := 0;  -- pour LFU
      Suivant         : T_Ptr_Cache := null;
   end record;

   type T_Cache is limited record
      Tete        : T_Ptr_Cache := null;
      Nb_Entrees  : Natural     := 0;
      Taille_Max  : Natural     := 0;
      Pol         : T_Politique := FIFO;
      Seq_Global  : Natural     := 0;
      Stats       : T_Stats;
   end record;

end Caches_LL;
