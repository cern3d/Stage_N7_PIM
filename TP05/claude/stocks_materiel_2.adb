-- Implantation du module Stocks_Materiel

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

package body Stocks_Materiel is

   -- =========================================================
   -- Utilitaire interne : trouver l'indice d'un numéro de série
   -- Retourne 0 si non trouvé
   -- =========================================================
   function Trouver_Indice (S : in Stock; Numero : in Numero_Serie) return Natural is
   begin
      for I in 1 .. S.Nb_Materiels loop
         if S.Materiels (I).Numero = Numero then
            return I;
         end if;
      end loop;
      return 0;
   end Trouver_Indice;

   -- =========================================================
   -- Créer
   -- =========================================================
   procedure Creer (S : out Stock) is
   begin
      S.Nb_Materiels := 0;
   end Creer;

   -- =========================================================
   -- Nombre_Materiels
   -- =========================================================
   function Nombre_Materiels (S : in Stock) return Natural is
   begin
      return S.Nb_Materiels;
   end Nombre_Materiels;

   -- =========================================================
   -- Enregistrer
   -- =========================================================
   procedure Enregistrer (S           : in out Stock;
                          Numero      : in     Numero_Serie;
                          Nature      : in     Nature_Materiel;
                          Annee_Achat : in     Annee) is
      N : constant Natural := S.Nb_Materiels + 1;
   begin
      S.Nb_Materiels          := N;
      S.Materiels (N).Numero      := Numero;
      S.Materiels (N).Nature      := Nature;
      S.Materiels (N).Annee_Achat := Annee_Achat;
      S.Materiels (N).Fonctionnel := True;
   end Enregistrer;

   -- =========================================================
   -- Mettre_A_Jour_Etat
   -- =========================================================
   procedure Mettre_A_Jour_Etat (S      : in out Stock;
                                  Numero : in     Numero_Serie) is
      Idx : constant Natural := Trouver_Indice (S, Numero);
   begin
      -- Précondition : le matériel doit exister
      pragma Assert (Idx /= 0, "Numero de serie introuvable dans Mettre_A_Jour_Etat");
      S.Materiels (Idx).Fonctionnel := not S.Materiels (Idx).Fonctionnel;
   end Mettre_A_Jour_Etat;

   -- =========================================================
   -- Nombre_Hors_Service
   -- =========================================================
   function Nombre_Hors_Service (S : in Stock) return Natural is
      Compteur : Natural := 0;
   begin
      for I in 1 .. S.Nb_Materiels loop
         if not S.Materiels (I).Fonctionnel then
            Compteur := Compteur + 1;
         end if;
      end loop;
      return Compteur;
   end Nombre_Hors_Service;

   -- =========================================================
   -- Supprimer
   -- =========================================================
   procedure Supprimer (S      : in out Stock;
                        Numero : in     Numero_Serie) is
      Idx : constant Natural := Trouver_Indice (S, Numero);
   begin
      pragma Assert (Idx /= 0, "Numero de serie introuvable dans Supprimer");
      -- Décalage : on écrase l'élément supprimé par le suivant, etc.
      for I in Idx .. S.Nb_Materiels - 1 loop
         S.Materiels (I) := S.Materiels (I + 1);
      end loop;
      S.Nb_Materiels := S.Nb_Materiels - 1;
   end Supprimer;

   -- =========================================================
   -- Afficher
   -- =========================================================
   procedure Afficher (S : in Stock) is
   begin
      Put_Line ("=== Stock (" & Natural'Image (S.Nb_Materiels) & " materiel(s)) ===");
      for I in 1 .. S.Nb_Materiels loop
         declare
            M : Materiel renames S.Materiels (I);
         begin
            Put ("  [");
            Put (M.Numero, Width => 0);
            Put ("] Nature : ");
            Put (Nature_Materiel'Image (M.Nature));
            Put ("  Achat : ");
            Put (M.Annee_Achat, Width => 0);
            Put ("  Etat : ");
            if M.Fonctionnel then
               Put_Line ("Fonctionnel");
            else
               Put_Line ("Hors service");
            end if;
         end;
      end loop;
      Put_Line ("=======================================");
   end Afficher;

   -- =========================================================
   -- Supprimer_Hors_Service
   -- =========================================================
   procedure Supprimer_Hors_Service (S : in out Stock) is
      I : Natural := 1;
   begin
      -- Parcours avec indice variable car la taille du stock change
      while I <= S.Nb_Materiels loop
         if not S.Materiels (I).Fonctionnel then
            Supprimer (S, S.Materiels (I).Numero);
            -- Ne pas incrémenter I : l'élément suivant est maintenant à l'indice I
         else
            I := I + 1;
         end if;
      end loop;
   end Supprimer_Hors_Service;

end Stocks_Materiel;