-- Adresses_IP : manipulation des adresses IP 32 bits
-- Fournit le type T_Adresse_IP et les opérations associées.

package Adresses_IP is

   -- Une adresse IP est un entier naturel de 32 bits (calculs modulo 2**32)
   type T_Adresse_IP is mod 2 ** 32;

   -- Convertir une adresse IP depuis sa notation pointée (ex: "147.127.18.0")
   -- Lève Constraint_Error si la chaîne n'est pas valide
   function Depuis_Chaine (S : String) return T_Adresse_IP;

   -- Convertir une adresse IP vers sa notation pointée
   function Vers_Chaine (IP : T_Adresse_IP) return String;

   -- Appliquer un masque : tester si Destination correspond à Reseau/Masque
   -- (Destination and Masque) = (Reseau and Masque)
   function Correspond (Destination : T_Adresse_IP;
                        Reseau      : T_Adresse_IP;
                        Masque      : T_Adresse_IP) return Boolean;

   -- Calculer la longueur d'un masque (nombre de bits à 1 consécutifs depuis le MSB)
   function Longueur_Masque (Masque : T_Adresse_IP) return Natural;

end Adresses_IP;
