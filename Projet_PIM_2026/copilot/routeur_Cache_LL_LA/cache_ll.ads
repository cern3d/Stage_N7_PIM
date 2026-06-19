-- Package pour un cache organisé en liste chaînée
with Types_Routeur;
with IP_Utils;
use Types_Routeur;
use IP_Utils;

package Cache_LL is

   -- Initialise le cache
   procedure Init(Size : Integer; Policy : String);

   -- Recherche dans le cache la meilleure correspondance pour Dest_IP
   -- Retourne une chaîne vide si non trouvé
   function Lookup(Dest_IP : T_Address_IP) return String;

   -- Insère une route dans le cache
   procedure Insert(Dest_IP : T_Address_IP; Mask : T_Address_IP; Mask_Len : Integer; Iface : String);

   -- Affiche le contenu du cache
   procedure Print_Cache;

   -- Statistiques
   procedure Get_Stats(Requests : out Natural; Hits : out Natural; Misses : out Natural);

end Cache_LL;
