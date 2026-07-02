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
   -- Principe (§1.4.2) : on cherche le masque le plus long M (> Long_Min)
   -- existant dans la table, tel que le RESEAU DE LA ROUTE CANDIDATE soit
   -- dans le même sous-réseau /Long_Min que Dest.
   --
   -- Autrement dit : la route candidate (net_c, mask_c) est "dans la même
   -- branche" que la route LPM sélectionnée si et seulement si :
   --     (net_c AND masque_de_long(Long_Min))
   --       = (Dest AND masque_de_long(Long_Min))
   -- ce qui s'écrit : Correspond(net_c, Dest, masque_de_long(Long_Min)).
   --
   -- Cette formulation couvre les deux cas du sujet :
   --
   -- Exemple du sujet : Dest=147.127.25.12, route LPM=/16 (147.127.0.0).
   --   Candidate /24 = 147.127.18.0 :
   --     147.127.18.0 AND 255.255.0.0 = 147.127.0.0
   --     147.127.25.12 AND 255.255.0.0 = 147.127.0.0  -> MEME -> retenu.
   --   -> Long_Res = 24, cache = 147.127.25.0/24 eth1. CORRECT.
   --
   -- Exemple utilisateur : Dest=212.212.212.212, route LPM=/8 (212.0.0.0).
   --   Candidate /24 = 147.127.18.0 :
   --     147.127.18.0 AND 255.0.0.0 = 147.0.0.0
   --     212.212.212.212 AND 255.0.0.0 = 212.0.0.0  -> DIFFERENT -> ignore.
   --   -> Long_Res reste 8, cache = 212.0.0.0/8 eth3. CORRECT.
   procedure Masque_Discriminant (Table      :     T_Table;
                                  Dest       :     T_Adresse_IP;
                                  Long_Min   :     Natural;
                                  Long_Res   : out Natural;
                                  Masque_Res : out T_Adresse_IP) is
      Courant : T_Pointeur := Table.Tete;
      Long_C  : Natural;

      -- Construire le masque de N bits (N premiers bits à 1 depuis le MSB)
      function Masque_De_Long (N : Natural) return T_Adresse_IP is
      begin
         if N = 0 then
            return 0;
         elsif N >= 32 then
            return T_Adresse_IP'Last;
         else
            return T_Adresse_IP'Last - (2 ** (32 - N) - 1);
         end if;
      end Masque_De_Long;

      -- Masque de la route LPM sélectionnée (sert à tester l'appartenance
      -- au même sous-réseau /Long_Min)
      Masque_LPM : constant T_Adresse_IP := Masque_De_Long (Long_Min);

   begin
      -- Partir du masque de la route LPM sélectionnée
      Long_Res   := Long_Min;
      Masque_Res := Masque_LPM;

      -- Parcourir la table pour trouver un masque plus long dans la même
      -- branche (sous-réseau /Long_Min) que Dest
      while Courant /= null loop
         Long_C := Longueur_Masque (Courant.Route.Masque);

         -- Le masque candidat est-il plus long que ce qu'on a retenu,
         -- et le réseau candidat tombe-t-il dans le même /Long_Min que Dest ?
         if Long_C > Long_Res
            and then Correspond (Courant.Route.Destination, Dest, Masque_LPM)
         then
            Long_Res   := Long_C;
            Masque_Res := Courant.Route.Masque;
         end if;
         Courant := Courant.Suivant;
      end loop;
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
