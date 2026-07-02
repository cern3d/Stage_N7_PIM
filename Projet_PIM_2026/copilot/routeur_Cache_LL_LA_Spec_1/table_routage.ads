-- Package pour gérer la table de routage
with Types_Routeur;
use Types_Routeur;

package Table_Routage is

   -- Charge la table de routage depuis un fichier.
   --
   -- paramètres
   --     File_Name  : nom du fichier de table de routage
   --     Table_Head : tête de la liste chaînée de routes en sortie
   procedure Load_Table(File_Name : String; Table_Head : out Route_Node_Access);

   -- Trouve l'interface associée à une adresse IP de destination.
   --
   -- paramètres
   --     Dest_IP    : adresse de destination recherchée
   --     Table_Head : tête de la table de routage
   --
   -- Assure
   --     Find_Interface renvoie une interface ou une chaîne vide si aucune route
   function Find_Interface(Dest_IP : T_Address_IP; Table_Head : Route_Node_Access) return String;

   -- Trouve la meilleure route correspondant à une adresse IP (longest prefix match).
   --
   -- paramètres
   --     Dest_IP    : adresse de destination recherchée
   --     Table_Head : tête de la table de routage
   --
   -- Assure
   --     le champ Mask_Len du résultat est -1 si aucune route n'est trouvée
   function Find_Route(Dest_IP : T_Address_IP; Table_Head : Route_Node_Access) return Route_Record;

   -- Affiche toutes les routes de la table.
   --
   -- paramètres
   --     Table_Head : tête de la table de routage
   procedure Print_Table(Table_Head : Route_Node_Access);

end Table_Routage;
