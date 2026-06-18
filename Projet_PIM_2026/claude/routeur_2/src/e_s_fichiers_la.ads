-- E_S_Fichiers_LA : version de E_S_Fichiers pour le routeur avec cache trie.
-- Lire_Table est identique ; Traiter_Paquets utilise T_Cache_Trie.

with Ada.Text_IO;    use Ada.Text_IO;
with Tables_Routage; use Tables_Routage;
with Caches_Trie;    use Caches_Trie;

package E_S_Fichiers_LA is

   -- Identique à E_S_Fichiers.Lire_Table
   procedure Lire_Table (Nom_Fichier : String;
                         Table       : in out T_Table);

   -- Traiter les paquets avec le cache trie
   procedure Traiter_Paquets (Nom_Fichier :        String;
                              Table       :        T_Table;
                              Cache       : in out T_Cache_Trie;
                              Fichier_Res : in out File_Type);

end E_S_Fichiers_LA;
