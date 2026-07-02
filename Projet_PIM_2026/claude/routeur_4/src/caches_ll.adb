with Ada.Unchecked_Deallocation;
with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings;       use Ada.Strings;

package body Caches_LL is

   procedure Liberer is
      new Ada.Unchecked_Deallocation (T_Cellule_Cache, T_Ptr_Cache);

   -- Retourner le nom d'interface sans espaces de remplissage
   function Iface_Str (R : T_Route) return String is
   begin
      pragma Assert (R.Iface_Len > 0 and then R.Iface_Len <= Max_Interface,
                     "Iface_Str : Iface_Len hors bornes");
      return Trim (R.Iface (1 .. R.Iface_Len), Right);
   end Iface_Str;

   ------------------
   -- Initialiser  --
   ------------------
   procedure Initialiser (Cache      : out T_Cache;
                          Taille_Max :     Natural;
                          Pol        :     T_Politique) is
   begin
      Cache.Tete       := null;
      Cache.Nb_Entrees := 0;
      Cache.Taille_Max := Taille_Max;
      Cache.Pol        := Pol;
      Cache.Seq_Global := 0;
      Cache.Stats      := (Nb_Demandes  => 0,
                           Nb_Hits      => 0,
                           Nb_Defauts   => 0,
                           Nb_Evictions => 0);
      -- Postcondition : invariants (I1)..(I4)
      pragma Assert (Cache.Nb_Entrees = 0,  "Initialiser : Nb_Entrees /= 0");
      pragma Assert (Cache.Seq_Global = 0,  "Initialiser : Seq_Global /= 0");
   end Initialiser;

   ----------------
   -- Finaliser  --
   ----------------
   procedure Finaliser (Cache : in out T_Cache) is
      Courant : T_Ptr_Cache := Cache.Tete;
      Suivant : T_Ptr_Cache;
   begin
      while Courant /= null loop
         Suivant := Courant.Suivant;
         Liberer (Courant);
         Courant := Suivant;
      end loop;
      Cache.Tete       := null;
      Cache.Nb_Entrees := 0;
      -- Postcondition
      pragma Assert (Cache.Nb_Entrees = 0 and then Cache.Tete = null,
                     "Finaliser : cache non vide apres liberation");
   end Finaliser;

   -- Incrémenter l'horloge logique globale et retourner la nouvelle valeur.
   -- Postcondition : Seq = Cache.Seq_Global@avant + 1
   procedure Tick (Cache : in out T_Cache; Seq : out Natural) is
   begin
      Cache.Seq_Global := Cache.Seq_Global + 1;
      Seq              := Cache.Seq_Global;
      pragma Assert (Seq > 0, "Tick : Seq_Global debordement");
   end Tick;

   ---------------
   -- Chercher  --
   ---------------
   function Chercher (Cache       : in out T_Cache;
                      Destination :        T_Adresse_IP;
                      Route       :    out T_Route) return Boolean is
      Courant        : T_Ptr_Cache := Cache.Tete;
      Seq            : Natural;
      Dem_Avant      : constant Natural := Cache.Stats.Nb_Demandes;
   begin
      Cache.Stats.Nb_Demandes := Cache.Stats.Nb_Demandes + 1;

      while Courant /= null loop
         if Correspond (Destination,
                        Courant.Route.Destination,
                        Courant.Route.Masque)
         then
            -- Hit : mettre à jour les compteurs LRU et LFU
            Tick (Cache, Seq);
            Courant.Seq_Dernier     := Seq;
            Courant.Nb_Utilisations := Courant.Nb_Utilisations + 1;
            Cache.Stats.Nb_Hits     := Cache.Stats.Nb_Hits + 1;
            Route := Courant.Route;
            -- Postcondition (hit)
            pragma Assert (Correspond (Destination, Route.Destination, Route.Masque),
                           "Chercher : route retournee ne correspond pas");
            pragma Assert (Cache.Stats.Nb_Demandes = Dem_Avant + 1,
                           "Chercher : Nb_Demandes non incremente");
            return True;
         end if;
         Courant := Courant.Suivant;
      end loop;

      Cache.Stats.Nb_Defauts := Cache.Stats.Nb_Defauts + 1;
      -- Postcondition (miss)
      pragma Assert (Cache.Stats.Nb_Demandes = Dem_Avant + 1,
                     "Chercher : Nb_Demandes non incremente (miss)");
      return False;
   end Chercher;

   -- Expulser la victime selon la politique courante.
   -- Précondition : Cache.Nb_Entrees > 0
   -- Postcondition : Cache.Nb_Entrees = Cache.Nb_Entrees@avant - 1
   --                 Cache.Stats.Nb_Evictions incrémenté de 1
   procedure Expulser (Cache : in out T_Cache) is
      Pred_Victime : T_Ptr_Cache := null;
      Victime      : T_Ptr_Cache := Cache.Tete;
      Pred_Courant : T_Ptr_Cache := null;
      Courant      : T_Ptr_Cache := Cache.Tete;
      Val_Victime  : Natural     := Natural'Last;
      Val_Courant  : Natural;
      Nb_Avant     : constant Natural := Cache.Nb_Entrees;
   begin
      pragma Assert (Cache.Nb_Entrees > 0, "Expulser : cache vide");

      -- Trouver la victime (entrée de valeur minimale selon la politique)
      while Courant /= null loop
         case Cache.Pol is
            when FIFO => Val_Courant := Courant.Seq_Insertion;
            when LRU  => Val_Courant := Courant.Seq_Dernier;
            when LFU  => Val_Courant := Courant.Nb_Utilisations;
         end case;
         if Val_Courant < Val_Victime then
            Val_Victime  := Val_Courant;
            Victime      := Courant;
            Pred_Victime := Pred_Courant;
         end if;
         Pred_Courant := Courant;
         Courant      := Courant.Suivant;
      end loop;

      pragma Assert (Victime /= null, "Expulser : aucune victime trouvee");

      -- Retirer la victime de la liste chaînée
      if Pred_Victime = null then
         Cache.Tete := Victime.Suivant;
      else
         Pred_Victime.Suivant := Victime.Suivant;
      end if;

      Liberer (Victime);
      Cache.Nb_Entrees         := Cache.Nb_Entrees - 1;
      Cache.Stats.Nb_Evictions := Cache.Stats.Nb_Evictions + 1;

      -- Postcondition
      pragma Assert (Cache.Nb_Entrees = Nb_Avant - 1,
                     "Expulser : Nb_Entrees incorrect apres eviction");
   end Expulser;

   -- Construire la route à mettre en cache selon §1.4.2.
   -- Précondition  : Route_Ok est la route LPM pour Dest_Orig dans Table
   -- Postcondition : résultat.Masque est le masque discriminant
   --                 résultat.Destination = Dest_Orig AND résultat.Masque
   --                 résultat.Iface = Route_Ok.Iface
   function Construire_Route_Cache (Table     : T_Table;
                                    Dest_Orig : T_Adresse_IP;
                                    Route_Ok  : T_Route) return T_Route is
      Long_Min   : constant Natural := Longueur_Masque (Route_Ok.Masque);
      Long_Res   : Natural;
      Masque_Res : T_Adresse_IP;
      R          : T_Route := Route_Ok;
   begin
      -- Calculer le masque discriminant via Tables_Routage
      Masque_Discriminant (Table, Dest_Orig, Long_Min, Long_Res, Masque_Res);

      pragma Assert (Long_Res >= Long_Min,
                     "Construire_Route_Cache : Long_Res < Long_Min");

      R.Destination := Dest_Orig and Masque_Res;
      R.Masque      := Masque_Res;

      -- Postcondition : l'interface est inchangée
      pragma Assert (R.Iface_Len = Route_Ok.Iface_Len,
                     "Construire_Route_Cache : Iface_Len modifie");
      return R;
   end Construire_Route_Cache;

   --------------
   -- Inserer  --
   --------------
   procedure Inserer (Cache     : in out T_Cache;
                      Table     :        T_Table;
                      Dest_Orig :        T_Adresse_IP;
                      Route_Ok  :        T_Route) is
      Route_Cache : constant T_Route :=
                       Construire_Route_Cache (Table, Dest_Orig, Route_Ok);
      Nouvelle    : T_Ptr_Cache;
      Seq         : Natural;
      Nb_Avant    : constant Natural := Cache.Nb_Entrees;
   begin
      -- Si cache inactif, ne rien faire
      if Cache.Taille_Max = 0 then
         return;
      end if;

      -- Expulser si nécessaire pour respecter la capacité maximale
      if Cache.Nb_Entrees >= Cache.Taille_Max then
         pragma Assert (Cache.Nb_Entrees = Cache.Taille_Max,
                        "Inserer : Nb_Entrees > Taille_Max avant eviction");
         Expulser (Cache);
      end if;

      pragma Assert (Cache.Nb_Entrees < Cache.Taille_Max,
                     "Inserer : cache encore plein apres eviction");

      Tick (Cache, Seq);

      -- Insertion en tête de liste (O(1))
      Nouvelle := new T_Cellule_Cache'
         (Route           => Route_Cache,
          Seq_Insertion   => Seq,
          Seq_Dernier     => Seq,
          Nb_Utilisations => 0,
          Suivant         => Cache.Tete);

      Cache.Tete       := Nouvelle;
      Cache.Nb_Entrees := Cache.Nb_Entrees + 1;

      -- Postcondition
      pragma Assert (Cache.Nb_Entrees <= Cache.Taille_Max,
                     "Inserer : Nb_Entrees > Taille_Max apres insertion");
      pragma Assert (Cache.Nb_Entrees = Natural'Min (Nb_Avant + 1,
                                                     Cache.Taille_Max),
                     "Inserer : Nb_Entrees incorrect");
   end Inserer;

   ---------------
   -- Afficher  --
   ---------------
   procedure Afficher (Cache : T_Cache) is
      Courant : T_Ptr_Cache := Cache.Tete;
   begin
      while Courant /= null loop
         Put_Line (Vers_Chaine (Courant.Route.Destination) & " "
                   & Vers_Chaine (Courant.Route.Masque)    & " "
                   & Iface_Str (Courant.Route));
         Courant := Courant.Suivant;
      end loop;
   end Afficher;

   ------------------
   -- Statistiques --
   ------------------
   function Statistiques (Cache : T_Cache) return T_Stats is
      S : constant T_Stats := Cache.Stats;
   begin
      -- Postcondition : invariant (I3)
      pragma Assert (S.Nb_Demandes = S.Nb_Hits + S.Nb_Defauts,
                     "Statistiques : Nb_Demandes /= Nb_Hits + Nb_Defauts");
      return S;
   end Statistiques;

   ---------------------
   -- Afficher_Stats  --
   ---------------------
   procedure Afficher_Stats (Cache : T_Cache) is
      S : constant T_Stats := Cache.Stats;
   begin
      Put_Line ("Demandes de route : " & Natural'Image (S.Nb_Demandes));
      Put_Line ("Hits (cache)      : " & Natural'Image (S.Nb_Hits));
      Put_Line ("Defauts de cache  : " & Natural'Image (S.Nb_Defauts));
      Put_Line ("Evictions         : " & Natural'Image (S.Nb_Evictions));
      if S.Nb_Demandes > 0 then
         Put_Line ("Taux de hit       : "
                   & Natural'Image (S.Nb_Hits * 100 / S.Nb_Demandes) & "%");
         Put_Line ("Taux de defaut    : "
                   & Natural'Image (S.Nb_Defauts * 100 / S.Nb_Demandes) & "%");
      end if;
   end Afficher_Stats;

end Caches_LL;
