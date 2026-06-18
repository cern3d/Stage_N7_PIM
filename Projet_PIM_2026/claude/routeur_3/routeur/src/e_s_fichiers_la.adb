with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;     use Ada.Strings.Fixed;
with Ada.Strings;           use Ada.Strings;
with Ada.Text_IO;           use Ada.Text_IO;
with Adresses_IP;           use Adresses_IP;

package body E_S_Fichiers_LA is

   procedure Prochain_Token (S     :     String;
                             Pos   : in out Positive;
                             Token :    out Unbounded_String) is
   begin
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
            S          : constant String := Trim (To_String (Ligne), Both);
            Pos        : Positive        := S'First;
            T1, T2, T3 : Unbounded_String;
         begin
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

   procedure Sep_Commande (Premiere : in out Boolean) is
   begin
      if not Premiere then New_Line; end if;
      Premiere := False;
   end Sep_Commande;

   -----------------------
   -- Traiter_Paquets   --
   -----------------------
   procedure Traiter_Paquets (Nom_Fichier :        String;
                              Table       :        T_Table;
                              Cache       : in out T_Cache_Trie;
                              Fichier_Res : in out File_Type) is
      Fichier      : File_Type;
      Ligne        : Unbounded_String;
      No_Ligne     : Natural := 0;
      Premiere_Cmd : Boolean := True;
   begin
      Open (Fichier, In_File, Nom_Fichier);

      while not End_Of_File (Fichier) loop
         Ligne    := To_Unbounded_String (Get_Line (Fichier));
         No_Ligne := No_Ligne + 1;

         declare
            S : constant String := Trim (To_String (Ligne), Both);
         begin
            if S'Length = 0 then
               null;

            elsif S = "table" then
               Sep_Commande (Premiere_Cmd);
               Put_Line ("table (ligne" & Natural'Image (No_Ligne) & ")");
               Tables_Routage.Afficher (Table);

            elsif S = "cache" then
               Sep_Commande (Premiere_Cmd);
               Put_Line ("cache (ligne" & Natural'Image (No_Ligne) & ")");
               Caches_Trie.Afficher (Cache);

            elsif S = "stat" then
               Sep_Commande (Premiere_Cmd);
               Put_Line ("stat (ligne" & Natural'Image (No_Ligne) & ")");
               Caches_Trie.Afficher_Stats (Cache);

            elsif S = "fin" then
               Sep_Commande (Premiere_Cmd);
               Put_Line ("fin (ligne" & Natural'Image (No_Ligne) & ")");
               Close (Fichier);
               return;

            else
               declare
                  Dest      : T_Adresse_IP;
                  Route     : T_Route;
                  Cache_Hit : Boolean;
                  Table_Hit : Boolean;
               begin
                  Dest      := Adresses_IP.Depuis_Chaine (S);
                  Cache_Hit := Caches_Trie.Chercher (Cache, Dest, Route);

                  if Cache_Hit then
                     Put_Line (Fichier_Res,
                               S & " "
                               & Trim (Route.Iface (1 .. Route.Iface_Len),
                                       Right));
                  else
                     Table_Hit := Tables_Routage.Chercher (Table, Dest, Route);
                     if Table_Hit then
                        Put_Line (Fichier_Res,
                                  S & " "
                                  & Trim (Route.Iface (1 .. Route.Iface_Len),
                                          Right));
                        Caches_Trie.Inserer (Cache, Table, Dest, Route);
                     else
                        Put_Line (Standard_Error, "Aucune route pour " & S);
                     end if;
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

end E_S_Fichiers_LA;
