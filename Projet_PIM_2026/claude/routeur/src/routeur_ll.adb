-- routeur_LL : routeur simple avec liste chaînée pour la table de routage.
-- Version 1 (sans cache) pour le livrable du 20 décembre.
--
-- Raffinage principal :
--   1. Analyser les arguments de la ligne de commande
--   2. Lire la table de routage depuis le fichier
--   3. Ouvrir le fichier de résultats en écriture
--   4. Traiter les paquets (et les commandes éventuelles)
--   5. Afficher les statistiques si demandé
--   6. Fermer les fichiers et libérer la mémoire

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.IO_Exceptions;
with Parametres;          use Parametres;
with Adresses_IP;         use Adresses_IP;
with Tables_Routage;      use Tables_Routage;
with E_S_Fichiers;        use E_S_Fichiers;

procedure Routeur_LL is

   Params      : T_Parametres;
   Table       : T_Table;
   Fich_Res    : File_Type;
   Nb_Paquets  : Natural;
   Nb_Defauts  : Natural;

begin
   -- Étape 1 : analyser la ligne de commande
   Analyser (Params);

   -- Étape 2 : initialiser et charger la table de routage
   Initialiser (Table);
   Lire_Table (Params.Fichier_Table.all, Table);

   -- Étape 3 : ouvrir le fichier de résultats
   Create (Fich_Res, Out_File, Params.Fichier_Resultats.all);

   -- Étape 4 : traiter les paquets
   Traiter_Paquets (Params.Fichier_Paquets.all,
                    Table,
                    Fich_Res,
                    Nb_Paquets,
                    Nb_Defauts);

   -- Étape 5 : afficher les statistiques si demandé
   if Params.Afficher_Stats then
      New_Line;
      Put_Line ("=== Statistiques ===");
      Put_Line ("Paquets traites : " & Natural'Image (Nb_Paquets));
      Put_Line ("Sans route      : " & Natural'Image (Nb_Defauts));
      if Nb_Paquets > 0 then
         Put_Line ("Taux defaut     : "
                   & Natural'Image (Nb_Defauts * 100 / Nb_Paquets) & "%");
      end if;
   end if;

   -- Étape 6 : fermer et libérer
   Close (Fich_Res);
   Finaliser (Table);

exception
   when Ada.IO_Exceptions.Name_Error =>
      Put_Line (Standard_Error, "Erreur : fichier introuvable.");
      if Is_Open (Fich_Res) then
         Close (Fich_Res);
      end if;
      Finaliser (Table);

   when Constraint_Error =>
      Put_Line (Standard_Error,
                "Erreur : argument invalide. "
                & "Usage : routeur_LL [-c <n>] [-p FIFO|LRU|LFU] "
                & "[-s|-S] [-t <fichier>] [-q <fichier>] [-r <fichier>]");
      if Is_Open (Fich_Res) then
         Close (Fich_Res);
      end if;
      Finaliser (Table);

end Routeur_LL;
