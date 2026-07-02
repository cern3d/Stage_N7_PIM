-- Package utilitaire pour les opérations sur les adresses IP
with Types_Routeur;
use Types_Routeur;

package IP_Utils is

   -- Supprime les espaces et caractères de contrôle d'une chaîne
   function Trim_Line(S : String) return String;

   -- Parse une chaîne au format X.X.X.X en adresse IP
   function Parse_IP(S : String) return T_Address_IP;

   -- Convertit une adresse IP en chaîne format X.X.X.X
   function IP_To_String(I : T_Address_IP) return String;

   -- Retourne la longueur du masque (nombre de bits à 1)
   function Mask_Length(M : T_Address_IP) return Integer;

end IP_Utils;
