------------------------------------------------------------------------
-- Caches_Trie
--
-- Spécification : TAD cache de routes implantée par un arbre préfixe
-- (trie binaire) sur les bits des adresses IP.
--
-- Structure de l'arbre :
--   - La racine correspond au bit 31 (MSB) de l'adresse.
--   - Chaque nœud a au plus deux fils : Fils(0) pour le bit 0,
--     Fils(1) pour le bit 1.
--   - Une route peut être stockée à n'importe quel nœud interne ou
--     feuille ; elle est placée au nœud de profondeur égale à la
--     longueur du masque de la route.
--
-- Invariants du type T_Cache_Trie (garantis après Initialiser) :
--   (I1) Nb_Entrees = nombre de nœuds portant une route (A_Route = True)
--   (I2) 0 <= Nb_Entrees <= Taille_Max
--   (I3) Stats.Nb_Demandes = Stats.Nb_Hits + Stats.Nb_Defauts
--   (I4) Pour tout nœud N à profondeur D portant une route R :
--          Longueur_Masque(R.Masque) = D
--   (I5) Seq_Global est strictement croissant
--
-- Recherche (LPM dans le trie) :
--   On descend bit par bit depuis le MSB de Destination.
--   On mémorise le dernier nœud portant une route rencontré en chemin.
--   Ce nœud correspond à la correspondance la plus longue (LPM).
--
-- Politiques de remplacement : identiques à Caches_LL (FIFO/LRU/LFU).
-- L'expulsion parcourt récursivement tous les nœuds portant une route
-- pour trouver la victime, puis élague les nœuds devenus inutiles.
------------------------------------------------------------------------
with Adresses_IP;    use Adresses_IP;
with Tables_Routage; use Tables_Routage;
with Parametres;     use Parametres;
with Caches_LL;      use Caches_LL;   -- réutilise T_Stats

package Caches_Trie is

   -- Type abstrait : cache de routes par arbre préfixe binaire
   type T_Cache_Trie is limited private;

   ------------------------------------------------------------------------
   -- Initialiser
   --
   -- Crée un cache trie vide de capacité Taille_Max et de politique Pol.
   --
   -- Précondition  : aucune
   -- Postcondition :
   --   Nb_Entrees = 0  (arbre vide, racine = null)
   --   Taille_Max = Taille_Max@appel
   --   Pol        = Pol@appel
   --   Stats      = (0, 0, 0, 0)
   ------------------------------------------------------------------------
   procedure Initialiser (Cache      : out T_Cache_Trie;
                          Taille_Max :     Natural;
                          Pol        :     T_Politique);

   ------------------------------------------------------------------------
   -- Finaliser
   --
   -- Libère récursivement tous les nœuds de l'arbre.
   --
   -- Précondition  : Cache a été initialisé
   -- Postcondition : Nb_Entrees = 0 ; toute la mémoire est libérée
   ------------------------------------------------------------------------
   procedure Finaliser (Cache : in out T_Cache_Trie);

   ------------------------------------------------------------------------
   -- Chercher
   --
   -- Descend dans le trie bit par bit depuis le bit 31 (MSB) de
   -- Destination et retourne la route du nœud le plus profond portant
   -- une route rencontré en chemin (LPM dans le trie).
   -- En cas de hit, met à jour Seq_Dernier et Nb_Utilisations du nœud.
   --
   -- Précondition  : Cache a été initialisé
   -- Postcondition :
   --   Stats.Nb_Demandes = Stats.Nb_Demandes@avant + 1
   --   Si résultat = True  : Stats.Nb_Hits    = Stats.Nb_Hits@avant + 1
   --                         Correspond(Destination, Route.Destination,
   --                                    Route.Masque) = True
   --   Si résultat = False : Stats.Nb_Defauts = Stats.Nb_Defauts@avant + 1
   ------------------------------------------------------------------------
   function Chercher (Cache       : in out T_Cache_Trie;
                      Destination :        T_Adresse_IP;
                      Route       :    out T_Route) return Boolean;

   ------------------------------------------------------------------------
   -- Inserer
   --
   -- Calcule la route à mettre en cache (masque discriminant §1.4.2 via
   -- Tables_Routage.Masque_Discriminant) puis insère cette route dans
   -- l'arbre au nœud de profondeur = longueur du masque discriminant.
   -- Crée les nœuds intermédiaires manquants.
   -- Si le cache est plein (Nb_Entrees = Taille_Max > 0), expulse d'abord
   -- la victime selon la politique (parcours récursif + élagage).
   -- Si Taille_Max = 0, ne fait rien.
   --
   -- Précondition  : Cache a été initialisé
   --                 Table a été initialisée et contient au moins Route_Ok
   --                 Chercher(Table, Dest_Orig, Route_Ok) = True
   -- Postcondition :
   --   Si Taille_Max = 0 : Cache inchangé
   --   Sinon :
   --     Nb_Entrees <= Taille_Max
   --     La route insérée vérifie l'invariant (I4) ci-dessus
   ------------------------------------------------------------------------
   procedure Inserer (Cache     : in out T_Cache_Trie;
                      Table     :        T_Table;
                      Dest_Orig :        T_Adresse_IP;
                      Route_Ok  :        T_Route);

   ------------------------------------------------------------------------
   -- Afficher
   --
   -- Affiche sur la sortie standard toutes les routes du cache par un
   -- parcours préfixe (profondeur d'abord, fils 0 avant fils 1).
   --
   -- Précondition  : Cache a été initialisé
   -- Postcondition : Cache est inchangé
   ------------------------------------------------------------------------
   procedure Afficher (Cache : T_Cache_Trie);

   ------------------------------------------------------------------------
   -- Statistiques
   --
   -- Retourne une copie des statistiques courantes.
   --
   -- Précondition  : Cache a été initialisé
   -- Postcondition : résultat.Nb_Demandes = résultat.Nb_Hits
   --                                       + résultat.Nb_Defauts
   ------------------------------------------------------------------------
   function Statistiques (Cache : T_Cache_Trie) return T_Stats
     with Post => Statistiques'Result.Nb_Demandes =
                  Statistiques'Result.Nb_Hits +
                  Statistiques'Result.Nb_Defauts;

   ------------------------------------------------------------------------
   -- Afficher_Stats
   --
   -- Affiche sur la sortie standard les statistiques du cache trie.
   --
   -- Précondition  : Cache a été initialisé
   -- Postcondition : Cache est inchangé
   ------------------------------------------------------------------------
   procedure Afficher_Stats (Cache : T_Cache_Trie);

private

   type T_Noeud;
   type T_Ptr_Noeud is access T_Noeud;

   type T_Fils is array (0 .. 1) of T_Ptr_Noeud;

   type T_Noeud is record
      Fils            : T_Fils       := (others => null);
      A_Route         : Boolean      := False;
      Route           : T_Route;
      Seq_Insertion   : Natural      := 0;
      Seq_Dernier     : Natural      := 0;
      Nb_Utilisations : Natural      := 0;
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
