-- Package pour la gestion des fichiers d'entrée/sortie
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;

package Fichiers is

   -- Ouvre les fichiers de paquets et de résultats.
   --
   -- paramètres
   --     Packets_File : nom du fichier d'entrée contenant les paquets
   --     Results_File : nom du fichier de sortie pour les résultats
   --     PFile        : handle de fichier d'entrée retourné
   --     RFile        : handle de fichier de sortie retourné
   procedure Open_Files(Packets_File : String; Results_File : String;
                        PFile : out File_Type; RFile : out File_Type)
     with Pre => Packets_File /= "" and Results_File /= "",
          Post => Ada.Text_IO.Is_Open(PFile) and Ada.Text_IO.Is_Open(RFile);

   -- Ferme les fichiers ouverts.
   --
   -- paramètres
   --     PFile : handle du fichier d'entrée
   --     RFile : handle du fichier de sortie
   procedure Close_Files(PFile : in out File_Type; RFile : in out File_Type)
     with Post => not Ada.Text_IO.Is_Open(PFile) and not Ada.Text_IO.Is_Open(RFile);

   -- Écrit une ligne de résultat de routage dans le fichier de sortie.
   --
   -- paramètres
   --     RFile : handle du fichier de sortie
   --     IP    : adresse IP du paquet traité
   --     eth   : interface de sortie choisie
   procedure Write_Result(RFile : File_Type; IP : String; eth : String)
     with Pre => Ada.Text_IO.Is_Open(RFile);

end Fichiers;
