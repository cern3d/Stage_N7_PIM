with Ada.Strings.Fixed;  use Ada.Strings.Fixed;
with Ada.Strings;        use Ada.Strings;

package body Adresses_IP is

   -- Extraire le prochain octet depuis S à partir de la position Pos.
   -- Avance Pos après le '.' ou jusqu'en fin de chaîne.
   procedure Lire_Octet (S     :     String;
                         Pos   : in out Positive;
                         Octet :    out T_Adresse_IP) is
      Debut : constant Positive := Pos;
      Val   : Integer := 0;
   begin
      -- Lire les chiffres
      while Pos <= S'Last and then S (Pos) in '0' .. '9' loop
         Val := Val * 10 + (Character'Pos (S (Pos)) - Character'Pos ('0'));
         Pos := Pos + 1;
      end loop;
      pragma Assert (Pos > Debut, "Octet vide dans l'adresse IP");
      pragma Assert (Val in 0 .. 255, "Octet hors intervalle [0,255]");
      Octet := T_Adresse_IP (Val);
      -- Sauter le '.' séparateur s'il existe
      if Pos <= S'Last and then S (Pos) = '.' then
         Pos := Pos + 1;
      end if;
   end Lire_Octet;

   ----------------------
   -- Depuis_Chaine    --
   ----------------------
   function Depuis_Chaine (S : String) return T_Adresse_IP is
      Pos     : Positive := S'First;
      O1, O2, O3, O4 : T_Adresse_IP;
   begin
      Lire_Octet (S, Pos, O1);
      Lire_Octet (S, Pos, O2);
      Lire_Octet (S, Pos, O3);
      Lire_Octet (S, Pos, O4);
      return O1 * 2 ** 24 + O2 * 2 ** 16 + O3 * 2 ** 8 + O4;
   end Depuis_Chaine;

   ---------------------
   -- Vers_Chaine     --
   ---------------------
   function Vers_Chaine (IP : T_Adresse_IP) return String is
      O1 : constant T_Adresse_IP := IP / 2 ** 24;
      O2 : constant T_Adresse_IP := (IP / 2 ** 16) mod 256;
      O3 : constant T_Adresse_IP := (IP / 2 ** 8)  mod 256;
      O4 : constant T_Adresse_IP :=  IP             mod 256;

      function Img (V : T_Adresse_IP) return String is
         S : constant String := T_Adresse_IP'Image (V);
      begin
         -- Supprimer l'espace initial produit par 'Image
         return Trim (S, Left);
      end Img;
   begin
      return Img (O1) & "." & Img (O2) & "." & Img (O3) & "." & Img (O4);
   end Vers_Chaine;

   --------------------
   -- Correspond     --
   --------------------
   function Correspond (Destination : T_Adresse_IP;
                        Reseau      : T_Adresse_IP;
                        Masque      : T_Adresse_IP) return Boolean is
   begin
      return (Destination and Masque) = (Reseau and Masque);
   end Correspond;

   -------------------------
   -- Longueur_Masque     --
   -------------------------
   function Longueur_Masque (Masque : T_Adresse_IP) return Natural is
      Compteur : Natural          := 0;
      Bit_Test : T_Adresse_IP     := 2 ** 31; -- bit de poids fort
   begin
      while Bit_Test /= 0 and then (Masque and Bit_Test) /= 0 loop
         Compteur := Compteur + 1;
         Bit_Test := Bit_Test / 2;
      end loop;
      return Compteur;
   end Longueur_Masque;

end Adresses_IP;
