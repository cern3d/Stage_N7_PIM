with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Command_Line;    use Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

procedure Routeur is

   type T_Address_IP is mod 2 ** 32;

   type Route_Record is record
      Dest       : T_Address_IP;
      Mask       : T_Address_IP;
      Iface      : String(1..32);
      Mask_Len   : Integer;
   end record;

   type Route_Node;
   type Route_Node_Access is access Route_Node;
   type Route_Node is record
      R    : Route_Record;
      Next : Route_Node_Access := null;
   end record;

   Table_Head : Route_Node_Access := null;

   -- Command line options
   Cache_Size    : Integer := 10;
   Policy        : String := "FIFO";
   Show_Stats    : Boolean := True;
   Table_File_UB    : Unbounded_String := To_Unbounded_String("table.txt");
   Packets_File_UB  : Unbounded_String := To_Unbounded_String("paquets.txt");
   Results_File_UB  : Unbounded_String := To_Unbounded_String("resultats.txt");

   -- Statistics
   Requests      : Natural := 0;
   Cache_Hits    : Natural := 0;
   Cache_Misses  : Natural := 0;

   -- per-run variables (moved here to avoid declarations after statements)
   PFile : File_Type;
   RFile : File_Type;
   Line : String(1..200);
   Last : Natural;
   Line_Num : Natural := 0;
   S_UB : Unbounded_String := To_Unbounded_String("");
   IP    : T_Address_IP := 0;
   Iface_UB : Unbounded_String := To_Unbounded_String("");
   Arg_UB : Unbounded_String := To_Unbounded_String("");

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

   procedure Append_Route(RR : Route_Record) is
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

   procedure Load_Table(File_Name : String) is
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
      null; -- suppress debug output
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
                Append_Route(RR);
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

   function Find_Interface(Dest_IP : T_Address_IP) return String is
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

   procedure Print_Table is
      Cur : Route_Node_Access := Table_Head;
   begin
      while Cur /= null loop
         Put_Line(IP_To_String(Cur.R.Dest) & " " & IP_To_String(Cur.R.Mask) & " " & Find_Interface(Cur.R.Dest));
         Cur := Cur.Next;
      end loop;
   end Print_Table;

begin
   -- parse command line (simple; last occurrence wins)
   for I in 1 .. Argument_Count loop
      Arg_UB := To_Unbounded_String(Argument(I));
      if To_String(Arg_UB) = "-c" and then I+1 <= Argument_Count then
         Cache_Size := Integer'Value(Argument(I+1));
      elsif To_String(Arg_UB) = "-p" and then I+1 <= Argument_Count then
         Policy := Argument(I+1);
      elsif To_String(Arg_UB) = "-s" then
         Show_Stats := True;
      elsif To_String(Arg_UB) = "-S" then
         Show_Stats := False;
      elsif To_String(Arg_UB) = "-t" and then I+1 <= Argument_Count then
         Table_File_UB := To_Unbounded_String(Argument(I+1));
      elsif To_String(Arg_UB) = "-q" and then I+1 <= Argument_Count then
         Packets_File_UB := To_Unbounded_String(Argument(I+1));
      elsif To_String(Arg_UB) = "-r" and then I+1 <= Argument_Count then
         Results_File_UB := To_Unbounded_String(Argument(I+1));
      end if;
   end loop;

   -- load routing table
   Load_Table(To_String(Table_File_UB));

   -- open packets and results
   Open(File => PFile, Mode => In_File, Name => To_String(Packets_File_UB));
   Create(File => RFile, Mode => Out_File, Name => To_String(Results_File_UB));
   while not End_Of_File(PFile) loop
         Get_Line(PFile, Line, Last);
         Line_Num := Line_Num + 1;
         S_UB := To_Unbounded_String(Trim_Line(Line(1..Last)));
         if Length(S_UB) = 0 then
            null;
         elsif To_String(S_UB) = "table" then
            Put_Line("table (ligne " & Integer'Image(Line_Num)(Integer'Image(Line_Num)'First+1..Integer'Image(Line_Num)'Last) & ")");
            Print_Table;
            New_Line;
         elsif To_String(S_UB) = "cache" then
            Put_Line("cache (ligne " & Integer'Image(Line_Num)(Integer'Image(Line_Num)'First+1..Integer'Image(Line_Num)'Last) & ")");
            New_Line;
         elsif To_String(S_UB) = "stat" then
            Put_Line("stat (ligne " & Integer'Image(Line_Num)(Integer'Image(Line_Num)'First+1..Integer'Image(Line_Num)'Last) & ")");
            Put_Line("demandes: " & Integer'Image(Requests)(Integer'Image(Requests)'First+1..Integer'Image(Requests)'Last));
            Put_Line("defauts: " & Integer'Image(Cache_Misses)(Integer'Image(Cache_Misses)'First+1..Integer'Image(Cache_Misses)'Last));
            New_Line;
         elsif To_String(S_UB) = "fin" then
            Put_Line("fin (ligne " & Integer'Image(Line_Num)(Integer'Image(Line_Num)'First+1..Integer'Image(Line_Num)'Last) & ")");
            exit;
         else
            -- Check if it's a known command (in case recognition fails)
            if To_String(S_UB) /= "table" and To_String(S_UB) /= "cache" and To_String(S_UB) /= "stat" and To_String(S_UB) /= "fin" then
               -- packet to route
               Requests := Requests + 1;
               IP := Parse_IP(To_String(S_UB));
               Iface_UB := To_Unbounded_String(Trim_Line(Find_Interface(IP)));
               if Length(Iface_UB) = 0 then
                  null; -- no route found
               end if;
               Put_Line(To_String(S_UB) & " " & To_String(Iface_UB));
               Put(RFile, To_String(S_UB) & " " & To_String(Iface_UB));
               New_Line(RFile);
               Cache_Misses := Cache_Misses + 1;
            end if;
         end if;
   end loop;
   Close(PFile);
   Close(RFile);
exception
   when others =>
      if Is_Open(PFile) then Close(PFile); end if;
      if Is_Open(RFile) then Close(RFile); end if;
      raise;
end Routeur;

--  x86_64-linux-gnu-gcc-13 -c -gnatwa routeur_LL.adb
--  routeur_LL.adb:5:11: warning: file name does not match unit name, should be "routeur_ll.adb" [enabled by default]
--  routeur_LL.adb:26:04: warning: variable "Cache_Size" is assigned but never read [-gnatwm]
--  routeur_LL.adb:27:04: warning: variable "Policy" is assigned but never read [-gnatwm]
--  routeur_LL.adb:28:04: warning: variable "Show_Stats" is assigned but never read [-gnatwm]
--  routeur_LL.adb:35:04: warning: variable "Cache_Hits" is not referenced [-gnatwu]
--  routeur_LL.adb:126:07: warning: "A" is not modified, could be declared constant [-gnatwk]
--  routeur_LL.adb:127:07: warning: "B" is not modified, could be declared constant [-gnatwk]
--  routeur_LL.adb:128:07: warning: "C" is not modified, could be declared constant [-gnatwk]
--  routeur_LL.adb:129:07: warning: "D" is not modified, could be declared constant [-gnatwk]
--  routeur_LL.adb:153:07: warning: "New_Node" is not modified, could be declared constant [-gnatwk]
--  x86_64-linux-gnu-gnatbind-13 -x routeur_LL.ali
--  x86_64-linux-gnu-gnatlink-13 routeur_LL.ali