with Ada.Unchecked_Deallocation;
with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings;       use Ada.Strings;

package body Caches_Trie is

   procedure Liberer is
      new Ada.Unchecked_Deallocation (T_Noeud, T_Ptr_Noeud);

   function Iface_Str (R : T_Route) return String is
   begin
      pragma Assert (R.Iface_Len > 0 and then R.Iface_Len <= Max_Interface,
                     "Iface_Str : Iface_Len hors bornes");
      return Trim (R.Iface (1 .. R.Iface_Len), Right);
   end Iface_Str;

   -- Incrémenter l'horloge logique.
   -- Postcondition : Seq = Cache.Seq_Global@avant + 1
   procedure Tick (Cache : in out T_Cache_Trie; Seq : out Natural) is
   begin
      Cache.Seq_Global := Cache.Seq_Global + 1;
      Seq              := Cache.Seq_Global;
      pragma Assert (Seq > 0, "Tick : Seq_Global debordement");
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
      -- Postcondition : invariants (I1) et (I2)
      pragma Assert (Cache.Nb_Entrees = 0 and then Cache.Racine = null,
                     "Initialiser trie : etat initial incorrect");
   end Initialiser;

   -- Libérer récursivement tout le sous-arbre enraciné en Noeud.
   -- Postcondition : Noeud = null à la sortie
   procedure Liberer_Arbre (Noeud : in out T_Ptr_Noeud) is
   begin
      if Noeud = null then
         return;
      end if;
      Liberer_Arbre (Noeud.Fils (0));
      Liberer_Arbre (Noeud.Fils (1));
      Liberer (Noeud);
      -- Postcondition : Noeud est libéré (accès ultérieur = comportement indéfini)
   end Liberer_Arbre;

   ----------------
   -- Finaliser  --
   ----------------
   procedure Finaliser (Cache : in out T_Cache_Trie) is
   begin
      Liberer_Arbre (Cache.Racine);
      Cache.Racine     := null;
      Cache.Nb_Entrees := 0;
      -- Postcondition
      pragma Assert (Cache.Nb_Entrees = 0 and then Cache.Racine = null,
                     "Finaliser trie : cache non vide apres liberation");
   end Finaliser;

   ---------------
   -- Chercher  --
   ---------------
   -- Descend bit par bit depuis le bit 31 (MSB) de Destination.
   -- Mémorise la route du nœud le plus profond rencontré portant une route.
   function Chercher (Cache       : in out T_Cache_Trie;
                      Destination :        T_Adresse_IP;
                      Route       :    out T_Route) return Boolean is
      Courant  : T_Ptr_Noeud := Cache.Racine;
      Bit_Pos  : Natural     := 31;
      Bit_Val  : Natural;
      Derniere : T_Ptr_Noeud := null;
      Seq      : Natural;
      Dem_Avant : constant Natural := Cache.Stats.Nb_Demandes;
   begin
      Cache.Stats.Nb_Demandes := Cache.Stats.Nb_Demandes + 1;

      -- Descendre dans l'arbre en suivant les bits de Destination
      loop
         exit when Courant = null;
         if Courant.A_Route then
            Derniere := Courant;
         end if;
         -- Extraire le bit Bit_Pos de Destination
         Bit_Val := Natural ((Destination / T_Adresse_IP (2 ** Bit_Pos))
                             mod 2);
         Courant := Courant.Fils (Bit_Val);
         exit when Bit_Pos = 0;
         Bit_Pos := Bit_Pos - 1;
      end loop;
      -- Vérifier aussi le nœud terminal
      if Courant /= null and then Courant.A_Route then
         Derniere := Courant;
      end if;

      if Derniere /= null then
         -- Hit
         Tick (Cache, Seq);
         Derniere.Seq_Dernier     := Seq;
         Derniere.Nb_Utilisations := Derniere.Nb_Utilisations + 1;
         Cache.Stats.Nb_Hits      := Cache.Stats.Nb_Hits + 1;
         Route := Derniere.Route;
         -- Postcondition (hit)
         pragma Assert (Correspond (Destination, Route.Destination, Route.Masque),
                        "Chercher trie : route retournee ne correspond pas");
         pragma Assert (Cache.Stats.Nb_Demandes = Dem_Avant + 1,
                        "Chercher trie : Nb_Demandes non incremente");
         return True;
      end if;

      Cache.Stats.Nb_Defauts := Cache.Stats.Nb_Defauts + 1;
      pragma Assert (Cache.Stats.Nb_Demandes = Dem_Avant + 1,
                     "Chercher trie : Nb_Demandes non incremente (miss)");
      return False;
   end Chercher;

   -- Valeur de comparaison d'un nœud selon la politique.
   -- Précondition : Noeud.A_Route = True
   function Valeur_Noeud (N   : T_Noeud;
                          Pol : T_Politique) return Natural is
   begin
      case Pol is
         when FIFO => return N.Seq_Insertion;
         when LRU  => return N.Seq_Dernier;
         when LFU  => return N.Nb_Utilisations;
      end case;
   end Valeur_Noeud;

   -- Trouver récursivement le nœud portant une route avec la valeur
   -- minimale selon la politique (= la victime à expulser).
   -- Précondition  : Noeud peut être null (cas de base)
   -- Postcondition : Victime pointe le nœud victime ou reste inchangé
   --                 Val_Min est la valeur minimale trouvée
   procedure Trouver_Victime (Noeud   :     T_Ptr_Noeud;
                              Pol     :     T_Politique;
                              Victime : in out T_Ptr_Noeud;
                              Val_Min : in out Natural) is
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

   -- Supprimer récursivement la route du nœud Victime et élager l'arbre.
   -- Retourne True si Noeud lui-même peut être libéré par son parent.
   -- Précondition  : Victime /= null et Victime.A_Route = True
   -- Postcondition : Victime.A_Route = False (ou Victime libéré)
   --                 Les nœuds devenus inutiles sont libérés
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
         -- Élager si le nœud est devenu inutile (sans fils)
         if Noeud.Fils (0) = null and then Noeud.Fils (1) = null then
            Liberer (Noeud);
            return True;
         end if;
         return False;
      end if;

      -- Descendre dans les fils
      for B in 0 .. 1 loop
         if Noeud.Fils (B) /= null then
            Peut_Liberer := Supprimer_Route (Noeud.Fils (B), Victime);
            if Peut_Liberer then
               Noeud.Fils (B) := null;
            end if;
         end if;
      end loop;

      -- Élager ce nœud s'il est devenu inutile
      if not Noeud.A_Route
         and then Noeud.Fils (0) = null
         and then Noeud.Fils (1) = null
      then
         Liberer (Noeud);
         return True;
      end if;
      return False;
   end Supprimer_Route;

   -- Expulser la victime du trie selon la politique courante.
   -- Précondition  : Cache.Nb_Entrees > 0
   -- Postcondition : Cache.Nb_Entrees = Cache.Nb_Entrees@avant - 1
   procedure Expulser (Cache : in out T_Cache_Trie) is
      Victime  : T_Ptr_Noeud := null;
      Val_Min  : Natural     := Natural'Last;
      Dummy    : Boolean;
      Nb_Avant : constant Natural := Cache.Nb_Entrees;
   begin
      pragma Assert (Cache.Nb_Entrees > 0, "Expulser trie : cache vide");

      Trouver_Victime (Cache.Racine, Cache.Pol, Victime, Val_Min);
      pragma Assert (Victime /= null, "Expulser trie : aucune victime");

      Dummy := Supprimer_Route (Cache.Racine, Victime);
      if Dummy then
         Cache.Racine := null;
      end if;

      Cache.Nb_Entrees         := Cache.Nb_Entrees - 1;
      Cache.Stats.Nb_Evictions := Cache.Stats.Nb_Evictions + 1;

      pragma Assert (Cache.Nb_Entrees = Nb_Avant - 1,
                     "Expulser trie : Nb_Entrees incorrect apres eviction");
   end Expulser;

   -- Insérer Route dans le trie au nœud de profondeur Longueur_Masque(Route.Masque).
   -- Crée les nœuds intermédiaires si nécessaire.
   -- Précondition  : Cache.Racine peut exister ou non
   -- Postcondition : le nœud cible porte la route (A_Route = True)
   --                 invariant (I4) conservé
   procedure Inserer_Dans_Trie (Cache : in out T_Cache_Trie;
                                Route :        T_Route;
                                Seq   :        Natural) is
      Long    : constant Natural := Longueur_Masque (Route.Masque);
      Courant : T_Ptr_Noeud;
      Bit_Pos : Natural;
      Bit_Val : Natural;
   begin
      pragma Assert (Long <= 32, "Inserer_Dans_Trie : longueur masque > 32");

      -- Créer la racine si elle n'existe pas
      if Cache.Racine = null then
         Cache.Racine := new T_Noeud;
      end if;
      Courant := Cache.Racine;

      -- Descendre Long niveaux en créant les nœuds manquants
      if Long > 0 then
         Bit_Pos := 31;
         for I in 1 .. Long loop
            Bit_Val := Natural ((Route.Destination
                                 / T_Adresse_IP (2 ** Bit_Pos)) mod 2);
            pragma Assert (Bit_Val in 0 .. 1,
                           "Inserer_Dans_Trie : bit hors [0,1]");
            if Courant.Fils (Bit_Val) = null then
               Courant.Fils (Bit_Val) := new T_Noeud;
            end if;
            Courant := Courant.Fils (Bit_Val);
            if Bit_Pos > 0 then
               Bit_Pos := Bit_Pos - 1;
            end if;
         end loop;
      end if;

      -- Stocker la route dans le nœud courant (profondeur = Long)
      Courant.A_Route         := True;
      Courant.Route           := Route;
      Courant.Seq_Insertion   := Seq;
      Courant.Seq_Dernier     := Seq;
      Courant.Nb_Utilisations := 0;

      -- Postcondition : invariant (I4)
      pragma Assert (Longueur_Masque (Courant.Route.Masque) = Long,
                     "Inserer_Dans_Trie : longueur masque stockee incorrecte");
   end Inserer_Dans_Trie;

   --------------
   -- Inserer  --
   --------------
   procedure Inserer (Cache     : in out T_Cache_Trie;
                      Table     :        T_Table;
                      Dest_Orig :        T_Adresse_IP;
                      Route_Ok  :        T_Route) is
      Long_Min    : constant Natural := Longueur_Masque (Route_Ok.Masque);
      Long_Res    : Natural;
      Masque_Res  : T_Adresse_IP;
      Route_Cache : T_Route := Route_Ok;
      Seq         : Natural;
      Nb_Avant    : constant Natural := Cache.Nb_Entrees;
   begin
      if Cache.Taille_Max = 0 then
         return;
      end if;

      -- Calculer le masque discriminant (§1.4.2)
      Masque_Discriminant (Table, Dest_Orig, Long_Min, Long_Res, Masque_Res);
      pragma Assert (Long_Res >= Long_Min,
                     "Inserer trie : Long_Res < Long_Min");

      Route_Cache.Destination := Dest_Orig and Masque_Res;
      Route_Cache.Masque      := Masque_Res;

      -- Expulser si le cache est plein
      if Cache.Nb_Entrees >= Cache.Taille_Max then
         pragma Assert (Cache.Nb_Entrees = Cache.Taille_Max,
                        "Inserer trie : Nb_Entrees > Taille_Max avant eviction");
         Expulser (Cache);
      end if;

      pragma Assert (Cache.Nb_Entrees < Cache.Taille_Max,
                     "Inserer trie : cache plein apres eviction");

      Tick (Cache, Seq);
      Inserer_Dans_Trie (Cache, Route_Cache, Seq);
      Cache.Nb_Entrees := Cache.Nb_Entrees + 1;

      -- Postcondition
      pragma Assert (Cache.Nb_Entrees <= Cache.Taille_Max,
                     "Inserer trie : Nb_Entrees > Taille_Max apres insertion");
      pragma Assert (Cache.Nb_Entrees = Natural'Min (Nb_Avant + 1,
                                                     Cache.Taille_Max),
                     "Inserer trie : Nb_Entrees incorrect");
   end Inserer;

   -- Parcours préfixe récursif pour afficher toutes les routes.
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
      S : constant T_Stats := Cache.Stats;
   begin
      -- Postcondition : invariant (I3)
      pragma Assert (S.Nb_Demandes = S.Nb_Hits + S.Nb_Defauts,
                     "Statistiques trie : invariant I3 viole");
      return S;
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
