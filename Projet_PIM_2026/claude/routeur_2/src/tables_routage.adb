with Ada.Unchecked_Deallocation;
with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Strings.Fixed;   use Ada.Strings.Fixed;
with Ada.Strings;         use Ada.Strings;

package body Tables_Routage is

   procedure Liberer is new Ada.Unchecked_Deallocation (T_Cellule, T_Pointeur);

   -- Construire un T_Route à partir des paramètres
   function Creer_Route (Destination : T_Adresse_IP;
                         Masque      : T_Adresse_IP;
                         Iface       : String) return T_Route is
      R : T_Route;
      L : constant Natural := Natural'Min (Iface'Length, Max_Interface);
   begin
      R.Destination := Destination;
      R.Masque      := Masque;
      R.Iface       := (others => ' ');
      R.Iface_Len   := L;
      R.Iface (1 .. L) := Iface (Iface'First .. Iface'First + L - 1);
      return R;
   end Creer_Route;

   ------------------
   -- Initialiser  --
   ------------------
   procedure Initialiser (Table : out T_Table) is
   begin
      Table.Tete      := null;
      Table.Nb_Routes := 0;
   end Initialiser;

   ----------------
   -- Finaliser  --
   ----------------
   procedure Finaliser (Table : in out T_Table) is
      Courant : T_Pointeur := Table.Tete;
      Suivant : T_Pointeur;
   begin
      while Courant /= null loop
         Suivant := Courant.Suivant;
         Liberer (Courant);
         Courant := Suivant;
      end loop;
      Table.Tete      := null;
      Table.Nb_Routes := 0;
   end Finaliser;

   --------------
   -- Ajouter  --
   --------------
   procedure Ajouter (Table       : in out T_Table;
                      Destination :        T_Adresse_IP;
                      Masque      :        T_Adresse_IP;
                      Iface       :        String) is
      Nouvelle : constant T_Pointeur := new T_Cellule'
         (Route   => Creer_Route (Destination, Masque, Iface),
          Suivant => null);
      Courant  : T_Pointeur;
   begin
      if Table.Tete = null then
         Table.Tete := Nouvelle;
      else
         Courant := Table.Tete;
         while Courant.Suivant /= null loop
            Courant := Courant.Suivant;
         end loop;
         Courant.Suivant := Nouvelle;
      end if;
      Table.Nb_Routes := Table.Nb_Routes + 1;
   end Ajouter;

   ---------------
   -- Chercher  --
   ---------------
   function Chercher (Table       :     T_Table;
                      Destination :     T_Adresse_IP;
                      Route       : out T_Route) return Boolean is
      Courant       : T_Pointeur := Table.Tete;
      Meilleur_Long : Integer    := -1;
      Trouve        : Boolean    := False;
      Long_Courant  : Natural;
   begin
      while Courant /= null loop
         if Correspond (Destination,
                        Courant.Route.Destination,
                        Courant.Route.Masque)
         then
            Long_Courant := Longueur_Masque (Courant.Route.Masque);
            if Long_Courant > Meilleur_Long then
               Meilleur_Long := Long_Courant;
               Route         := Courant.Route;
               Trouve        := True;
            end if;
         end if;
         Courant := Courant.Suivant;
      end loop;
      return Trouve;
   end Chercher;

   --------------------------
   -- Masque_Discriminant  --
   --------------------------
   -- Chercher dans la table le plus long masque M tel que :
   --   1. Longueur(M) > Long_Min
   --   2. (Dest and M) /= (Destination_Route and M)
   --      c'est-à-dire que Dest NE correspond PAS à cette route
   -- Un tel masque garantit que la route mise en cache ne sera jamais
   -- confondue avec la route de cette ligne.
   -- Si aucun masque ne satisfait ces conditions, Long_Res = Long_Min.
   procedure Masque_Discriminant (Table      :     T_Table;
                                  Dest       :     T_Adresse_IP;
                                  Long_Min   :     Natural;
                                  Long_Res   : out Natural;
                                  Masque_Res : out T_Adresse_IP) is
      Courant : T_Pointeur := Table.Tete;
      Long_C  : Natural;
   begin
      Long_Res   := Long_Min;
      Masque_Res := Adresses_IP.T_Adresse_IP'Last; -- valeur sentinelle
      -- On va chercher le masque le plus long qui discrimine
      while Courant /= null loop
         Long_C := Longueur_Masque (Courant.Route.Masque);
         -- Ce masque est-il plus long que ce qu'on a retenu,
         -- et la route associée NE correspond-elle PAS à Dest ?
         if Long_C > Long_Res
            and then not Correspond (Dest,
                                     Courant.Route.Destination,
                                     Courant.Route.Masque)
         then
            Long_Res   := Long_C;
            Masque_Res := Courant.Route.Masque;
         end if;
         Courant := Courant.Suivant;
      end loop;

      -- Si aucun masque discriminant trouvé, Masque_Res doit correspondre
      -- à Long_Min. On construit le masque à partir de Long_Min.
      if Long_Res = Long_Min then
         -- Reconstruire le masque correspondant à Long_Min bits
         if Long_Min = 0 then
            Masque_Res := 0;
         elsif Long_Min >= 32 then
            Masque_Res := T_Adresse_IP'Last;
         else
            -- Long_Min bits à 1 en partant du MSB
            -- 2**32 - 2**(32-Long_Min) en arithmétique modulo
            Masque_Res := T_Adresse_IP'Last - (2 ** (32 - Long_Min) - 1);
         end if;
      end if;
   end Masque_Discriminant;

   ---------------
   -- Afficher  --
   ---------------
   procedure Afficher (Table : T_Table) is
      Courant : T_Pointeur := Table.Tete;
   begin
      while Courant /= null loop
         Put_Line (Vers_Chaine (Courant.Route.Destination) & " "
                   & Vers_Chaine (Courant.Route.Masque)    & " "
                   & Trim (Courant.Route.Iface
                             (1 .. Courant.Route.Iface_Len), Right));
         Courant := Courant.Suivant;
      end loop;
   end Afficher;

   ------------
   -- Taille --
   ------------
   function Taille (Table : T_Table) return Natural is
   begin
      return Table.Nb_Routes;
   end Taille;

end Tables_Routage;
