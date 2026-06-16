with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
-- Tu devras instancier ici ton module de liste chaînée (ex: avec un type Route)

procedure Routeur_Simple is

    -- Définition du type IP selon le sujet
    type T_Adresse_IP is mod 2**32;
    
    -- Structure d'une Route
    type T_Route is record
        Destination : T_Adresse_IP;
        Masque      : T_Adresse_IP;
        Interface_R : Unbounded_String;
    end record;

    -- Variables pour les noms de fichiers (valeurs par défaut)
    Fichier_Table    : Unbounded_String := To_Unbounded_String("table.txt");
    Fichier_Paquets  : Unbounded_String := To_Unbounded_String("paquets.txt");
    Fichier_Resultat : Unbounded_String := To_Unbounded_String("resultats.txt");

    -- Variables Fichiers
    File_T, File_P, File_R : File_Type;

    -- Procédure pour analyser la ligne de commande
    procedure Analyser_Ligne_Commande is
        i : Integer := 1;
    begin
        while i <= Argument_Count loop
            if Argument(i) = "-t" then
                Fichier_Table := To_Unbounded_String(Argument(i + 1));
                i := i + 2;
            elsif Argument(i) = "-q" then
                Fichier_Paquets := To_Unbounded_String(Argument(i + 1));
                i := i + 2;
            elsif Argument(i) = "-r" then
                Fichier_Resultat := To_Unbounded_String(Argument(i + 1));
                i := i + 2;
            else
                -- On ignore les options de cache (-c, -p, -S, -s) pour le routeur simple
                i := i + 1;
            end if;
        end loop;
    end Analyser_Ligne_Commande;

    -- Procédure de routage d'une IP
    procedure Router_Paquet(IP_Dest : in T_Adresse_IP; Interf_Trouvee : out Unbounded_String) is
        -- Ici, tu parcours ta liste chaînée de routes.
        -- Le principe : (IP_Dest and Route.Masque) = (Route.Destination and Route.Masque)
        -- Si plusieurs correspondent, on garde celle avec le masque le plus long.
    begin
        -- Simulation de recherche (à remplacer par ton itérateur de liste)
        Interf_Trouvee := To_Unbounded_String("eth_default"); 
    end Router_Paquet;

    Ligne_Fichier : Unbounded_String;
    Interf_Sortie : Unbounded_String;
    Numero_Ligne  : Positive := 1;

begin
    -- 1. Analyse de la ligne de commande
    Analyser_Ligne_Commande;

    -- 2. Chargement de la table de routage
    Open(File_T, In_File, To_String(Fichier_Table));
    while not End_Of_File(File_T) loop
        Ligne_Fichier := To_Unbounded_String(Get_Line(File_T));
        -- TODO : Parser la ligne (Extraire IP, Masque, Interface)
        -- TODO : Insérer dans la liste chaînée
    end loop;
    Close(File_T);

    -- 3. Traitement des paquets
    Open(File_P, In_File, To_String(Fichier_Paquets));
    Create(File_R, Out_File, To_String(Fichier_Resultat));

    while not End_Of_File(File_P) loop
        Ligne_Fichier := To_Unbounded_String(Get_Line(File_P));
        
        -- Gestion des commandes spéciales
        if Ligne_Fichier = "table" then
            Put_Line("table (ligne " & Integer'Image(Numero_Ligne) & ")");
            -- TODO : Afficher la liste des routes
        elsif Ligne_Fichier = "cache" or Ligne_Fichier = "stat" then
            -- Ignoré pour le routeur simple, mais on peut afficher la commande
            Put_Line(To_String(Ligne_Fichier) & " (ligne " & Integer'Image(Numero_Ligne) & ")");
        elsif Ligne_Fichier = "fin" then
            Put_Line("fin (ligne " & Integer'Image(Numero_Ligne) & ")");
            exit; -- Arrêt du traitement
        else
            -- C'est une adresse IP
            -- TODO : Convertir le String en T_Adresse_IP
            -- IP_Recherche := Convertir_String_Vers_IP(To_String(Ligne_Fichier));
            
            -- Router_Paquet(IP_Recherche, Interf_Sortie);
            
            -- Écriture dans le fichier résultat (Format : IP Interface)
            Put_Line(File_R, To_String(Ligne_Fichier) & " " & To_String(Interf_Sortie));
        end if;
        Numero_Ligne := Numero_Ligne + 1;
    end loop;

    Close(File_P);
    Close(File_R);

end Routeur_Simple;