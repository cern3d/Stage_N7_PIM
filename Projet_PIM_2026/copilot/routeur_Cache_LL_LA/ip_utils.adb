-- Body du package IP_Utils
package body IP_Utils is

   function Trim_Line(S : String) return String is
      First, Last : Integer;
   begin
      First := S'First;
      while First <= S'Last and then (S(First) = ' ' or S(First) = ASCII.CR or S(First) = ASCII.LF) loop
         First := First + 1;
      end loop;
      if First > S'Last then
         return "";
      end if;
      Last := S'Last;
      while Last >= First and then (S(Last) = ' ' or S(Last) = ASCII.CR or S(Last) = ASCII.LF) loop
         Last := Last - 1;
      end loop;
      return S(First..Last);
   end Trim_Line;

   function Parse_IP(S : String) return T_Address_IP is
      Str : constant String := Trim_Line(S);
      A,B,C,D : Integer := 0;
      Dot1, Dot2, Dot3 : Natural := 0;
   begin
      -- find first dot
      for Pos in Str'Range loop
         if Str(Pos) = '.' then
            Dot1 := Pos;
            exit;
         end if;
      end loop;
      if Dot1 = 0 then
         return 0;
      end if;
      -- find second dot
      for Pos in Dot1+1 .. Str'Last loop
         if Str(Pos) = '.' then
            Dot2 := Pos;
            exit;
         end if;
      end loop;
      if Dot2 = 0 then
         return 0;
      end if;
      -- find third dot
      for Pos in Dot2+1 .. Str'Last loop
         if Str(Pos) = '.' then
            Dot3 := Pos;
            exit;
         end if;
      end loop;
      if Dot3 = 0 then
         return 0;
      end if;
      -- parse octets with exception handling
      begin
         A := Integer'Value(Trim_Line(Str(1..Dot1-1)));
      exception
         when others => A := 0;
      end;
      begin
         B := Integer'Value(Trim_Line(Str(Dot1+1..Dot2-1)));
      exception
         when others => B := 0;
      end;
      begin
         C := Integer'Value(Trim_Line(Str(Dot2+1..Dot3-1)));
      exception
         when others => C := 0;
      end;
      begin
         D := Integer'Value(Trim_Line(Str(Dot3+1..Str'Last)));
      exception
         when others => D := 0;
      end;
      return T_Address_IP(A) * 2**24 + T_Address_IP(B) * 2**16 + T_Address_IP(C) * 2**8 + T_Address_IP(D);
   end Parse_IP;

   function IP_To_String(I : T_Address_IP) return String is
      A : Integer := Integer((I / 2**24) mod 256);
      B : Integer := Integer((I / 2**16) mod 256);
      C : Integer := Integer((I / 2**8) mod 256);
      D : Integer := Integer(I mod 256);
   begin
      return Integer'Image(A)(Integer'Image(A)'First+1..Integer'Image(A)'Last) & "." &
             Integer'Image(B)(Integer'Image(B)'First+1..Integer'Image(B)'Last) & "." &
             Integer'Image(C)(Integer'Image(C)'First+1..Integer'Image(C)'Last) & "." &
             Integer'Image(D)(Integer'Image(D)'First+1..Integer'Image(D)'Last);
   end IP_To_String;

   function Mask_Length(M : T_Address_IP) return Integer is
      Count : Integer := 0;
      X : T_Address_IP := M;
   begin
      for I in 0 .. 31 loop
         if (X and (2 ** 31)) /= 0 then
            Count := Count + 1;
            X := X * 2;
         else
            exit;
         end if;
      end loop;
      return Count;
   end Mask_Length;

end IP_Utils;
