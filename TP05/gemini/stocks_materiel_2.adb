with Ada.Text_IO; use Ada.Text_IO;

package body Stocks_Materiel is

   ------------------
   -- Creer_Stock --
   ------------------
   procedure Creer_Stock (S : out Stock) is
   begin
      S.Taille := 0;
   end Creer_Stock;

   ----------------------
   -- Nombre_Materiels --
   ----------------------
   function Nombre_Materiels (S : in Stock) return Natural is
   begin
      return S.Taille;
   end Nombre_Materiels;

   --------------------------
   -- Enregistrer_Materiel --
   --------------------------
   procedure Enregistrer_Materiel (
      S            : in out Stock;
      Num_Serie    : in Numero_Serie_Type;
      Nat          : in Nature_Materiel;
      Annee_Achat  : in Annee) is
   begin
      -- L'invariant de capacité est protégé par la précondition
      S.Taille := S.Taille + 1;
      S.Elements(S.Taille) := (
         Numero_Serie => Num_Serie,
         Nature       => Nat,
         Annee_Achat  => Annee_Achat,
         En_Fonction  => True
      );
   end Enregistrer_Materiel;

   -------------------
   -- Modifier_Etat --
   -------------------
   procedure Modifier_Etat (
      S         : in out Stock;
      Num_Serie : in Numero_Serie_Type;
      En_Marche : in Boolean) is
   begin
      for I in 1 .. S.Taille loop
         if S.Elements(I).Numero_Serie = Num_Serie then
            S.Elements(I).En_Fonction := En_Marche;
            return; -- Matériel trouvé et modifié, on s'arrête
         end if;
      end loop;
      -- Si non trouvé, l'énoncé ne demande pas de lever d'erreur spécifique.
   end Modifier_Etat;

   -------------------------
   -- Nombre_Hors_Service --
   -------------------------
   function Nombre_Hors_Service (S : in Stock) return Natural is
      Compteur : Natural := 0;
   begin
      for I in 1 .. S.Taille loop
         if not S.Elements(I).En_Fonction then
            Compteur := Compteur + 1;
         end if;
      end loop;
      return Compteur;
   end Nombre_Hors_Service;

   ------------------------
   -- Supprimer_Materiel --
   ------------------------
   procedure Supprimer_Materiel (
      S         : in out Stock;
      Num_Serie : in Numero_Serie_Type) is
   begin
      for I in 1 .. S.Taille loop
         if S.Elements(I).Numero_Serie = Num_Serie then
            -- On remplace l'élément à supprimer par le tout dernier du tableau
            S.Elements(I) := S.Elements(S.Taille);
            S.Taille := S.Taille - 1;
            return;
         end if;
      end loop;
   end Supprimer_Materiel;

   --------------------
   -- Afficher_Stock --
   --------------------
   procedure Afficher_Stock (S : in Stock) is
   begin
      if S.Taille = 0 then
         Put_Line("Le stock est vide.");
      else
         Put_Line("--- ETAT DU STOCK ---");
         for I in 1 .. S.Taille loop
            Put("No: " & Integer'Image(S.Elements(I).Numero_Serie));
            Put(" | Nature: " & Nature_Materiel'Image(S.Elements(I).Nature));
            Put(" | Annee: " & Integer'Image(S.Elements(I).Annee_Achat));
            Put_Line(" | Fonctionnel: " & Boolean'Image(S.Elements(I).En_Fonction));
         end loop;
         Put_Line("---------------------");
      end if;
   end Afficher_Stock;

   -----------------------
   -- Supprimer_Tous_HS --
   -----------------------
   procedure Supprimer_Tous_HS (S : in out Stock) is
      I : Positive := 1;
   begin
      while I <= S.Taille loop
         if not S.Elements(I).En_Fonction then
            -- Remplacement par le dernier élément
            S.Elements(I) := S.Elements(S.Taille);
            S.Taille := S.Taille - 1;
            -- Attention : on n'incrémente pas I ici car le nouvel élément 
            -- copié à l'indice I doit lui aussi être analysé !
         else
            I := I + 1;
         end if;
      end loop;
   end Supprimer_Tous_HS;

end Stocks_Materiel;