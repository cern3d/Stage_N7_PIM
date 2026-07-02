-- Package pour la gestion des fichiers d'entrée/sortie
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;

package Fichiers is

   -- Ouvre les fichiers de paquets et de résultats.
   -- Paramètres:
   --   Packets_File : nom du fichier d'entrée contenant les paquets.
   --   Results_File : nom du fichier de sortie pour les résultats.
   --   PFile        : handle de fichier d'entrée retourné.
   --   RFile        : handle de fichier de sortie retourné.
   procedure Open_Files(Packets_File : String; Results_File : String;
                        PFile : out File_Type; RFile : out File_Type);

   -- Ferme les fichiers ouverts.
   procedure Close_Files(PFile : in out File_Type; RFile : in out File_Type);

   -- Écrit une ligne de résultat de routage dans le fichier de sortie.
   -- Paramètres:
   --   RFile : handle du fichier de sortie.
   --   IP    : adresse IP du paquet traité.
   --   eth   : interface de sortie choisie.
   procedure Write_Result(RFile : File_Type; IP : String; eth : String);

end Fichiers;
