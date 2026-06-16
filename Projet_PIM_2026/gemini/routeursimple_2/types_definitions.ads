with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Types_Definitions is

   -- Type IP sous forme d'entier naturel modulo 2**32 (32 bits) 
   type T_Adresse_IP is mod 2**32;

   -- Structure représentant une route complète [cite: 16, 45]
   type T_Route is record
      Destination : T_Adresse_IP;   -- Adresse réseau de destination [cite: 45]
      Masque      : T_Adresse_IP;   -- Masque de sous-réseau [cite: 45]
      Interface_R : Unbounded_String; -- Interface de sortie associée [cite: 45, 161]
   end record;

   -- Fonctions utilitaires de conversion de types
   function String_To_IP (S : String) return T_Adresse_IP;
   function IP_To_String (IP : T_Adresse_IP) return String;

end Types_Definitions;