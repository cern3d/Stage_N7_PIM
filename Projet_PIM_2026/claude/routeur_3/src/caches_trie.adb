with Ada.Unchecked_Deallocation;
with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings;       use Ada.Strings;

package body Caches_Trie is

   procedure Liberer is
      new Ada.Unchecked_Deallocation (T_Noeud, T_Ptr_Noeud);

   function Iface_Str (R : T_Route) return String is
   begin
      return Trim (R.Iface (1 .. R.Iface_Len), Right);
   end Iface_Str;

   procedure Tick (Cache : in out T_Cache_Trie; Seq : out Natural) is
   begin
      Cache.Seq_Global := Cache.Seq_Global + 1;
      Seq              := Cache.Seq_Global;
   end Tick;

   ------------------
   -- Initialiser  --
   ------------------
   procedure Initialiser (Cache      : out T_Cache_Trie;
                          Taille_Max :     Natural;
                          Pol        :     T_Politique) is
   begin
      Cache.Racine     := null;
      Cache.Nb_Entrees := 0;
      Cache.Taille_Max := Taille_Max;
      Cache.Pol        := Pol;
      Cache.Seq_Global := 0;
      Cache.Stats      := (Nb_Demandes  => 0,
                           Nb_Hits      => 0,
                           Nb_Defauts   => 0,
                           Nb_Evictions => 0);
   end Initialiser;

   -- Libérer récursivement un sous-arbre
   procedure Liberer_Arbre (Noeud : in out T_Ptr_Noeud) is
   begin
      if Noeud = null then
         return;
      end if;
      Liberer_Arbre (Noeud.Fils (0));
      Liberer_Arbre (Noeud.Fils (1));
      Liberer (Noeud);
   end Liberer_Arbre;

   ----------------
   -- Finaliser  --
   ----------------
   procedure Finaliser (Cache : in out T_Cache_Trie) is
   begin
      Liberer_Arbre (Cache.Racine);
      Cache.Racine     := null;
      Cache.Nb_Entrees := 0;
   end Finaliser;

   ---------------
   -- Chercher  --
   ---------------
   -- Descendre dans le trie bit par bit depuis le MSB (bit 31) de Destination.
   -- À chaque nœud portant une route, mémoriser cette route (LPM).
   -- Retourner la route mémorisée la plus profonde.
   function Chercher (Cache       : in out T_Cache_Trie;
                      Destination :        T_Adresse_IP;
                      Route       :    out T_Route) return Boolean is
      Courant    : T_Ptr_Noeud := Cache.Racine;
      Bit_Pos    : Natural     := 31;   -- on commence au MSB
      Bit_Val    : Natural;
      Derniere   : T_Ptr_Noeud := null; -- nœud avec route le plus profond
      Seq        : Natural;
   begin
      Cache.Stats.Nb_Demandes := Cache.Stats.Nb_Demandes + 1;

      -- Descendre tant qu'il y a un nœud
      loop
         exit when Courant = null;

         if Courant.A_Route then
            Derniere := Courant;
         end if;

         -- Si on a épuisé les 32 bits, on s'arrête
         exit when Bit_Pos > 31; -- garde-fou (ne devrait pas arriver)

         -- Extraire le bit courant de Destination
         Bit_Val := Natural ((Destination / T_Adresse_IP (2 ** Bit_Pos))
                             mod 2);

         -- Descendre vers le fils correspondant
         Courant := Courant.Fils (Bit_Val);

         if Bit_Pos = 0 then
            -- On a traité les 32 bits
            if Courant /= null and then Courant.A_Route then
               Derniere := Courant;
            end if;
            exit;
         end if;
         Bit_Pos := Bit_Pos - 1;
      end loop;

      if Derniere /= null then
         -- Hit : mettre à jour les compteurs
         Tick (Cache, Seq);
         Derniere.Seq_Dernier     := Seq;
         Derniere.Nb_Utilisations := Derniere.Nb_Utilisations + 1;
         Cache.Stats.Nb_Hits      := Cache.Stats.Nb_Hits + 1;
         Route := Derniere.Route;
         return True;
      end if;

      Cache.Stats.Nb_Defauts := Cache.Stats.Nb_Defauts + 1;
      return False;
   end Chercher;

   -- ---------------------------------------------------------------
   -- Expulsion : trouver la feuille victime et la supprimer.
   -- On parcourt tout le trie pour trouver le nœud avec route ayant
   -- la plus petite valeur selon la politique, puis on supprime sa route.
   -- Si le nœud n'a plus de fils, on l'élague (et remonte si besoin).
   -- ---------------------------------------------------------------

   -- Valeur de comparaison d'un nœud selon la politique
   function Valeur_Noeud (N   : T_Noeud;
                          Pol : T_Politique) return Natural is
   begin
      case Pol is
         when FIFO => return N.Seq_Insertion;
         when LRU  => return N.Seq_Dernier;
         when LFU  => return N.Nb_Utilisations;
      end case;
   end Valeur_Noeud;

   -- Parcourir récursivement pour trouver la victime (nœud avec route
   -- ayant la plus petite valeur selon la politique).
   procedure Trouver_Victime (Noeud    :     T_Ptr_Noeud;
                              Pol      :     T_Politique;
                              Victime  : in out T_Ptr_Noeud;
                              Val_Min  : in out Natural) is
   begin
      if Noeud = null then
         return;
      end if;
      if Noeud.A_Route then
         declare
            V : constant Natural := Valeur_Noeud (Noeud.all, Pol);
         begin
            if V < Val_Min then
               Val_Min := V;
               Victime := Noeud;
            end if;
         end;
      end if;
      Trouver_Victime (Noeud.Fils (0), Pol, Victime, Val_Min);
      Trouver_Victime (Noeud.Fils (1), Pol, Victime, Val_Min);
   end Trouver_Victime;

   -- Supprimer la route du nœud victime.
   -- Élague les nœuds devenus inutiles (pas de route, pas de fils).
   -- Retourne True si le nœud lui-même peut être libéré par son parent.
   function Supprimer_Route (Noeud   : in out T_Ptr_Noeud;
                             Victime :        T_Ptr_Noeud) return Boolean is
      Peut_Liberer : Boolean;
   begin
      if Noeud = null then
         return False;
      end if;

      if Noeud = Victime then
         -- Supprimer la route de ce nœud
         Noeud.A_Route := False;
         -- Si le nœud n'a plus de fils, il peut être libéré
         if Noeud.Fils (0) = null and then Noeud.Fils (1) = null then
            Liberer (Noeud);
            return True;
         end if;
         return False;
      end if;

      -- Descendre dans les deux sous-arbres
      for B in 0 .. 1 loop
         if Noeud.Fils (B) /= null then
            Peut_Liberer := Supprimer_Route (Noeud.Fils (B), Victime);
            if Peut_Liberer then
               Noeud.Fils (B) := null;
            end if;
         end if;
      end loop;

      -- Élager ce nœud s'il n'a plus de route ni de fils
      if not Noeud.A_Route
         and then Noeud.Fils (0) = null
         and then Noeud.Fils (1) = null
      then
         Liberer (Noeud);
         return True;
      end if;
      return False;
   end Supprimer_Route;

   procedure Expulser (Cache : in out T_Cache_Trie) is
      Victime : T_Ptr_Noeud := null;
      Val_Min : Natural     := Natural'Last;
      Dummy   : Boolean;
   begin
      -- Trouver la victime
      Trouver_Victime (Cache.Racine, Cache.Pol, Victime, Val_Min);

      pragma Assert (Victime /= null, "Expulser trie : aucune victime");

      -- Supprimer et élager
      Dummy := Supprimer_Route (Cache.Racine, Victime);
      if Dummy then
         Cache.Racine := null;
      end if;

      Cache.Nb_Entrees         := Cache.Nb_Entrees - 1;
      Cache.Stats.Nb_Evictions := Cache.Stats.Nb_Evictions + 1;
   end Expulser;

   -- Insérer une route dans le trie selon son masque (longueur = profondeur).
   -- Crée les nœuds intermédiaires au besoin.
   procedure Inserer_Dans_Trie (Cache : in out T_Cache_Trie;
                                Route :        T_Route;
                                Seq   :        Natural) is
      Long     : constant Natural     := Longueur_Masque (Route.Masque);
      Courant  : T_Ptr_Noeud;
      Bit_Pos  : Natural;
      Bit_Val  : Natural;
   begin
      -- Créer la racine si elle n'existe pas
      if Cache.Racine = null then
         Cache.Racine := new T_Noeud;
      end if;
      Courant := Cache.Racine;

      -- Descendre / créer Long nœuds (un par bit du masque)
      if Long > 0 then
         Bit_Pos := 31;
         for I in 1 .. Long loop
            Bit_Val := Natural ((Route.Destination
                                 / T_Adresse_IP (2 ** Bit_Pos)) mod 2);
            if Courant.Fils (Bit_Val) = null then
               Courant.Fils (Bit_Val) := new T_Noeud;
            end if;
            Courant := Courant.Fils (Bit_Val);
            if Bit_Pos > 0 then
               Bit_Pos := Bit_Pos - 1;
            end if;
         end loop;
      end if;

      -- Stocker la route dans le nœud courant
      Courant.A_Route         := True;
      Courant.Route           := Route;
      Courant.Seq_Insertion   := Seq;
      Courant.Seq_Dernier     := Seq;
      Courant.Nb_Utilisations := 0;
   end Inserer_Dans_Trie;

   --------------
   -- Inserer  --
   --------------
   procedure Inserer (Cache     : in out T_Cache_Trie;
                      Table     :        T_Table;
                      Dest_Orig :        T_Adresse_IP;
                      Route_Ok  :        T_Route) is
      -- Construire la route correcte à mettre en cache (§1.4.2)
      Long_Min   : constant Natural := Longueur_Masque (Route_Ok.Masque);
      Long_Res   : Natural;
      Masque_Res : T_Adresse_IP;
      Route_Cache : T_Route := Route_Ok;
      Seq         : Natural;
   begin
      if Cache.Taille_Max = 0 then
         return;
      end if;

      -- Calculer le masque discriminant
      Masque_Discriminant (Table, Dest_Orig, Long_Min, Long_Res, Masque_Res);
      Route_Cache.Destination := Dest_Orig and Masque_Res;
      Route_Cache.Masque      := Masque_Res;

      -- Expulser si le cache est plein
      if Cache.Nb_Entrees >= Cache.Taille_Max then
         Expulser (Cache);
      end if;

      Tick (Cache, Seq);
      Inserer_Dans_Trie (Cache, Route_Cache, Seq);
      Cache.Nb_Entrees := Cache.Nb_Entrees + 1;
   end Inserer;

   -- Parcours en profondeur pour afficher toutes les routes
   procedure Afficher_Arbre (Noeud : T_Ptr_Noeud) is
   begin
      if Noeud = null then
         return;
      end if;
      if Noeud.A_Route then
         Put_Line (Vers_Chaine (Noeud.Route.Destination) & " "
                   & Vers_Chaine (Noeud.Route.Masque)    & " "
                   & Iface_Str (Noeud.Route));
      end if;
      Afficher_Arbre (Noeud.Fils (0));
      Afficher_Arbre (Noeud.Fils (1));
   end Afficher_Arbre;

   ---------------
   -- Afficher  --
   ---------------
   procedure Afficher (Cache : T_Cache_Trie) is
   begin
      Afficher_Arbre (Cache.Racine);
   end Afficher;

   ------------------
   -- Statistiques --
   ------------------
   function Statistiques (Cache : T_Cache_Trie) return T_Stats is
   begin
      return Cache.Stats;
   end Statistiques;

   ---------------------
   -- Afficher_Stats  --
   ---------------------
   procedure Afficher_Stats (Cache : T_Cache_Trie) is
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

end Caches_Trie;
