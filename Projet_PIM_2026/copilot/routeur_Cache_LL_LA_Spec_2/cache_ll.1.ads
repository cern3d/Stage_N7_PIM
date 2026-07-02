-- Package pour un cache organisé en liste chaînée
with Types_Routeur;
with IP_Utils;
use Types_Routeur;
use IP_Utils;

package Cache_LL is

   -- Initialise le cache.
   --
   -- paramètres
   --     Size   : capacité maximale du cache
   --     Policy : politique d'éviction ("FIFO", "LRU", "LFU")
   procedure Init(Size : Integer; Policy : String);

   -- Recherche dans le cache la meilleure correspondance de préfixe pour Dest_IP.
   -- Retourne une chaîne vide si aucune route n'est trouvée.
   --
   -- paramètres
   --     Dest_IP : adresse IP de destination recherchée
   function Lookup(Dest_IP : T_Address_IP) return String;

   -- Insère une route dans le cache.
   --
   -- paramètres
   --     Dest_IP  : adresse réseau de destination
   --     Mask     : masque réseau
   --     Mask_Len : longueur du masque
   --     Iface    : interface associée à la route
   procedure Insert(Dest_IP : T_Address_IP; Mask : T_Address_IP; Mask_Len : Integer; Iface : String);

   -- Affiche le contenu du cache sur la sortie standard.
   procedure Print_Cache;

   -- Fournit les statistiques du cache.
   --
   -- paramètres
   --     Requests : nombre de recherches effectuées
   --     Hits     : nombre de correspondances trouvées
   --     Misses   : nombre de non-correspondances
   procedure Get_Stats(Requests : out Natural; Hits : out Natural; Misses : out Natural);

end Cache_LL;
