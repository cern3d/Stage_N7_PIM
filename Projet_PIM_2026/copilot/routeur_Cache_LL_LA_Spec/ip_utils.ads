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
   --     Trim_Line'Result ne commence ni ne termine par des espaces, CR ou LF
   function Trim_Line(S : String) return String
     with Post => (Trim_Line'Result'Length = 0 or else
                   (Trim_Line'Result(Trim_Line'Result'First) /= ' ' and
                    Trim_Line'Result(Trim_Line'Result'Last) /= ' '));

   -- Analyse une chaîne au format X.X.X.X et retourne l'adresse IP 32 bits.
   --
   -- paramètres
   --     S : chaîne représentant une adresse IPv4
   --
   -- Assure
   --     Parse_IP'Result est une adresse IP valide ou 0 en cas d'erreur
   function Parse_IP(S : String) return T_Address_IP
     with Post => Parse_IP'Result < 2 ** 32;

   -- Convertit une adresse IP 32 bits en chaîne au format X.X.X.X.
   --
   -- paramètres
   --     I : adresse IP codée sur 32 bits
   --
   -- Assure
   --     le résultat est une chaîne non vide représentant l'adresse IPv4
   function IP_To_String(I : T_Address_IP) return String
     with Post => IP_To_String'Result'Length > 0;

   -- Retourne le nombre de bits à 1 dans un masque IP.
   --
   -- paramètres
   --     M : masque IP codé sur 32 bits
   --
   -- Assure
   --     le résultat est la longueur du préfixe de masque
   function Mask_Length(M : T_Address_IP) return Integer
     with Post => Mask_Length'Result >= 0;

end IP_Utils;
