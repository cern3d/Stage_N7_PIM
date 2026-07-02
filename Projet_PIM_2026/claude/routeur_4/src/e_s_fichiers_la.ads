------------------------------------------------------------------------
-- E_S_Fichiers_LA
--
-- Spécification : entrées/sorties pour routeur_LA (cache trie).
--
-- Ce package est fonctionnellement identique à E_S_Fichiers, à
-- l'exception que Traiter_Paquets utilise un T_Cache_Trie (arbre
-- préfixe) au lieu d'un T_Cache (liste chaînée).
--
-- Lire_Table est identique à E_S_Fichiers.Lire_Table ; elle est
-- redéclarée ici pour éviter une dépendance croisée entre les deux
-- packages de E/S.
--
-- Se reporter à E_S_Fichiers pour la spécification complète des
-- formats de fichiers et des algorithmes de traitement.
------------------------------------------------------------------------
with Ada.Text_IO;    use Ada.Text_IO;
with Tables_Routage; use Tables_Routage;
with Caches_Trie;    use Caches_Trie;

package E_S_Fichiers_LA is

   ------------------------------------------------------------------------
   -- Lire_Table
   --
   -- Identique à E_S_Fichiers.Lire_Table.
   --
   -- Précondition  : Table a été initialisée
   --                 Nom_Fichier'Length > 0
   -- Postcondition : Taille(Table) = Taille(Table)@avant + N
   --                 où N est le nombre de routes valides lues
   -- Exception     : Ada.IO_Exceptions.Name_Error si fichier introuvable
   ------------------------------------------------------------------------
   procedure Lire_Table (Nom_Fichier : String;
                         Table       : in out T_Table)
     with Pre => Nom_Fichier'Length > 0;

   ------------------------------------------------------------------------
   -- Traiter_Paquets
   --
   -- Identique à E_S_Fichiers.Traiter_Paquets, mais utilise un
   -- T_Cache_Trie (arbre préfixe) à la place d'un T_Cache (liste).
   --
   -- Précondition  : Table a été initialisée et chargée
   --                 Cache a été initialisé
   --                 Fichier_Res est ouvert en écriture (Out_File)
   --                 Nom_Fichier'Length > 0
   -- Postcondition : identique à E_S_Fichiers.Traiter_Paquets
   -- Exception     : Ada.IO_Exceptions.Name_Error si fichier introuvable
   ------------------------------------------------------------------------
   procedure Traiter_Paquets (Nom_Fichier :        String;
                              Table       :        T_Table;
                              Cache       : in out T_Cache_Trie;
                              Fichier_Res : in out File_Type)
     with Pre => Nom_Fichier'Length > 0;

end E_S_Fichiers_LA;
