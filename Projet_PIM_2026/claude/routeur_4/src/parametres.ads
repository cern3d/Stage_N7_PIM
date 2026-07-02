------------------------------------------------------------------------
-- Parametres
--
-- Spécification : analyse de la ligne de commande pour routeur_LL
-- et routeur_LA.
--
-- Options reconnues (peuvent apparaître dans n'importe quel ordre ;
-- en cas de répétition, la dernière occurrence fait foi) :
--   -c <taille>        taille du cache (Natural, défaut 10 ; 0 = pas de cache)
--   -p FIFO|LRU|LFU   politique de remplacement (défaut FIFO)
--   -s                 afficher les statistiques (défaut)
--   -S                 ne pas afficher les statistiques
--   -t <fichier>       fichier de la table de routage (défaut "table.txt")
--   -q <fichier>       fichier des paquets (défaut "paquets.txt")
--   -r <fichier>       fichier des résultats (défaut "resultats.txt")
------------------------------------------------------------------------
package Parametres is

   -- Politiques de gestion du cache
   -- FIFO : expulse la plus ancienne entrée (premier entré, premier sorti)
   -- LRU  : expulse l'entrée la moins récemment utilisée
   -- LFU  : expulse l'entrée la moins fréquemment utilisée
   type T_Politique is (FIFO, LRU, LFU);

   -- Invariant : Fichier_Table, Fichier_Paquets, Fichier_Resultats
   --             ne sont jamais null après un appel à Analyser.
   type T_Parametres is record
      Taille_Cache      : Natural     := 10;
      Politique         : T_Politique := FIFO;
      Afficher_Stats    : Boolean     := True;
      Fichier_Table     : access String;
      Fichier_Paquets   : access String;
      Fichier_Resultats : access String;
   end record;

   ------------------------------------------------------------------------
   -- Analyser
   --
   -- Lit Ada.Command_Line et remplit Params avec les valeurs des options.
   -- Les valeurs par défaut sont appliquées avant l'analyse ; toute option
   -- présente écrase la valeur courante.
   --
   -- Précondition  : aucune
   -- Postcondition :
   --   Params.Fichier_Table     /= null
   --   Params.Fichier_Paquets   /= null
   --   Params.Fichier_Resultats /= null
   --   Params.Taille_Cache      >= 0
   -- Exception     : Constraint_Error si une option est inconnue,
   --                 si un argument attendu est absent, ou si la valeur
   --                 de -c n'est pas un Natural valide.
   ------------------------------------------------------------------------
   procedure Analyser (Params : out T_Parametres);

end Parametres;
