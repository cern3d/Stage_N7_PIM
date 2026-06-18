-- Tables_Routage : TAD liste chaînée de routes
-- Chaque route est un triplet (Destination, Masque, Interface).
-- La recherche applique la règle du masque le plus long (LPM).

with Adresses_IP; use Adresses_IP;

package Tables_Routage is

   -- Longueur maximale d'un nom d'interface (ex: "eth0")
   Max_Interface : constant := 32;
   subtype T_Interface is String (1 .. Max_Interface);

   -- Une route dans la table
   type T_Route is record
      Destination : T_Adresse_IP;
      Masque      : T_Adresse_IP;
      Iface       : T_Interface;
      Iface_Len   : Natural;       -- longueur réelle du nom d'interface
   end record;

   -- Type opaque : liste chaînée de routes
   type T_Table is limited private;

   -- Initialiser une table vide
   procedure Initialiser (Table : out T_Table);

   -- Libérer la mémoire de la table
   procedure Finaliser (Table : in out T_Table);

   -- Ajouter une route à la fin de la table
   procedure Ajouter (Table       : in out T_Table;
                      Destination :        T_Adresse_IP;
                      Masque      :        T_Adresse_IP;
                      Iface       :        String);

   -- Chercher la meilleure route pour Destination (masque le plus long).
   -- Retourne True et remplit Route si une route a été trouvée.
   function Chercher (Table       :     T_Table;
                      Destination :     T_Adresse_IP;
                      Route       : out T_Route) return Boolean;

   -- Trouver le masque le plus long dans la table pour lequel
   -- Destination NE correspond PAS à la route associée,
   -- et dont la longueur est > Long_Min.
   -- Résultat dans Long_Res et Masque_Res.
   -- Si aucun tel masque n'existe, Long_Res reste égal à Long_Min.
   -- Utilisé pour construire les routes mises en cache (§1.4.2).
   procedure Masque_Discriminant (Table      :     T_Table;
                                  Dest       :     T_Adresse_IP;
                                  Long_Min   :     Natural;
                                  Long_Res   : out Natural;
                                  Masque_Res : out T_Adresse_IP);

   -- Afficher toutes les routes sur la sortie standard
   procedure Afficher (Table : T_Table);

   -- Retourner le nombre de routes dans la table
   function Taille (Table : T_Table) return Natural;

private

   type T_Cellule;
   type T_Pointeur is access T_Cellule;

   type T_Cellule is record
      Route   : T_Route;
      Suivant : T_Pointeur := null;
   end record;

   type T_Table is limited record
      Tete      : T_Pointeur := null;
      Nb_Routes : Natural    := 0;
   end record;

end Tables_Routage;
