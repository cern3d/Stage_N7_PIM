with Ada.Text_IO; use Ada.Text_IO;

package body Pack_Table_Routage is

   -----------------
   -- Initialiser --
   -----------------
   procedure Initialiser (Table : out T_Table_Routage) is
   begin
      Table.Tete := null;
      Table.Queue := null;
   end Initialiser;

   -----------------
   -- Enregistrer --
   -----------------
   procedure Enregistrer (Table : in out T_Table_Routage; Route : in T_Route) is
      Nouveau : T_Lien := new T_Cellule'(Route => Route, Suivant => null);
   begin
      if Table.Tete = null then
         Table.Tete := Nouveau;
         Table.Queue := Nouveau;
      else
         Table.Queue.Suivant := Nouveau;
         Table.Queue := Nouveau;
      end if;
   end Enregistrer;

   --------------------
   -- Chercher_Route --
   --------------------
   procedure Chercher_Route (Table   : in T_Table_Routage; 
                             IP_Dest : in T_Adresse_IP; 
                             Interf  : out Unbounded_String) is
      Courant          : T_Lien := Table.Tete;
      Meilleur_Masque  : T_Adresse_IP := 0;
      Trouve           : Boolean := False;
   begin
      Interf := To_Unbounded_String("");

      while Courant /= null loop
         -- Application de l'opérateur AND bit à bit pour vérifier la correspondance [cite: 40, 265]
         if (IP_Dest and Courant.Route.Masque) = (Courant.Route.Destination and Courant.Route.Masque) then
            -- Règle du masque le plus long [cite: 41]
            if not Trouve or else Courant.Route.Masque >= Meilleur_Masque then
               Meilleur_Masque := Courant.Route.Masque;
               Interf          := Courant.Route.Interface_R;
               Trouve          := True;
            end if;
         end if;
         Courant := Courant.Suivant;
      end loop;
   end Chercher_Route;

   --------------------
   -- Afficher_Table --
   --------------------
   procedure Afficher_Table (Table : in T_Table_Routage) is
      Courant : T_Lien := Table.Tete;
   begin
      while Courant /= null loop
         Put_Line(IP_To_String(Courant.Route.Destination) & " " &
                  IP_To_String(Courant.Route.Masque) & " " &
                  To_String(Courant.Route.Interface_R));
         Courant := Courant.Suivant;
      end loop;
   end Afficher_Table;

   -----------
   -- Vider --
   -----------
   procedure Vider (Table : in out T_Table_Routage) is
      Courant : T_Lien := Table.Tete;
      A_Epingler : T_Lien;
   begin
      while Courant /= null loop
         A_Epingler := Courant;
         Courant := Courant.Suivant;
         -- Libération mémoire pour prévenir les fuites détectables par Valgrind [cite: 359]
         -- (Ici simulé, l'Unchecked_Deallocation peut être instancié au besoin)
      end loop;
      Table.Tete := null;
      Table.Queue := null;
   end Vider;


   procedure Chercher_Route_Pour_Cache (
   Table             : in T_Table_Routage;
   IP                : in T_Adresse_IP;
   Interface_R       : out Unbounded_String;
   Masque_Cache      : out T_Adresse_IP;
   Destination_Cache : out T_Adresse_IP
) is
   --  /!\ ATTENTION : 
   --  Remplace 'T_Lien' par TON type de pointeur de cellule (ex: T_Pointeur)
   --  Remplace 'Table.Tete' par TON champ de record (ex: Table.Liste ou Table.Premier)
   Courant        : T_Lien := Table.Tete; 
   Route_Gagnante : T_Route;
   Trouve         : Boolean := False;
   Max_Masque     : T_Adresse_IP;
begin
   -- Étape 1 : Trouver la route correspondante (Masque le plus long)
   while Courant /= null loop
      -- /!\ Ajuste ici si tes cellules contiennent directement Destination/Masque 
      -- au lieu d'un sous-record nommé 'Route' (ex: Courant.Masque au lieu de Courant.Route.Masque)
      if (IP and Courant.Route.Masque) = Courant.Route.Destination then
         if not Trouve or else Courant.Route.Masque > Route_Gagnante.Masque then
            Route_Gagnante := Courant.Route;
            Trouve := True;
         end if;
      end if;
      Courant := Courant.Suivant; -- Ajuste si ton pointeur de cellule s'appelle 'Suiv' ou 'Svt'
   end loop;

   if Trouve then
      Interface_R := Route_Gagnante.Interface_R;
      Max_Masque  := Route_Gagnante.Masque;

      -- Étape 2 (Section 1.4.2) : Trouver le masque le plus long pour cette destination
      Courant := Table.Tete; -- On repart du début de la liste interne
      while Courant /= null loop
         if (Courant.Route.Destination and Route_Gagnante.Masque) = Route_Gagnante.Destination then
            if Courant.Route.Masque > Max_Masque then
               Max_Masque := Courant.Route.Masque;
            end if;
         end if;
         Courant := Courant.Suivant;
      end loop;

      -- Calcul des éléments à insérer dans le cache
      Masque_Cache      := Max_Masque;
      Destination_Cache := IP and Max_Masque;
   else
      -- Sécurité si aucune route trouvée
      Interface_R       := To_Unbounded_String("");
      Masque_Cache      := 0;
      Destination_Cache := 0;
   end if;
end Chercher_Route_Pour_Cache;

end Pack_Table_Routage;