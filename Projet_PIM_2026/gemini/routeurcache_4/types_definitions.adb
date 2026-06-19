package body Types_Definitions is

   ------------------
   -- String_To_IP --
   ------------------
   function String_To_IP (S : String) return T_Adresse_IP is
      Resultat      : T_Adresse_IP := 0;
      Octet_Courant : T_Adresse_IP := 0;
      Poids         : T_Adresse_IP := 256**3;
   begin
      for I in S'Range loop
         if S(I) >= '0' and S(I) <= '9' then
            Octet_Courant := Octet_Courant * 10 + T_Adresse_IP(Character'Pos(S(I)) - Character'Pos('0'));
         elsif S(I) = '.' then
            Resultat      := Resultat + (Octet_Courant * Poids);
            Poids         := Poids / 256;
            Octet_Courant := 0;
         end if;
      end loop;
      Resultat := Resultat + (Octet_Courant * Poids);
      return Resultat;
   end String_To_IP;

   ------------------
   -- IP_To_String --
   ------------------
   function IP_To_String (IP : T_Adresse_IP) return String is
      O1 : T_Adresse_IP := IP / 256**3;
      O2 : T_Adresse_IP := (IP / 256**2) mod 256;
      O3 : T_Adresse_IP := (IP / 256) mod 256;
      O4 : T_Adresse_IP := IP mod 256;

      function Clean_Img (V : T_Adresse_IP) return String is
         S : String := T_Adresse_IP'Image(V);
      begin
         if S(S'First) = ' ' then
            return S(S'First + 1 .. S'Last);
         else
            return S;
         end if;
      end Clean_Img;
   begin
      return Clean_Img(O1) & "." & Clean_Img(O2) & "." & Clean_Img(O3) & "." & Clean_Img(O4);
   end IP_To_String;

end Types_Definitions;