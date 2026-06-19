-- Package pour la gestion des fichiers d'entrée/sortie
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;

package Fichiers is

   -- Ouvre les fichiers de paquets et de résultats
   procedure Open_Files(Packets_File : String; Results_File : String;
                        PFile : out File_Type; RFile : out File_Type);

   -- Ferme les fichiers
   procedure Close_Files(PFile : in out File_Type; RFile : in out File_Type);

   -- Écrit un résultat de routage dans le fichier de résultats
   procedure Write_Result(RFile : File_Type; IP : String; eth : String);

end Fichiers;
