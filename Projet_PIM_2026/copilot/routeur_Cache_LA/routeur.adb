-- Routeur simple avec liste chaînée - version modulaire
with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Command_Line;    use Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Types_Routeur;       use Types_Routeur;
with IP_Utils;            use IP_Utils;
with Table_Routage;       use Table_Routage;
with Fichiers;            use Fichiers;

procedure Routeur is

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

   -- File handles and variables
   PFile : File_Type;
   RFile : File_Type;
   Line : String(1..200);
   Last : Natural;
   Line_Num : Natural := 0;
   S_UB : Unbounded_String := To_Unbounded_String("");
   IP    : T_Address_IP := 0;
   Iface_UB : Unbounded_String := To_Unbounded_String("");
   Arg_UB : Unbounded_String := To_Unbounded_String("");
   Table_Head : Route_Node_Access := null;

begin
   -- Parse command line arguments
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

   -- Load routing table
   Load_Table(To_String(Table_File_UB), Table_Head);

   -- Open files
   Open_Files(To_String(Packets_File_UB), To_String(Results_File_UB), PFile, RFile);

   -- Main processing loop
   while not End_Of_File(PFile) loop
      Get_Line(PFile, Line, Last);
      Line_Num := Line_Num + 1;
      S_UB := To_Unbounded_String(Trim_Line(Line(1..Last)));

      if Length(S_UB) = 0 then
         null;
      elsif To_String(S_UB) = "table" then
         Put_Line("table (ligne " & Integer'Image(Line_Num)(Integer'Image(Line_Num)'First+1..Integer'Image(Line_Num)'Last) & ")");
         Print_Table(Table_Head);
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
         -- Check if it's not a known command and then route the packet
         if To_String(S_UB) /= "table" and To_String(S_UB) /= "cache" and 
            To_String(S_UB) /= "stat" and To_String(S_UB) /= "fin" then
            Requests := Requests + 1;
            IP := Parse_IP(To_String(S_UB));
            Iface_UB := To_Unbounded_String(Trim_Line(Find_Interface(IP, Table_Head)));
            if Length(Iface_UB) = 0 then
               null; -- no route found
            end if;
            Put_Line(To_String(S_UB) & " " & To_String(Iface_UB));
            Write_Result(RFile, To_String(S_UB), To_String(Iface_UB));
            Cache_Misses := Cache_Misses + 1;
         end if;
      end if;
   end loop;

   -- Close files
   Close_Files(PFile, RFile);

exception
   when others =>
      Close_Files(PFile, RFile);
      raise;
end Routeur;