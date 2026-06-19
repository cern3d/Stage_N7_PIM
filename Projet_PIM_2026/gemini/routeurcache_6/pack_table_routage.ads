with Types_Definitions; use Types_Definitions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Pack_Table_Routage is

   type T_Table_Routage is limited private;

   ----------------------------------------------------------------------------
   -- FONCTIONS ET PROCEDURES DE LA TABLE
   ----------------------------------------------------------------------------

   -- Rôle : Initialise une table de routage à vide. [cite: 14]
   -- Postconditions : La table est prête à l'emploi (Tete et Queue à null).
   procedure Initialiser (Table : out T_Table_Routage); 

   -- Rôle : Insère une nouvelle route en fin de table (conserve l'ordre de lecture). [cite: 15]
   -- Préconditions  : La table a été initialisée.
   -- Postconditions : La route est chaînée à la toute fin de la structure.
   procedure Enregistrer (Table : in out T_Table_Routage; Route : in T_Route);

   -- Rôle : Recherche l'interface réseau selon l'algorithme du masque le plus long (LPM). [cite: 16]
   -- Paramètres     : IP_Dest -> L'IP du paquet à aiguiller.
   --                  Interf  -> Reçoit le nom de l'interface ou reste vide si non trouvé.
   -- Postconditions : Si plusieurs routes correspondent, seule celle au masque le plus grand est retenue.
   procedure Chercher_Route (Table   : in T_Table_Routage; 
                             IP_Dest : in T_Adresse_IP; 
                             Interf  : out Unbounded_String);

   -- Rôle : Recherche LPM étendue conçue spécifiquement pour alimenter le cache réseau. [cite: 19]
   -- Paramètres     : Donne en sortie l'interface, mais aussi le Masque et la Destination exacts
   --                  de la règle globale pour pouvoir peupler proprement le cache.
   procedure Chercher_Route_Pour_Cache (
      Table             : in T_Table_Routage;
      IP                : in T_Adresse_IP;
      Interface_R       : out Unbounded_String;
      Masque_Cache      : out T_Adresse_IP;
      Destination_Cache : out T_Adresse_IP
   );

   -- Rôle : Imprime l'ensemble des routes de la table sur le terminal. [cite: 17]
   procedure Afficher_Table (Table : in T_Table_Routage);

   -- Rôle : Libère l'intégralité de la mémoire allouée dynamiquement pour les routes. [cite: 18]
   -- Postconditions : La table revient à un état vide identique après un appel à Initialiser.
   procedure Vider (Table : in out T_Table_Routage); 

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

end Pack_Table_Routage;