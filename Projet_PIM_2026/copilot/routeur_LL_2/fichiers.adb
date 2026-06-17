-- Body du package Fichiers
package body Fichiers is

   procedure Open_Files(Packets_File : String; Results_File : String;
                        PFile : out File_Type; RFile : out File_Type) is
   begin
      Open(File => PFile, Mode => In_File, Name => Packets_File);
      Create(File => RFile, Mode => Out_File, Name => Results_File);
   end Open_Files;

   procedure Close_Files(PFile : in out File_Type; RFile : in out File_Type) is
   begin
      if Is_Open(PFile) then
         Close(PFile);
      end if;
      if Is_Open(RFile) then
         Close(RFile);
      end if;
   end Close_Files;

   procedure Write_Result(RFile : File_Type; IP : String; eth : String) is
   begin
      Put(RFile, IP & " " & eth);
      New_Line(RFile);
   end Write_Result;

end Fichiers;
