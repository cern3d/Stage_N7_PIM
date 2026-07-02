with Types_Definitions; use Types_Definitions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Pack_Table_Routage is

   type T_Table_Routage is limited private;

   -- Initialise une table vide
   procedure Initialiser (Table : out T_Table_Routage);

   -- Insère une nouvelle route en fin de table (conserve l'ordre de lecture) [cite: 157, 216]
   procedure Enregistrer (Table : in out T_Table_Routage; Route : in T_Route);

   -- Algorithme de routage : Recherche le masque le plus long valide [cite: 41, 67]
   procedure Chercher_Route (Table   : in T_Table_Routage; 
                             IP_Dest : in T_Adresse_IP; 
                             Interf  : out Unbounded_String);

   -- Affiche l'intégralité de la table sur la sortie standard [cite: 194]
   procedure Afficher_Table (Table : in T_Table_Routage);

   -- Libère proprement la mémoire allouée dynamiquement [cite: 359]
   procedure Vider (Table : in out T_Table_Routage);

   procedure Chercher_Route_Pour_Cache (
   Table             : in T_Table_Routage;
   IP                : in T_Adresse_IP;
   Interface_R       : out Unbounded_String;
   Masque_Cache      : out T_Adresse_IP;
   Destination_Cache : out T_Adresse_IP
);

private

   type T_Cellule;
   type T_Lien is access T_Cellule;
   type T_Cellule is record
      Route   : T_Route;
      Suivant : T_Lien;
   end record;

   type T_Table_Routage is record
      Tete : T_Lien := null;
      Queue : T_Lien := null;
   end record;

end Pack_Table_Routage;