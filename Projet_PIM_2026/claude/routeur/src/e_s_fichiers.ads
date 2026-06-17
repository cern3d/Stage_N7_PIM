-- E_S_Fichiers : lecture de la table de routage et des paquets,
--                écriture des résultats.

with Ada.Text_IO;         use Ada.Text_IO;
with Tables_Routage;      use Tables_Routage;
with Adresses_IP;         use Adresses_IP;

package E_S_Fichiers is

   -- Lire le fichier Nom_Fichier et peupler Table.
   -- Chaque ligne : <destination> <masque> <interface>
   -- Lève Ada.IO_Exceptions.Name_Error si le fichier n'existe pas.
   procedure Lire_Table (Nom_Fichier : String;
                         Table       : in out T_Table);

   -- Traiter le fichier de paquets Nom_Fichier.
   -- Pour chaque adresse IP lue, chercher la route dans Table et écrire
   -- le résultat dans Fichier_Res (déjà ouvert en écriture).
   -- Afficher les résultats des commandes (table, cache, stat, fin)
   -- sur la sortie standard.
   -- Retourne dans Nb_Paquets le nombre de paquets routés,
   -- dans Nb_Defauts le nombre de défauts (aucune route trouvée).
   procedure Traiter_Paquets (Nom_Fichier  :     String;
                              Table        :     T_Table;
                              Fichier_Res  : in out File_Type;
                              Nb_Paquets   :    out Natural;
                              Nb_Defauts   :    out Natural);

end E_S_Fichiers;
