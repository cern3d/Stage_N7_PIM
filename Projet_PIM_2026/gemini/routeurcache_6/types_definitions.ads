with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Types_Definitions is

   -- Type IP sous forme d'entier naturel modulo 2**32 (32 bits) 
   type T_Adresse_IP is mod 2**32;

   -- Type pour la politique de remplacement du cache [cite: 2]
   type T_Politique is (FIFO, LRU, LFU);

   -- Structure d'une Route dans le Cache (avec métadonnées pour les politiques d'éviction) [cite: 3]
   type T_Route_Cache is record
      Destination    : T_Adresse_IP;
      Masque         : T_Adresse_IP;
      Interface_R    : Unbounded_String;
      Date_Insertion : Natural := 0; -- Horodatage global pour la politique FIFO [cite: 5]
      Dernier_Acces  : Natural := 0; -- Horodatage global pour la politique LRU [cite: 5, 6]
      Frequence      : Natural := 0; -- Compteur d'utilisations pour la politique LFU [cite: 6, 7]
   end record;

   -- Structure représentant une route statique issue de la table de routage [cite: 16, 45]
   type T_Route is record
      Destination : T_Adresse_IP;    -- Adresse réseau de destination [cite: 8]
      Masque      : T_Adresse_IP;    -- Masque de sous-réseau [cite: 9]
      Interface_R : Unbounded_String; -- Interface de sortie associée (ex: eth0) [cite: 10]
   end record;

   ----------------------------------------------------------------------------
   -- FONCTIONS UTILITAIRES DE CONVERSION [cite: 11]
   ----------------------------------------------------------------------------

   -- Rôle : Convertit une chaîne au format pointé ("192.168.1.1") en entier 32 bits.
   -- Préconditions  : S doit être une chaîne bien formée contenant 4 octets séparés par des points.
   -- Postconditions : Renvoie la valeur numérique correspondante de type T_Adresse_IP.
   function String_To_IP (S : String) return T_Adresse_IP;

   -- Rôle : Convertit un entier 32 bits en sa représentation textuelle pointée (ex: "192.168.1.1").
   -- Préconditions  : Aucune (tout T_Adresse_IP est convertible).
   -- Postconditions : Renvoie une chaîne standard contenant l'adresse IP parsée.
   function IP_To_String (IP : T_Adresse_IP) return String;

end Types_Definitions;