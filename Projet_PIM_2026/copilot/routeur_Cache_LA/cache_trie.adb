-- Body du package Cache_Trie
with Types_Routeur;
with IP_Utils;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
use Types_Routeur;
use IP_Utils;

package body Cache_Trie is

   type Trie_Node;
   type Trie_Node_Access is access Trie_Node;
   type Cache_Entry;
   type Cache_Entry_Access is access Cache_Entry;
  
      type Child_Array is array(0..1) of Trie_Node_Access;

   type Trie_Node is record
      Child : Child_Array := (others => null);
      Item  : Cache_Entry_Access := null;
   end record;

   type Cache_Entry is record
      Dest     : T_Address_IP := 0;
      Mask     : T_Address_IP := 0;
      Mask_Len : Integer := 0;
      Iface    : String(1..32) := (others => ' ');
      Prev     : Cache_Entry_Access := null;
      Next     : Cache_Entry_Access := null;
      Use_Count: Natural := 0;
      Node_Ptr : Trie_Node_Access := null;
   end record;

   Root : Trie_Node_Access := null;
   Head, Tail : Cache_Entry_Access := null;
   Current_Size : Natural := 0;
   Max_Size : Natural := 10;
   Policy : Ada.Strings.Unbounded.Unbounded_String := To_Unbounded_String("FIFO");

   Requests : Natural := 0;
   Hits : Natural := 0;
   Misses : Natural := 0;

   function Get_Bit(I : T_Address_IP; Pos : Integer) return Integer is
   begin
      -- Pos: 0 = bit de poids fort (31)
      if (I and (2 ** (31 - Pos))) /= 0 then
         return 1;
      else
         return 0;
      end if;
   end Get_Bit;

   procedure Init(Size : Integer; Policy : String) is
   begin
      -- reset
      Root := new Trie_Node'(Child => (others => null), Item => null);
      Head := null; Tail := null;
      Current_Size := 0;
      if Size < 0 then
         Max_Size := 0;
      else
         Max_Size := Natural(Size);
      end if;
      Cache_Trie.Policy := To_Unbounded_String(Policy);
      Requests := 0; Hits := 0; Misses := 0;
   end Init;

   procedure Unlink_Entry(E : in out Cache_Entry_Access) is
   begin
      if E = null then
         return;
      end if;
      if E.Prev /= null then
         E.Prev.Next := E.Next;
      else
         Head := E.Next;
      end if;
      if E.Next /= null then
         E.Next.Prev := E.Prev;
      else
         Tail := E.Prev;
      end if;
      E.Prev := null; E.Next := null;
   end Unlink_Entry;

   procedure Link_To_Tail(E : in out Cache_Entry_Access) is
   begin
      if E = null then
         return;
      end if;
      E.Prev := Tail;
      E.Next := null;
      if Tail /= null then
         Tail.Next := E;
      end if;
      Tail := E;
      if Head = null then
         Head := E;
      end if;
   end Link_To_Tail;

   procedure Evict_One is
      To_Remove : Cache_Entry_Access := null;
      Cur : Cache_Entry_Access;
      Min_Use : Natural := 0;
   begin
      if Current_Size = 0 then
         return;
      end if;
      if Max_Size = 0 then
         return;
      end if;
      if To_String(Policy) = "FIFO" then
         To_Remove := Head;
      elsif To_String(Policy) = "LRU" then
         To_Remove := Head; -- head is least recently used
      elsif To_String(Policy) = "LFU" then
         -- find minimal use_count
         Cur := Head;
         if Cur /= null then
            Min_Use := Cur.Use_Count;
            To_Remove := Cur;
            Cur := Cur.Next;
         end if;
         while Cur /= null loop
            if Cur.Use_Count < Min_Use then
               Min_Use := Cur.Use_Count;
               To_Remove := Cur;
            end if;
            Cur := Cur.Next;
         end loop;
      else
         To_Remove := Head;
      end if;

      if To_Remove = null then
         return;
      end if;
      -- remove from trie
      if To_Remove.Node_Ptr /= null then
         To_Remove.Node_Ptr.all.Item := null;
      end if;
      -- unlink from list
      Unlink_Entry(To_Remove);
      -- free cell
      To_Remove := null;
      if Current_Size > 0 then
         Current_Size := Current_Size - 1;
      end if;
   end Evict_One;

   function Lookup(Dest_IP : T_Address_IP) return String is
      Node : Trie_Node_Access := Root;
      Best : Cache_Entry_Access := null;
      Bit : Integer;
      I : Integer := 0;
      S : String(1..32) := (others => ' ');
      Last : Integer := 0;
   begin
      Requests := Requests + 1;
      -- traverse trie, keep last seen entry (longest prefix)
      for I in 0 .. 31 loop
         if Node = null then
            exit;
         end if;
         if Node.all.Item /= null then
            Best := Node.all.Item;
         end if;
         Bit := Get_Bit(Dest_IP, I);
         Node := Node.all.Child(Bit);
      end loop;
      -- best entry is tracked during traversal; no further check needed here
      if Best = null then
         Misses := Misses + 1;
         return "";
      else
         Hits := Hits + 1;
         Best.Use_Count := Best.Use_Count + 1;
         -- update LRU: move to tail if policy LRU
             if To_String(Policy) = "LRU" then
            Unlink_Entry(Best);
            Link_To_Tail(Best);
         end if;
         -- return iface trimmed
         Last := 0;
         for I in Best.Iface'Range loop
            if Best.Iface(I) /= ' ' then
               Last := I;
            end if;
         end loop;
         if Last = 0 then
            return "";
         else
            S(1..Last) := Best.Iface(1..Last);
            return S(1..Last);
         end if;
      end if;
   end Lookup;

   procedure Insert(Dest_IP : T_Address_IP; Mask : T_Address_IP; Mask_Len : Integer; Iface : String) is
      Network : T_Address_IP := Dest_IP and Mask;
      Node : Trie_Node_Access := Root;
      B : Integer;
      New_Entry : Cache_Entry_Access;
      I : Integer;
      IFace_Len : Integer := 0;
      ML : Integer := Mask_Len;
   begin
      -- if cache disabled
      if Max_Size = 0 then
         return;
      end if;

      -- traverse/create nodes for mask_len bits
      if ML > 32 then
         ML := 32;
      elsif ML < 0 then
         ML := 0;
      end if;
      if ML > 0 then
         for I in 0 .. Mask_Len - 1 loop
            B := Get_Bit(Network, I);
            if Node.all.Child(B) = null then
               Node.all.Child(B) := new Trie_Node'(Child => (others => null), Item => null);
            end if;
            Node := Node.all.Child(B);
         end loop;
      end if;
      -- if already present, update iface and mask
      if Node.all.Item /= null then
         -- copy iface safely into fixed field
         declare
            L : Integer := Iface'Length;
         begin
            if L > 32 then L := 32; end if;
            for I in 1 .. L loop
               Node.all.Item.Iface(I) := Iface(I);
            end loop;
         end;
         Node.all.Item.Mask := Mask;
         Node.all.Item.Mask_Len := ML;
         return;
      end if;

      -- create new entry
      New_Entry := new Cache_Entry'(Dest => Network, Mask => Mask, Mask_Len => Mask_Len, Iface => (others => ' '), Prev => null, Next => null, Use_Count => 0, Node_Ptr => Node);
      -- copy Iface into fixed field
      declare
         L : Integer := Iface'Length;
      begin
         if L > 32 then L := 32; end if;
         for I in 1 .. L loop
            New_Entry.Iface(I) := Iface(I);
         end loop;
      end;
      Node.all.Item := New_Entry;
      -- append to tail
      Link_To_Tail(New_Entry);
      Current_Size := Current_Size + 1;
      -- evict if necessary
      if Current_Size > Max_Size then
         Evict_One;
      end if;
   end Insert;

   procedure Print_Cache is
      Cur : Cache_Entry_Access := Head;
      S : String(1..200);
      IFace_Str : String(1..32);
      Last : Integer;
   begin
      while Cur /= null loop
         -- trim iface
         Last := 0;
         for I in Cur.Iface'Range loop
            if Cur.Iface(I) /= ' ' then
               Last := I;
            end if;
         end loop;
         if Last = 0 then
            IFace_Str := (others => ' ');
         else
            IFace_Str := (others => ' ');
            for I in 1 .. Last loop IFace_Str(I) := Cur.Iface(I); end loop;
         end if;
         Put(IP_To_String(Cur.Dest) & " " & IP_To_String(Cur.Mask));
         if Last > 0 then
            Put(" ");
            for I in 1 .. Last loop
               Put(IFace_Str(I));
            end loop;
         end if;
         New_Line;
         Cur := Cur.Next;
      end loop;
   end Print_Cache;

   procedure Get_Stats(Requests : out Natural; Hits : out Natural; Misses : out Natural) is
   begin
      Requests := Cache_Trie.Requests;
      Hits := Cache_Trie.Hits;
      Misses := Cache_Trie.Misses;
   end Get_Stats;

end Cache_Trie;
