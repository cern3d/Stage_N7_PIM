with Types_Definitions; use Types_Definitions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Pack_Cache_Arbre is

   type T_Cache is limited private;

   -- Initialise le cache avec sa taille et sa politique
   procedure Initialiser (Cache      : out T_Cache; 
                          Taille_Max : in Integer; 
                          Politique  : in T_Politique);

   -- Cherche une IP dans le cache (recherche du plus long préfixe correspondant)
   procedure Chercher_Cache (Cache   : in out T_Cache; 
                             IP_Dest : in T_Adresse_IP; 
                             Interf  : out Unbounded_String;
                             Trouve  : out Boolean);

   -- Ajoute une route dans l'arbre à la profondeur correspondant à son masque
   procedure Ajouter_Cache (Cache : in out T_Cache; Route : in T_Route_Cache);

   -- Affiche le contenu du cache (parcours de l'arbre)
   procedure Afficher_Cache (Cache : in T_Cache);

   -- Libère la mémoire de l'arbre
   procedure Vider (Cache : in out T_Cache);

private

   type T_Noeud;
   type T_Arbre is access T_Noeud;
   
   type T_Noeud is record
      Est_Route   : Boolean := False; -- Vrai si ce nœud contient une route valide
      Route       : T_Route_Cache;
      Fils_Gauche : T_Arbre := null;  -- Branche pour le bit 0
      Fils_Droit  : T_Arbre := null;  -- Branche pour le bit 1
   end record;

   type T_Cache is record
      Racine     : T_Arbre := null;
      Taille_Max : Integer := 10;
      Taille_Act : Integer := 0;
      Politique  : T_Politique := FIFO;
      Compteur   : Natural := 0; -- Horloge globale pour les politiques d'éviction
   end record;

end Pack_Cache_Arbre;