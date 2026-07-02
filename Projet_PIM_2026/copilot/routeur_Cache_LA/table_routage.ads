-- Package pour gérer la table de routage
with Types_Routeur;
use Types_Routeur;

package Table_Routage is

   -- Charge la table de routage depuis un fichier
   procedure Load_Table(File_Name : String; Table_Head : out Route_Node_Access);

   -- Trouve l'interface pour une adresse IP destination
   function Find_Interface(Dest_IP : T_Address_IP; Table_Head : Route_Node_Access) return String;

   -- Trouve la route (enregistrement) correspondant à une adresse IP (meilleure correspondance)
   -- Si aucune route trouvée, retourne un enregistrement avec Mask_Len = -1
   function Find_Route(Dest_IP : T_Address_IP; Table_Head : Route_Node_Access) return Route_Record;

   -- Affiche toutes les routes de la table
   procedure Print_Table(Table_Head : Route_Node_Access);

end Table_Routage;
