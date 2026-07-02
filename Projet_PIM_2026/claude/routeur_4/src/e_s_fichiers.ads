------------------------------------------------------------------------
-- E_S_Fichiers
--
-- Spécification : lecture de la table de routage et des paquets,
-- écriture des résultats. Version pour routeur_LL (cache liste chaînée).
--
-- Ce package encapsule toutes les entrées/sorties fichier du programme
-- routeur_LL. Il fournit deux sous-programmes principaux :
--   * Lire_Table     : lit un fichier de configuration et peuple la table
--   * Traiter_Paquets : lit un fichier de paquets, route chaque adresse
--                       (cache → table), traite les commandes inline,
--                       et écrit les résultats dans un fichier de sortie.
--
-- Format du fichier de table (une route par ligne, champs séparés par
-- des espaces) :
--   <destination> <masque> <interface>
--   Exemple : "147.127.18.0 255.255.255.0 eth1"
--
-- Format du fichier de paquets (une adresse IP ou une commande par ligne) :
--   Commandes reconnues : table | cache | stat | fin
--   Toute autre ligne est interprétée comme une adresse IP destination.
--
-- Format du fichier de résultats (une ligne par paquet routé) :
--   <adresse_ip_destination> <interface>
--   Exemple : "212.212.212.212 eth3"
------------------------------------------------------------------------
with Ada.Text_IO;    use Ada.Text_IO;
with Tables_Routage; use Tables_Routage;
with Caches_LL;      use Caches_LL;

package E_S_Fichiers is

   ------------------------------------------------------------------------
   -- Lire_Table
   --
   -- Ouvre le fichier Nom_Fichier en lecture et ajoute chaque route
   -- valide dans Table via Tables_Routage.Ajouter. Les lignes vides
   -- et les lignes incomplètes sont ignorées silencieusement.
   --
   -- Précondition  : Table a été initialisée
   --                 Nom_Fichier'Length > 0
   -- Postcondition : Taille(Table) = Taille(Table)@avant + N
   --                 où N est le nombre de routes valides dans le fichier
   --                 Le fichier est fermé à la sortie (succès ou exception)
   -- Exception     : Ada.IO_Exceptions.Name_Error si le fichier n'existe
   --                 pas ou n'est pas accessible en lecture.
   --                 Constraint_Error si une adresse dans le fichier est
   --                 mal formée.
   ------------------------------------------------------------------------
   procedure Lire_Table (Nom_Fichier : String;
                         Table       : in out T_Table)
     with Pre => Nom_Fichier'Length > 0;

   ------------------------------------------------------------------------
   -- Traiter_Paquets
   --
   -- Lit le fichier de paquets Nom_Fichier ligne par ligne.
   -- Pour chaque ligne :
   --   * Si c'est une commande reconnue ("table", "cache", "stat", "fin") :
   --       affiche son nom et son numéro de ligne sur la sortie standard,
   --       exécute la commande ; "fin" arrête le traitement immédiatement.
   --   * Sinon : interprète la ligne comme une adresse IP destination.
   --       1. Chercher dans Cache  → si hit  : utiliser la route du cache
   --       2. Si miss              : chercher dans Table (LPM)
   --                                 si trouvé : insérer dans Cache
   --       3. Écrire dans Fichier_Res : "<ip_dest> <interface>"
   --       Les adresses invalides sont signalées sur stderr et ignorées.
   --
   -- Précondition  : Table a été initialisée et chargée
   --                 Cache a été initialisé
   --                 Fichier_Res est ouvert en écriture (Out_File)
   --                 Nom_Fichier'Length > 0
   -- Postcondition : Tous les paquets (jusqu'à "fin" ou fin de fichier)
   --                 ont été traités.
   --                 Fichier_Res contient les résultats de routage.
   --                 Nom_Fichier est fermé à la sortie.
   -- Exception     : Ada.IO_Exceptions.Name_Error si le fichier de
   --                 paquets n'existe pas.
   ------------------------------------------------------------------------
   procedure Traiter_Paquets (Nom_Fichier :        String;
                              Table       :        T_Table;
                              Cache       : in out T_Cache;
                              Fichier_Res : in out File_Type)
     with Pre => Nom_Fichier'Length > 0;

end E_S_Fichiers;
