-- Package utilitaire pour les opérations sur les adresses IP
with Types_Routeur;
use Types_Routeur;

package IP_Utils is

   -- Supprime les espaces et caractères de contrôle en début et fin de chaîne.
   -- Paramètres:
   --   S : chaîne à nettoyer.
   -- Résultat:
   --   chaîne sans espaces ni retours chariot aux extrémités.
   function Trim_Line(S : String) return String;

   -- Analyse une chaîne au format X.X.X.X et retourne l'adresse IP 32 bits.
   -- Si la chaîne n'est pas correcte, la fonction retourne 0.
   function Parse_IP(S : String) return T_Address_IP;

   -- Convertit une adresse IP 32 bits en chaîne au format X.X.X.X.
   function IP_To_String(I : T_Address_IP) return String;

   -- Retourne le nombre de bits à 1 dans un masque IP.
   -- Exemple: 255.255.255.0 -> 24.
   function Mask_Length(M : T_Address_IP) return Integer;

end IP_Utils;
