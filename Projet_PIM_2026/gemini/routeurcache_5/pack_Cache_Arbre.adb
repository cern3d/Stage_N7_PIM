with Ada.Text_IO; use Ada.Text_IO;

package body Pack_Cache_Arbre is

   procedure Initialiser (Cache : out T_Cache; Taille_Max : in Integer; Politique : in T_Politique) is
   begin
      Cache.Racine     := null;
      Cache.Taille_Max := Taille_Max;
      Cache.Taille_Act := 0;
      Cache.Politique  := Politique;
      Cache.Compteur   := 0;
   end Initialiser;

   function Longueur_Masque (Masque : T_Adresse_IP) return Natural is
      L : Natural := 0;
   begin
      for I in reverse 0 .. 31 loop
         if (Masque and (T_Adresse_IP(2)**I)) /= 0 then
            L := L + 1;
         else
            exit;
         end if;
      end loop;
      return L;
   end Longueur_Masque;

   procedure Rechercher_Victime_Rec (Noeud : in T_Arbre; Politique : in T_Politique; Meilleur : in out T_Arbre) is
   begin
      if Noeud = null then
         return;
      end if;

      if Noeud.Est_Route then
         if Meilleur = null then
            Meilleur := Noeud;
         else
            case Politique is
               when FIFO =>
                  if Noeud.Route.Date_Insertion < Meilleur.Route.Date_Insertion then Meilleur := Noeud; end if;
               when LRU =>
                  if Noeud.Route.Dernier_Acces < Meilleur.Route.Dernier_Acces then Meilleur := Noeud; end if;
               when LFU =>
                  if Noeud.Route.Frequence < Meilleur.Route.Frequence then Meilleur := Noeud; end if;
            end case;
         end if;
      end if;

      Rechercher_Victime_Rec(Noeud.Fils_Gauche, Politique, Meilleur);
      Rechercher_Victime_Rec(Noeud.Fils_Droit, Politique, Meilleur);
   end Rechercher_Victime_Rec;

   procedure Chercher_Cache (Cache   : in out T_Cache; 
                             IP_Dest : in T_Adresse_IP; 
                             Interf  : out Unbounded_String;
                             Trouve  : out Boolean) is
      Courant : T_Arbre := Cache.Racine;
      Dernier_Match : T_Arbre := null;
      Bit : T_Adresse_IP;
   begin
      Trouve := False;
      if Courant = null then return; end if;

      Cache.Compteur := Cache.Compteur + 1;

      if Courant.Est_Route then
         Dernier_Match := Courant;
      end if;

      for I in reverse 0 .. 31 loop
         Bit := T_Adresse_IP(2)**I;
         if (IP_Dest and Bit) /= 0 then
            Courant := Courant.Fils_Droit;
         else
            Courant := Courant.Fils_Gauche;
         end if;

         if Courant = null then
            exit;
         end if;

         if Courant.Est_Route then
            Dernier_Match := Courant;
         end if;
      end loop;

      if Dernier_Match /= null then
         Interf := Dernier_Match.Route.Interface_R;
         Trouve := True;
         Dernier_Match.Route.Dernier_Acces := Cache.Compteur;
         Dernier_Match.Route.Frequence     := Dernier_Match.Route.Frequence + 1;
      end if;
   end Chercher_Cache;

   procedure Ajouter_Cache (Cache : in out T_Cache; Route : in T_Route_Cache) is
      L : Natural := Longueur_Masque(Route.Masque);
      Courant : T_Arbre;
      Bit : T_Adresse_IP;
      Route_A_Inserer : T_Route_Cache := Route;
   begin
      if Cache.Taille_Max = 0 then return; end if;

      if Cache.Racine = null then
         Cache.Racine := new T_Noeud;
      end if;

      Courant := Cache.Racine;
      for I in reverse (32 - L) .. 31 loop
         Bit := T_Adresse_IP(2)**I;
         if (Route.Destination and Bit) /= 0 then
            if Courant.Fils_Droit = null then Courant.Fils_Droit := new T_Noeud; end if;
            Courant := Courant.Fils_Droit;
         else
            if Courant.Fils_Gauche = null then Courant.Fils_Gauche := new T_Noeud; end if;
            Courant := Courant.Fils_Gauche;
         end if;
      end loop;

      if not Courant.Est_Route then
         if Cache.Taille_Act >= Cache.Taille_Max then
            declare
               Victime : T_Arbre := null;
            begin
               Rechercher_Victime_Rec(Cache.Racine, Cache.Politique, Victime);
               if Victime /= null then
                  Victime.Est_Route := False;
                  Cache.Taille_Act  := Cache.Taille_Act - 1;
               end if;
            end;
         end if;
         Cache.Taille_Act := Cache.Taille_Act + 1;
      end if;

      Cache.Compteur := Cache.Compteur + 1;
      Route_A_Inserer.Date_Insertion := Cache.Compteur;
      Route_A_Inserer.Dernier_Acces  := Cache.Compteur;
      Route_A_Inserer.Frequence      := 1;

      Courant.Route     := Route_A_Inserer;
      Courant.Est_Route := True;
   end Ajouter_Cache;

   procedure Afficher_Cache (Cache : in T_Cache) is
      procedure Afficher_Rec (Noeud : in T_Arbre) is
      begin
         if Noeud = null then return; end if;
         if Noeud.Est_Route then
            Put_Line(IP_To_String(Noeud.Route.Destination) & " " &
                     IP_To_String(Noeud.Route.Masque) & " " &
                     To_String(Noeud.Route.Interface_R));
         end if;
         Afficher_Rec(Noeud.Fils_Gauche);
         Afficher_Rec(Noeud.Fils_Droit);
      end Afficher_Rec;
   begin
      Afficher_Rec(Cache.Racine);
   end Afficher_Cache;

   -- CORRECTION ICI : Remplacement de Libérer_Rec par Liberer_Rec
   procedure Vider (Cache : in out T_Cache) is
      procedure Liberer_Rec (Noeud : in out T_Arbre) is
      begin
         if Noeud = null then return; end if;
         Liberer_Rec(Noeud.Fils_Gauche);
         Liberer_Rec(Noeud.Fils_Droit);
         Noeud := null;
      end Liberer_Rec;
   begin
      Liberer_Rec(Cache.Racine);
      Cache.Taille_Act := 0;
   end Vider;

end Pack_Cache_Arbre;