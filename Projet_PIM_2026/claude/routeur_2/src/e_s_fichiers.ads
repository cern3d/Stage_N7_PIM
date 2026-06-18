-- E_S_Fichiers : lecture de la table de routage et des paquets,
--                écriture des résultats.
-- Version avec cache : Traiter_Paquets gère aussi le cache.

with Ada.Text_IO;    use Ada.Text_IO;
with Tables_Routage; use Tables_Routage;
with Caches_LL;      use Caches_LL;

package E_S_Fichiers is

   -- Lire le fichier Nom_Fichier et peupler Table.
   -- Chaque ligne : <destination> <masque> <interface>
   -- Lève Ada.IO_Exceptions.Name_Error si le fichier n'existe pas.
   procedure Lire_Table (Nom_Fichier : String;
                         Table       : in out T_Table);

   -- Traiter le fichier de paquets.
   -- Pour chaque adresse IP :
   --   1. Chercher dans le cache
   --   2. Si miss : chercher dans la table, insérer dans le cache
   --   3. Écrire le résultat dans Fichier_Res
   -- Les commandes (table, cache, stat, fin) sont traitées inline.
   procedure Traiter_Paquets (Nom_Fichier :        String;
                              Table       :        T_Table;
                              Cache       : in out T_Cache;
                              Fichier_Res : in out File_Type);

end E_S_Fichiers;
