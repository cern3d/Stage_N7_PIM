------------------------------------------------------------------------
-- Caches_LL
--
-- Spécification : TAD cache de routes implantée par une liste chaînée.
--
-- Le cache conserve un sous-ensemble des résultats de routage déjà
-- calculés pour accélérer les recherches futures.
--
-- Politiques de remplacement (choix à l'initialisation) :
--   FIFO : expulse l'entrée dont le numéro de séquence d'insertion
--           est le plus petit (la plus anciennement insérée).
--   LRU  : expulse l'entrée dont le dernier accès (lecture ou insertion)
--           est le plus ancien (Seq_Dernier minimal).
--   LFU  : expulse l'entrée la moins souvent accédée depuis son insertion
--           (Nb_Utilisations minimal).
--
-- Cohérence du cache (§1.4.2) :
--   Chaque entrée stocke une route construite avec un masque discriminant
--   calculé par Tables_Routage.Masque_Discriminant, garantissant qu'aucune
--   route plus spécifique de la table ne sera masquée par le cache.
--
-- Invariants du type T_Cache (garantis après Initialiser, conservés par
-- toutes les opérations) :
--   (I1) Nb_Entrees = longueur de la liste chaînée pointée par Tete
--   (I2) 0 <= Nb_Entrees <= Taille_Max  (ou Taille_Max = 0 : cache inactif)
--   (I3) Stats.Nb_Demandes = Stats.Nb_Hits + Stats.Nb_Defauts
--   (I4) Seq_Global est strictement croissant au fil des opérations
------------------------------------------------------------------------
with Adresses_IP;    use Adresses_IP;
with Tables_Routage; use Tables_Routage;
with Parametres;     use Parametres;

package Caches_LL is

   -- Statistiques du cache
   -- Invariant : Nb_Demandes = Nb_Hits + Nb_Defauts
   type T_Stats is record
      Nb_Demandes  : Natural := 0;
      Nb_Hits      : Natural := 0;
      Nb_Defauts   : Natural := 0;
      Nb_Evictions : Natural := 0;
   end record;

   -- Type abstrait : cache de routes par liste chaînée
   type T_Cache is limited private;

   ------------------------------------------------------------------------
   -- Initialiser
   --
   -- Crée un cache vide de capacité maximale Taille_Max et de politique
   -- de remplacement Pol.
   --
   -- Précondition  : aucune
   -- Postcondition :
   --   Nb_Entrees  = 0
   --   Taille_Max  = Taille_Max@appel
   --   Pol         = Pol@appel
   --   Seq_Global  = 0
   --   Stats       = (0, 0, 0, 0)
   ------------------------------------------------------------------------
   procedure Initialiser (Cache      : out T_Cache;
                          Taille_Max :     Natural;
                          Pol        :     T_Politique);

   ------------------------------------------------------------------------
   -- Finaliser
   --
   -- Libère toute la mémoire dynamique du cache.
   --
   -- Précondition  : Cache a été initialisé
   -- Postcondition : Nb_Entrees = 0 ; toute la mémoire est libérée
   ------------------------------------------------------------------------
   procedure Finaliser (Cache : in out T_Cache);

   ------------------------------------------------------------------------
   -- Chercher
   --
   -- Cherche dans le cache une entrée dont le masque correspond à
   -- Destination (test Correspond standard). En cas de hit, met à jour
   -- les compteurs Seq_Dernier et Nb_Utilisations de l'entrée trouvée.
   --
   -- Précondition  : Cache a été initialisé
   -- Postcondition :
   --   Stats.Nb_Demandes = Stats.Nb_Demandes@avant + 1
   --   Si résultat = True  : Stats.Nb_Hits    = Stats.Nb_Hits@avant + 1
   --                         Correspond(Destination, Route.Destination,
   --                                    Route.Masque) = True
   --   Si résultat = False : Stats.Nb_Defauts = Stats.Nb_Defauts@avant + 1
   ------------------------------------------------------------------------
   function Chercher (Cache       : in out T_Cache;
                      Destination :        T_Adresse_IP;
                      Route       :    out T_Route) return Boolean;

   ------------------------------------------------------------------------
   -- Inserer
   --
   -- Construit la route à mettre en cache (masque discriminant via
   -- Tables_Routage.Masque_Discriminant) puis l'insère dans le cache.
   -- Si le cache est plein (Nb_Entrees = Taille_Max > 0), expulse d'abord
   -- la victime selon la politique avant d'insérer.
   -- Si Taille_Max = 0, ne fait rien.
   --
   -- Précondition  : Cache a été initialisé
   --                 Table a été initialisée et contient au moins Route_Ok
   --                 Chercher(Table, Dest_Orig, Route_Ok) = True
   --                   (Route_Ok est bien la route LPM pour Dest_Orig)
   -- Postcondition :
   --   Si Taille_Max = 0 : Cache inchangé
   --   Sinon :
   --     Nb_Entrees <= Taille_Max
   --     La route insérée vérifie :
   --       Route_cache.Masque = masque discriminant calculé pour Dest_Orig
   --       Route_cache.Destination = Dest_Orig AND Route_cache.Masque
   --       Route_cache.Iface = Route_Ok.Iface
   ------------------------------------------------------------------------
   procedure Inserer (Cache     : in out T_Cache;
                      Table     :        T_Table;
                      Dest_Orig :        T_Adresse_IP;
                      Route_Ok  :        T_Route);

   ------------------------------------------------------------------------
   -- Afficher
   --
   -- Affiche sur la sortie standard toutes les entrées du cache (de la
   -- tête vers la queue, ordre du plus récemment inséré au plus ancien),
   -- au format : "<destination> <masque> <interface>"
   --
   -- Précondition  : Cache a été initialisé
   -- Postcondition : Cache est inchangé
   ------------------------------------------------------------------------
   procedure Afficher (Cache : T_Cache);

   ------------------------------------------------------------------------
   -- Statistiques
   --
   -- Retourne une copie des statistiques courantes.
   --
   -- Précondition  : Cache a été initialisé
   -- Postcondition : résultat.Nb_Demandes = résultat.Nb_Hits
   --                                       + résultat.Nb_Defauts
   ------------------------------------------------------------------------
   function Statistiques (Cache : T_Cache) return T_Stats
     with Post => Statistiques'Result.Nb_Demandes =
                  Statistiques'Result.Nb_Hits +
                  Statistiques'Result.Nb_Defauts;

   ------------------------------------------------------------------------
   -- Afficher_Stats
   --
   -- Affiche sur la sortie standard les statistiques du cache :
   -- nombre de demandes, hits, défauts, évictions, taux de hit/défaut.
   --
   -- Précondition  : Cache a été initialisé
   -- Postcondition : Cache est inchangé
   ------------------------------------------------------------------------
   procedure Afficher_Stats (Cache : T_Cache);

private

   type T_Cellule_Cache;
   type T_Ptr_Cache is access T_Cellule_Cache;

   type T_Cellule_Cache is record
      Route           : T_Route;
      Seq_Insertion   : Natural     := 0;
      Seq_Dernier     : Natural     := 0;
      Nb_Utilisations : Natural     := 0;
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
