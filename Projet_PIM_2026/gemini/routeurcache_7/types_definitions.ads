with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Types_Definitions is

   -- Type IP sous forme d'entier naturel modulo 2**32 (32 bits) 
   type T_Adresse_IP is mod 2**32;

   -- Type pour la politique de remplacement du cache
   type T_Politique is (FIFO, LRU, LFU);

   -- Structure d'une Route dans le Cache (avec métadonnées)
   type T_Route_Cache is record
      Destination    : T_Adresse_IP;
      Masque         : T_Adresse_IP;
      Interface_R    : Unbounded_String;
      Date_Insertion : Natural := 0; -- Pour la politique FIFO
      Dernier_Acces  : Natural := 0; -- Pour la politique LRU
      Frequence      : Natural := 0; -- Pour la politique LFU
   end record;

   -- Structure représentant une route complète
   type T_Route is record
      Destination : T_Adresse_IP;   -- Adresse réseau de destination
      Masque      : T_Adresse_IP;   -- Masque de sous-réseau
      Interface_R : Unbounded_String; -- Interface de sortie associée
   end record;

   ----------------------------------------------------------------------------
   -- FONCTIONS UTILITAIRES DE CONVERSION
   ----------------------------------------------------------------------------

   -- Convertir une chaîne au format pointé ("192.168.1.1") en un entier 32 bits.
   --
   -- Paramètres
   --     S : la chaîne de caractères représentant l'adresse IP
   --
   -- Assure
   --     String_To_IP'Result contient la valeur numérique de l'IP sur 32 bits.
   --
   function String_To_IP (S : String) return T_Adresse_IP;

   -- Convertir un entier 32 bits en sa représentation textuelle pointée (ex: "192.168.1.1").
   --
   -- Paramètres
   --     IP : l'adresse IP sous forme d'entier 32 bits
   --
   -- Assure
   --     String_To_IP (IP_To_String'Result) = IP
   --
   function IP_To_String (IP : T_Adresse_IP) return String with
       Post => String_To_IP (IP_To_String'Result) = IP;

end Types_Definitions;