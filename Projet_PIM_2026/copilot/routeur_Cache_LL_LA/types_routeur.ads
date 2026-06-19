-- Package de définition des types utilisés par le routeur
package Types_Routeur is

   -- Type pour les adresses IP (32 bits)
   type T_Address_IP is mod 2 ** 32;

   -- Enregistrement représentant une route
   type Route_Record is record
      Dest       : T_Address_IP;
      Mask       : T_Address_IP;
      Iface      : String(1..32);
      Mask_Len   : Integer;
   end record;

   -- Nœud de liste chaînée pour stocker les routes
   type Route_Node;
   type Route_Node_Access is access Route_Node;
   type Route_Node is record
      R    : Route_Record;
      Next : Route_Node_Access := null;
   end record;

end Types_Routeur;
