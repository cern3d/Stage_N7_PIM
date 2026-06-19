-- Body du package Table_Routage
with Ada.Text_IO;
use Ada.Text_IO;
with IP_Utils;
use IP_Utils;

package body Table_Routage is

   procedure Append_Route(RR : Route_Record; Table_Head : in out Route_Node_Access) is
      New_Node : Route_Node_Access := new Route_Node'(R => RR, Next => null);
      Cur : Route_Node_Access := Table_Head;
   begin
      if Table_Head = null then
         Table_Head := New_Node;
      else
         while Cur.Next /= null loop
            Cur := Cur.Next;
         end loop;
         Cur.Next := New_Node;
      end if;
   end Append_Route;

   procedure Load_Table(File_Name : String; Table_Head : out Route_Node_Access) is
      F : File_Type;
      Line : String(1..200);
      Last : Natural;
      RR : Route_Record;
      -- tokenization buffers
      W1, W2, W3 : String(1..64) := (others => ' ');
      W1_Len, W2_Len, W3_Len : Natural := 0;
      token : String(1..200) := (others => ' ');
      token_len : Natural := 0;
      Temp1 : String(1..64) := (others => ' ');
      Temp2 : String(1..64) := (others => ' ');
      Temp3 : String(1..64) := (others => ' ');
      L : Integer := 0;
   begin
      Table_Head := null;
      Open(File => F, Mode => In_File, Name => File_Name);
      while not End_Of_File(F) loop
         Get_Line(F, Line, Last);
         if Last = 0 then
            null;
         else
             -- tokenize Line(1..Last) into W1, W2, W3 using simple scanner
             W1_Len := 0; W2_Len := 0; W3_Len := 0; token_len := 0;
             for J in 1 .. Last loop
                if Line(J) /= ' ' then
                   token_len := token_len + 1;
                   token(token_len) := Line(J);
                elsif token_len > 0 then
                   if W1_Len = 0 then
                      for X in 1 .. token_len loop
                         W1(X) := token(X);
                      end loop;
                      W1_Len := token_len;
                   elsif W2_Len = 0 then
                      for X in 1 .. token_len loop
                         W2(X) := token(X);
                      end loop;
                      W2_Len := token_len;
                   elsif W3_Len = 0 then
                      for X in 1 .. token_len loop
                         W3(X) := token(X);
                      end loop;
                      W3_Len := token_len;
                   end if;
                   -- reset token
                   for X in 1 .. token_len loop token(X) := ' '; end loop;
                   token_len := 0;
                end if;
             end loop;
             if token_len > 0 then
                if W1_Len = 0 then
                   for X in 1 .. token_len loop W1(X) := token(X); end loop; W1_Len := token_len;
                elsif W2_Len = 0 then
                   for X in 1 .. token_len loop W2(X) := token(X); end loop; W2_Len := token_len;
                elsif W3_Len = 0 then
                   for X in 1 .. token_len loop W3(X) := token(X); end loop; W3_Len := token_len;
                end if;
             end if;
             -- tokenization complete
             if W1_Len > 0 and W2_Len > 0 and W3_Len > 0 then
                for X in 1 .. W1_Len loop Temp1(X) := W1(X); end loop;
                for X in 1 .. W2_Len loop Temp2(X) := W2(X); end loop;
                for X in 1 .. W3_Len loop Temp3(X) := W3(X); end loop;
                -- validate tokens contain dots before parsing
                declare
                   D1, D2 : Natural := 0;
                begin
                   for Y in 1 .. W1_Len loop
                      if Temp1(Y) = '.' then D1 := D1 + 1; end if;
                   end loop;
                   for Y in 1 .. W2_Len loop
                      if Temp2(Y) = '.' then D2 := D2 + 1; end if;
                   end loop;
                   if D1 > 0 and D2 > 0 then
                      RR.Dest := Parse_IP(Temp1(1..W1_Len));
                      RR.Mask := Parse_IP(Temp2(1..W2_Len));
                   end if;
                end;
                RR.Mask_Len := Mask_Length(RR.Mask);
                RR.Iface := (1..32 => ' ');
                L := W3_Len;
                if L > 32 then
                   L := 32;
                end if;
                for K in 1 .. L loop
                   RR.Iface(K) := Temp3(K);
                end loop;
                Append_Route(RR, Table_Head);
             end if;
         end if;
      end loop;
      Close(F);
   exception
      when others =>
         if Is_Open(F) then
            Close(F);
         end if;
         raise;
   end Load_Table;

   function Find_Interface(Dest_IP : T_Address_IP; Table_Head : Route_Node_Access) return String is
      Cur : Route_Node_Access := Table_Head;
      Best_Mask : Integer := -1;
      Best_If   : String(1..32) := (others => ' ');
      S : String(1..32) := (others => ' ');
      Last : Integer := 0;
   begin
      while Cur /= null loop
         if (Dest_IP and Cur.R.Mask) = (Cur.R.Dest and Cur.R.Mask) then
            if Cur.R.Mask_Len > Best_Mask then
               Best_Mask := Cur.R.Mask_Len;
               Best_If := Cur.R.Iface;
            end if;
         end if;
         Cur := Cur.Next;
      end loop;
      if Best_Mask = -1 then
         return "";
      else
         S := Best_If;
         Last := 0;
         for I in S'Range loop
            if S(I) /= ' ' then
               Last := I;
            end if;
         end loop;
         if Last = 0 then
            return "";
         else
            return S(1..Last);
         end if;
      end if;
   end Find_Interface;

   function Find_Route(Dest_IP : T_Address_IP; Table_Head : Route_Node_Access) return Route_Record is
      Cur : Route_Node_Access := Table_Head;
      Best_Mask : Integer := -1;
      Best_RR   : Route_Record := (Dest => 0, Mask => 0, Iface => (1..32 => ' '), Mask_Len => -1);
   begin
      while Cur /= null loop
         if (Dest_IP and Cur.R.Mask) = (Cur.R.Dest and Cur.R.Mask) then
            if Cur.R.Mask_Len > Best_Mask then
               Best_Mask := Cur.R.Mask_Len;
               Best_RR := Cur.R;
            end if;
         end if;
         Cur := Cur.Next;
      end loop;
      if Best_Mask = -1 then
         return Best_RR;
      else
         return Best_RR;
      end if;
   end Find_Route;

   procedure Print_Table(Table_Head : Route_Node_Access) is
      Cur : Route_Node_Access := Table_Head;
   begin
      while Cur /= null loop
         Put_Line(IP_To_String(Cur.R.Dest) & " " & IP_To_String(Cur.R.Mask) & " " & Find_Interface(Cur.R.Dest, Table_Head));
         Cur := Cur.Next;
      end loop;
   end Print_Table;

end Table_Routage;
