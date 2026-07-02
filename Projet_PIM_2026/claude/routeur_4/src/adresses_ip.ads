------------------------------------------------------------------------
-- Adresses_IP
--
-- Spécification : manipulation des adresses IPv4 sur 32 bits.
--
-- Un type modulaire T_Adresse_IP est utilisé afin que les opérations
-- arithmétiques (notamment les décalages) se fassent naturellement
-- modulo 2**32 sans risque de débordement.
-- Les opérateurs "and" et "or" appliqués à ce type réalisent des
-- opérations bit à bit, ce qui permet d'implémenter directement les
-- masques réseau.
--
-- Invariant de type pour T_Adresse_IP :
--   0 <= IP < 2**32   (garanti par le type modulaire)
--
-- Invariant de type pour un masque valide :
--   Les bits à 1 sont tous consécutifs depuis le bit de poids fort (MSB).
--   Autrement dit : il n'existe pas de bit à 0 suivi d'un bit à 1.
--   Exemple valide   : 11111111.11111111.00000000.00000000  (255.255.0.0)
--   Exemple invalide : 11111111.00000000.11111111.00000000
------------------------------------------------------------------------
package Adresses_IP is

   -- Type principal : adresse IP sur 32 bits, arithmétique modulo 2**32
   type T_Adresse_IP is mod 2 ** 32;

   ------------------------------------------------------------------------
   -- Depuis_Chaine
   --
   -- Convertit une chaîne au format pointé "A.B.C.D" en T_Adresse_IP.
   --
   -- Précondition  : S est de la forme "A.B.C.D" avec A,B,C,D entiers
   --                 dans [0..255], séparés exactement par des points.
   -- Postcondition : résultat = A * 2**24 + B * 2**16 + C * 2**8 + D
   -- Exception     : Constraint_Error si la précondition n'est pas
   --                 satisfaite (format invalide ou octet hors [0..255]).
   ------------------------------------------------------------------------
   function Depuis_Chaine (S : String) return T_Adresse_IP;

   ------------------------------------------------------------------------
   -- Vers_Chaine
   --
   -- Convertit un T_Adresse_IP en sa notation pointée "A.B.C.D".
   --
   -- Précondition  : aucune (tout T_Adresse_IP est valide)
   -- Postcondition : résultat est une chaîne de la forme "A.B.C.D"
   --                 avec A = IP / 2**24, B = (IP / 2**16) mod 256,
   --                      C = (IP / 2**8) mod 256, D = IP mod 256
   --                 et Depuis_Chaine(Vers_Chaine(IP)) = IP
   ------------------------------------------------------------------------
   function Vers_Chaine (IP : T_Adresse_IP) return String;

   ------------------------------------------------------------------------
   -- Correspond
   --
   -- Teste si Destination appartient au sous-réseau défini par
   -- (Reseau, Masque) selon la règle standard :
   --   (Destination and Masque) = (Reseau and Masque)
   --
   -- Précondition  : Masque est un masque valide (bits à 1 consécutifs
   --                 depuis le MSB) — non vérifié à l'exécution pour
   --                 des raisons de performance.
   -- Postcondition : résultat = ((Destination and Masque) = (Reseau and Masque))
   ------------------------------------------------------------------------
   function Correspond (Destination : T_Adresse_IP;
                        Reseau      : T_Adresse_IP;
                        Masque      : T_Adresse_IP) return Boolean;

   ------------------------------------------------------------------------
   -- Longueur_Masque
   --
   -- Retourne le nombre de bits à 1 consécutifs depuis le MSB de Masque
   -- (aussi appelé longueur de préfixe ou CIDR).
   --
   -- Précondition  : Masque est un masque valide (bits à 1 consécutifs
   --                 depuis le MSB). Si ce n'est pas le cas, le résultat
   --                 est le nombre de bits à 1 avant le premier bit à 0.
   -- Postcondition : 0 <= résultat <= 32
   --                 Si Masque = 0             alors résultat = 0
   --                 Si Masque = 2**32 - 1     alors résultat = 32
   ------------------------------------------------------------------------
   function Longueur_Masque (Masque : T_Adresse_IP) return Natural
     with Post => Longueur_Masque'Result <= 32;

end Adresses_IP;
