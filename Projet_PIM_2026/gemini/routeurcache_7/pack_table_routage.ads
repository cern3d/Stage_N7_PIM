with Types_Definitions; use Types_Definitions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Pack_Table_Routage is

   type T_Table_Routage is limited private;

   -- Savoir si la table de routage est vide ou non.
   --
   -- Paramètres
   --     Table : la table de routage à tester
   --
   function Est_Vide (Table : in T_Table_Routage) return Boolean;

   -- Initialiser une table de routage pour qu'elle soit vide.
   --
   -- Paramètres
   --     Table : la table de routage à initialiser
   --
   -- Assure
   --     Est_Vide (Table)
   --
   procedure Initialiser (Table : out T_Table_Routage) with
       Post => Est_Vide (Table);

   -- Insérer une nouvelle route en fin de table (conserve l'ordre de lecture).
   --
   -- Paramètres
   --     Table : la table de routage où enregistrer la route
   --     Route : la route statique à ajouter
   --
   -- Assure
   --     not Est_Vide (Table)
   --
   procedure Enregistrer (Table : in out T_Table_Routage; Route : in T_Route) with
       Post => not Est_Vide (Table);

   -- Trouver l'interface réseau associée à une IP selon l'algorithme du masque le plus long (LPM).
   --
   -- Paramètres
   --     Table   : la table de routage dans laquelle chercher
   --     IP_Dest : l'adresse IP de destination du paquet à router
   --     Interf  : l'interface de sortie trouvée (ou vide si aucune route ne correspond)
   --
   procedure Chercher_Route (Table   : in T_Table_Routage; 
                             IP_Dest : in T_Adresse_IP; 
                             Interf  : out Unbounded_String);

   -- Recherche LPM étendue conçue spécifiquement pour alimenter le cache réseau.
   -- Elle renvoie l'interface, mais aussi le Masque et la Destination exacts de la règle globale.
   --
   -- Paramètres
   --     Table             : la table de routage dans laquelle chercher
   --     IP                : l'adresse IP cible recherchée
   --     Interface_R       : l'interface réseau de sortie trouvée
   --     Masque_Cache      : le masque de sous-réseau de la route LPM sélectionnée
   --     Destination_Cache : l'adresse réseau de la route LPM sélectionnée
   --
   procedure Chercher_Route_Pour_Cache (
      Table             : in T_Table_Routage;
      IP                : in T_Adresse_IP;
      Interface_R       : out Unbounded_String;
      Masque_Cache      : out T_Adresse_IP;
      Destination_Cache : out T_Adresse_IP
   );

   -- Afficher l'intégralité des routes de la table sur la sortie standard.
   --
   -- Paramètres
   --     Table : la table de routage à afficher
   --
   procedure Afficher_Table (Table : in T_Table_Routage);

   -- Libérer proprement toute la mémoire allouée dynamiquement pour les routes de la table.
   --
   -- Paramètres
   --     Table : la table de routage à vider
   --
   -- Assure
   --     Est_Vide (Table)
   --
   procedure Vider (Table : in out T_Table_Routage) with
       Post => Est_Vide (Table);

private

   type T_Cellule;
   type T_Lien is access T_Cellule;
   
   type T_Cellule is record
      Route   : T_Route;
      Suivant : T_Lien;
   end record;
   
   type T_Table_Routage is record
      Tete  : T_Lien := null;
      Queue : T_Lien := null;
   end record;

   -- Implémentation de la fonction expression pour le contrat
   function Est_Vide (Table : in T_Table_Routage) return Boolean is (Table.Tete = null);

end Pack_Table_Routage;