-- Package utilitaire pour les opérations sur les adresses IP
with Types_Routeur;
use Types_Routeur;

package IP_Utils is

   -- Supprime les espaces et caractères de contrôle en début et fin de chaîne.
   --
   -- paramètres
   --     S : chaîne à nettoyer
   --
   -- Assure
   --     Trim_Line(S) ne commence ni ne termine par des espaces, CR ou LF
   function Trim_Line(S : String) return String;

   -- Analyse une chaîne au format X.X.X.X et retourne l'adresse IP 32 bits.
   --
   -- paramètres
   --     S : chaîne représentant une adresse IPv4
   --
   -- Assure
   --     Parse_IP(S) renvoie la valeur 0 si la chaîne est invalide
   function Parse_IP(S : String) return T_Address_IP;

   -- Convertit une adresse IP 32 bits en chaîne au format X.X.X.X.
   --
   -- paramètres
   --     I : adresse IP codée sur 32 bits
   --
   -- Assure
   --     le résultat est une chaîne décimale séparée par des points
   function IP_To_String(I : T_Address_IP) return String;

   -- Retourne le nombre de bits à 1 dans un masque IP.
   --
   -- paramètres
   --     M : masque IP codé sur 32 bits
   --
   -- Assure
   --     le résultat est la longueur du préfixe de masque
   function Mask_Length(M : T_Address_IP) return Integer;

end IP_Utils;
