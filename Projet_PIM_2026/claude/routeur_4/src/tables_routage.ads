------------------------------------------------------------------------
-- Tables_Routage
--
-- Spécification : TAD table de routage implantée par une liste chaînée.
--
-- Une table de routage est une séquence ordonnée de routes.
-- Chaque route est un triplet (Destination, Masque, Interface).
--
-- Invariants du type T_Table (non vérifiables sans itérateur public) :
--   * Nb_Routes = longueur de la liste chaînée (nombre de nœuds)
--   * Tous les champs Iface_Len vérifient 0 < Iface_Len <= Max_Interface
--
-- Algorithme de recherche : Longest Prefix Match (LPM)
--   Pour une adresse Dest, on parcourt toutes les routes et on retient
--   celle dont le masque est le plus long parmi celles qui vérifient
--   Correspond(Dest, Route.Destination, Route.Masque).
------------------------------------------------------------------------
with Adresses_IP; use Adresses_IP;

package Tables_Routage is

   -- Longueur maximale d'un nom d'interface (ex : "eth0", "lo")
   Max_Interface : constant := 32;
   subtype T_Interface is String (1 .. Max_Interface);

   -- Invariant de T_Route :
   --   0 < Iface_Len <= Max_Interface
   --   Masque est un masque valide (bits à 1 consécutifs depuis le MSB)
   type T_Route is record
      Destination : T_Adresse_IP;
      Masque      : T_Adresse_IP;
      Iface       : T_Interface;
      Iface_Len   : Natural;
   end record;

   -- Type abstrait : liste chaînée de T_Route, accès en lecture seule
   -- depuis l'extérieur du package.
   type T_Table is limited private;

   ------------------------------------------------------------------------
   -- Initialiser
   --
   -- Précondition  : aucune
   -- Postcondition : Taille(Table) = 0
   --                 Table est vide (aucune route)
   ------------------------------------------------------------------------
   procedure Initialiser (Table : out T_Table);

   ------------------------------------------------------------------------
   -- Finaliser
   --
   -- Libère toute la mémoire dynamique allouée par la table.
   --
   -- Précondition  : Table a été initialisée
   -- Postcondition : Taille(Table) = 0 ; toute la mémoire est libérée
   ------------------------------------------------------------------------
   procedure Finaliser (Table : in out T_Table);

   ------------------------------------------------------------------------
   -- Ajouter
   --
   -- Insère une nouvelle route EN QUEUE de la liste, en préservant
   -- l'ordre d'insertion (identique à l'ordre du fichier de configuration).
   --
   -- Précondition  : Table a été initialisée
   --                 0 < Iface'Length <= Max_Interface
   -- Postcondition : Taille(Table) = Taille(Table)@avant + 1
   --                 La nouvelle route est la dernière de la liste
   ------------------------------------------------------------------------
   procedure Ajouter (Table       : in out T_Table;
                      Destination :        T_Adresse_IP;
                      Masque      :        T_Adresse_IP;
                      Iface       :        String)
     with Pre => Iface'Length > 0 and then Iface'Length <= Max_Interface;

   ------------------------------------------------------------------------
   -- Chercher
   --
   -- Applique l'algorithme LPM (Longest Prefix Match) sur Table pour
   -- l'adresse Destination et retourne la route correspondante.
   --
   -- Précondition  : Table a été initialisée
   -- Postcondition :
   --   Si résultat = True :
   --     Correspond(Destination, Route.Destination, Route.Masque) = True
   --     Pour toute route R de Table vérifiant Correspond(Destination,…) :
   --       Longueur_Masque(Route.Masque) >= Longueur_Masque(R.Masque)
   --   Si résultat = False :
   --     Aucune route de Table ne correspond à Destination
   ------------------------------------------------------------------------
   function Chercher (Table       :     T_Table;
                      Destination :     T_Adresse_IP;
                      Route       : out T_Route) return Boolean;

   ------------------------------------------------------------------------
   -- Masque_Discriminant
   --
   -- Calcule le masque à utiliser pour la route mise en cache, conformément
   -- au §1.4.2 du sujet.
   --
   -- Principe : on cherche le masque le plus long M (> Long_Min) existant
   -- dans la table, tel que le réseau de la route candidate soit dans le
   -- MÊME sous-réseau /Long_Min que Dest :
   --
   --   Correspond(candidate.Destination, Dest, Masque_De_Long(Long_Min))
   --
   -- Cette condition garantit que le masque retenu est pertinent pour
   -- discriminer des routes dans la MÊME branche de l'arbre de préfixes
   -- que la route LPM sélectionnée.
   --
   -- Précondition  : Table a été initialisée
   --                 Long_Min <= 32
   --                 Long_Min = Longueur_Masque(masque de la route LPM)
   -- Postcondition :
   --   Long_Res >= Long_Min
   --   Long_Res <= 32
   --   Masque_Res = masque dont la longueur est Long_Res
   --   Si Long_Res = Long_Min : aucune route candidate plus spécifique
   --     n'a été trouvée dans la même branche
   --   Si Long_Res > Long_Min : il existe dans Table une route de masque
   --     Long_Res dont le réseau est dans le même /Long_Min que Dest
   ------------------------------------------------------------------------
   procedure Masque_Discriminant (Table      :     T_Table;
                                  Dest       :     T_Adresse_IP;
                                  Long_Min   :     Natural;
                                  Long_Res   : out Natural;
                                  Masque_Res : out T_Adresse_IP)
     with Pre  => Long_Min <= 32,
          Post => Long_Res >= Long_Min and then Long_Res <= 32;

   ------------------------------------------------------------------------
   -- Afficher
   --
   -- Affiche sur la sortie standard toutes les routes de la table dans
   -- leur ordre d'insertion, au format :
   --   "<destination> <masque> <interface>"
   --
   -- Précondition  : Table a été initialisée
   -- Postcondition : Table est inchangée
   ------------------------------------------------------------------------
   procedure Afficher (Table : T_Table);

   ------------------------------------------------------------------------
   -- Taille
   --
   -- Retourne le nombre de routes dans la table.
   --
   -- Précondition  : Table a été initialisée
   -- Postcondition : résultat >= 0
   ------------------------------------------------------------------------
   function Taille (Table : T_Table) return Natural
     with Post => Taille'Result >= 0;

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
