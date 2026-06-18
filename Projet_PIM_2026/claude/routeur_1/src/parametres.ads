-- Parametres : analyse de la ligne de commande pour routeur_LL / routeur_LA
-- Options supportées : -c -p -s -S -t -q -r

package Parametres is

   -- Politiques de gestion du cache
   type T_Politique is (FIFO, LRU, LFU);

   -- Ensemble des paramètres du programme
   type T_Parametres is record
      Taille_Cache      : Natural      := 10;
      Politique         : T_Politique  := FIFO;
      Afficher_Stats    : Boolean      := True;
      Fichier_Table     : access String;
      Fichier_Paquets   : access String;
      Fichier_Resultats : access String;
   end record;

   -- Analyser Ada.Command_Line et remplir les paramètres.
   -- Lève Constraint_Error si une option est inconnue ou mal formée.
   procedure Analyser (Params : out T_Parametres);

end Parametres;
