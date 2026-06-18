-- Caches_Trie : TAD cache de routes représenté par un arbre préfixe (trie).
--
-- Chaque nœud de l'arbre correspond à un bit de l'adresse IP (0 ou 1).
-- Une route est stockée dans le nœud correspondant au dernier bit
-- significatif de son masque (profondeur = longueur du masque).
--
-- La recherche descend l'arbre bit par bit depuis le MSB de Destination
-- et retourne la route stockée au nœud le plus profond rencontré
-- (Longest Prefix Match dans le trie).
--
-- Politiques de remplacement (FIFO/LRU/LFU) :
--   Quand le cache est plein, on parcourt toutes les feuilles (nœuds avec
--   une route stockée) pour identifier la victime, puis on la supprime.
--   Si le nœud parent n'a plus d'enfant ni de route, il est également
--   supprimé (élagage remonté).

with Adresses_IP;    use Adresses_IP;
with Tables_Routage; use Tables_Routage;
with Parametres;     use Parametres;
with Caches_LL;      use Caches_LL;   -- réutilise T_Stats

package Caches_Trie is

   -- Type opaque : arbre préfixe
   type T_Cache_Trie is limited private;

   -- Initialiser un cache vide
   -- Précondition : Taille_Max >= 0
   procedure Initialiser (Cache      : out T_Cache_Trie;
                          Taille_Max :     Natural;
                          Pol        :     T_Politique);

   -- Libérer toute la mémoire de l'arbre
   procedure Finaliser (Cache : in out T_Cache_Trie);

   -- Chercher une route pour Destination dans le trie.
   -- Descend bit par bit depuis le MSB et retourne la route la plus
   -- profonde trouvée (LPM dans le trie).
   -- Met à jour les compteurs selon la politique.
   function Chercher (Cache       : in out T_Cache_Trie;
                      Destination :        T_Adresse_IP;
                      Route       :    out T_Route) return Boolean;

   -- Insérer la route correcte dans le trie (avec masque discriminant §1.4.2).
   -- Si le cache est plein, expulser la victime selon la politique.
   procedure Inserer (Cache     : in out T_Cache_Trie;
                      Table     :        T_Table;
                      Dest_Orig :        T_Adresse_IP;
                      Route_Ok  :        T_Route);

   -- Afficher toutes les routes du cache (parcours en ordre)
   procedure Afficher (Cache : T_Cache_Trie);

   -- Retourner les statistiques
   function Statistiques (Cache : T_Cache_Trie) return T_Stats;

   -- Afficher les statistiques
   procedure Afficher_Stats (Cache : T_Cache_Trie);

private

   type T_Noeud;
   type T_Ptr_Noeud is access T_Noeud;
   type T_Fils is array (0 .. 1) of T_Ptr_Noeud;

   -- Chaque nœud peut avoir deux fils (bit 0 et bit 1)
   -- et optionnellement une route stockée.
   type T_Noeud is record
      Fils            : T_Fils := (null, null);
      -- Route stockée dans ce nœud (valide si A_Route = True)
      A_Route         : Boolean       := False;
      Route           : T_Route;
      -- Compteurs pour les politiques de remplacement
      Seq_Insertion   : Natural       := 0;
      Seq_Dernier     : Natural       := 0;
      Nb_Utilisations : Natural       := 0;
   end record;

   type T_Cache_Trie is limited record
      Racine      : T_Ptr_Noeud := null;
      Nb_Entrees  : Natural     := 0;
      Taille_Max  : Natural     := 0;
      Pol         : T_Politique := FIFO;
      Seq_Global  : Natural     := 0;
      Stats       : T_Stats;
   end record;

end Caches_Trie;
