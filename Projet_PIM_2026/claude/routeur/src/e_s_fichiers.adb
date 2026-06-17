with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;     use Ada.Strings.Fixed;
with Ada.Strings;           use Ada.Strings;
with Ada.Text_IO;           use Ada.Text_IO;

package body E_S_Fichiers is

   -- Extraire le prochain token (séquence de non-blancs) depuis S
   -- en partant de la position Pos. Avance Pos après le token.
   -- Retourne "" si la fin de chaîne est atteinte.
   procedure Prochain_Token (S     :     String;
                             Pos   : in out Positive;
                             Token :    out Unbounded_String) is
   begin
      -- Sauter les blancs
      while Pos <= S'Last and then S (Pos) = ' ' loop
         Pos := Pos + 1;
      end loop;
      Token := Null_Unbounded_String;
      while Pos <= S'Last and then S (Pos) /= ' ' loop
         Append (Token, S (Pos));
         Pos := Pos + 1;
      end loop;
   end Prochain_Token;

   -----------------
   -- Lire_Table  --
   -----------------
   procedure Lire_Table (Nom_Fichier : String;
                         Table       : in out T_Table) is
      Fichier : File_Type;
      Ligne   : Unbounded_String;
   begin
      Open (Fichier, In_File, Nom_Fichier);

      while not End_Of_File (Fichier) loop
         Ligne := To_Unbounded_String (Get_Line (Fichier));
         declare
            S   : constant String  := Trim (To_String (Ligne), Both);
            Pos : Positive         := S'First;
            T1, T2, T3 : Unbounded_String;
         begin
            -- Ignorer les lignes vides
            if S'Length > 0 then
               Prochain_Token (S, Pos, T1);
               Prochain_Token (S, Pos, T2);
               Prochain_Token (S, Pos, T3);
               if Length (T1) > 0 and then Length (T2) > 0
                  and then Length (T3) > 0
               then
                  Ajouter (Table,
                           Adresses_IP.Depuis_Chaine (To_String (T1)),
                           Adresses_IP.Depuis_Chaine (To_String (T2)),
                           To_String (T3));
               end if;
            end if;
         end;
      end loop;

      Close (Fichier);
   end Lire_Table;

   -----------------------
   -- Traiter_Paquets   --
   -----------------------
   procedure Traiter_Paquets (Nom_Fichier  :     String;
                              Table        :     T_Table;
                              Fichier_Res  : in out File_Type;
                              Nb_Paquets   :    out Natural;
                              Nb_Defauts   :    out Natural) is
      Fichier     : File_Type;
      Ligne       : Unbounded_String;
      No_Ligne    : Natural := 0;
      Premiere_Cmd : Boolean := True;
   begin
      Nb_Paquets := 0;
      Nb_Defauts := 0;

      Open (Fichier, In_File, Nom_Fichier);

      while not End_Of_File (Fichier) loop
         Ligne    := To_Unbounded_String (Get_Line (Fichier));
         No_Ligne := No_Ligne + 1;

         declare
            S : constant String := Trim (To_String (Ligne), Both);
         begin
            -- Ligne vide : ignorer
            if S'Length = 0 then
               null;

            -- Commande : table
            elsif S = "table" then
               if not Premiere_Cmd then
                  New_Line;
               end if;
               Premiere_Cmd := False;
               Put_Line ("table (ligne" & Natural'Image (No_Ligne) & ")");
               Tables_Routage.Afficher (Table);

            -- Commande : cache (pas de cache dans cette version, liste vide)
            elsif S = "cache" then
               if not Premiere_Cmd then
                  New_Line;
               end if;
               Premiere_Cmd := False;
               Put_Line ("cache (ligne" & Natural'Image (No_Ligne) & ")");
               -- Pas de cache dans routeur simple : rien à afficher

            -- Commande : stat
            elsif S = "stat" then
               if not Premiere_Cmd then
                  New_Line;
               end if;
               Premiere_Cmd := False;
               Put_Line ("stat (ligne" & Natural'Image (No_Ligne) & ")");
               -- Statistiques affichées ici (dans le routeur simple : triviales)
               Put_Line ("Paquets traites : " & Natural'Image (Nb_Paquets));
               Put_Line ("Defauts        : " & Natural'Image (Nb_Defauts));

            -- Commande : fin
            elsif S = "fin" then
               if not Premiere_Cmd then
                  New_Line;
               end if;
               Put_Line ("fin (ligne" & Natural'Image (No_Ligne) & ")");
               Close (Fichier);
               return;

            -- Adresse IP : paquet à router
            else
               declare
                  Dest  : T_Adresse_IP;
                  Route : T_Route;
                  Ok    : Boolean;
               begin
                  Dest       := Adresses_IP.Depuis_Chaine (S);
                  Ok         := Tables_Routage.Chercher (Table, Dest, Route);
                  Nb_Paquets := Nb_Paquets + 1;

                  if Ok then
                     Put_Line (Fichier_Res,
                               S & " "
                               & Trim (Route.Iface (1 .. Route.Iface_Len),
                                       Right));
                  else
                     -- Aucune route trouvée : indiquer l'erreur
                     Nb_Defauts := Nb_Defauts + 1;
                     Put_Line (Standard_Error,
                               "Aucune route pour " & S);
                  end if;
               exception
                  when Constraint_Error =>
                     Put_Line (Standard_Error,
                               "Ligne " & Natural'Image (No_Ligne)
                               & " ignoree (adresse invalide) : " & S);
               end;
            end if;
         end;
      end loop;

      Close (Fichier);
   end Traiter_Paquets;

end E_S_Fichiers;
