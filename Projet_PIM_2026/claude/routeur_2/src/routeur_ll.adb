-- routeur_LL : routeur avec liste chaînée pour la table de routage
--              et liste chaînée pour le cache.
--
-- Raffinage principal :
--   1. Analyser les arguments de la ligne de commande
--   2. Initialiser la table de routage (liste chaînée)
--   3. Lire la table de routage depuis le fichier
--   4. Initialiser le cache (liste chaînée, politique, taille)
--   5. Ouvrir le fichier de résultats en écriture
--   6. Traiter les paquets (recherche cache → table, commandes inline)
--   7. Afficher les statistiques finales si demandé
--   8. Fermer les fichiers et libérer la mémoire

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.IO_Exceptions;
with Parametres;        use Parametres;
with Tables_Routage;    use Tables_Routage;
with Caches_LL;         use Caches_LL;
with E_S_Fichiers;      use E_S_Fichiers;

procedure Routeur_LL is

   Params   : T_Parametres;
   Table    : T_Table;
   Cache    : T_Cache;
   Fich_Res : Ada.Text_IO.File_Type;
   Stats    : T_Stats;

begin
   -- Étape 1 : analyser la ligne de commande
   Analyser (Params);

   -- Étape 2 & 3 : initialiser et charger la table de routage
   Initialiser (Table);
   Lire_Table (Params.Fichier_Table.all, Table);

   -- Étape 4 : initialiser le cache
   Initialiser (Cache, Params.Taille_Cache, Params.Politique);

   -- Étape 5 : ouvrir le fichier de résultats
   Create (Fich_Res, Out_File, Params.Fichier_Resultats.all);

   -- Étape 6 : traiter les paquets
   Traiter_Paquets (Params.Fichier_Paquets.all, Table, Cache, Fich_Res);

   -- Étape 7 : afficher les statistiques finales si demandé
   if Params.Afficher_Stats then
      Stats := Statistiques (Cache);
      New_Line;
      Put_Line ("=== Statistiques finales ===");
      Put_Line ("Politique cache   : " & T_Politique'Image (Params.Politique));
      Put_Line ("Taille cache      : " & Natural'Image (Params.Taille_Cache));
      Afficher_Stats (Cache);
   end if;

   -- Étape 8 : fermer et libérer
   Close (Fich_Res);
   Finaliser (Cache);
   Finaliser (Table);

exception
   when Ada.IO_Exceptions.Name_Error =>
      Put_Line (Standard_Error, "Erreur : fichier introuvable.");
      if Is_Open (Fich_Res) then
         Close (Fich_Res);
      end if;
      Finaliser (Cache);
      Finaliser (Table);

   when Constraint_Error =>
      Put_Line (Standard_Error,
                "Erreur d'argument. "
                & "Usage : routeur_LL [-c <n>] [-p FIFO|LRU|LFU] "
                & "[-s|-S] [-t <fic>] [-q <fic>] [-r <fic>]");
      if Is_Open (Fich_Res) then
         Close (Fich_Res);
      end if;
      Finaliser (Cache);
      Finaliser (Table);

end Routeur_LL;
