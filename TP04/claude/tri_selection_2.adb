with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Numerics.Discrete_Random;

procedure Tri_Selection is

    Capacite : constant Integer := 10;
    type T_TableauElements is array (1 .. Capacite) of Integer;
    type T_Tableau is record
        Elements : T_TableauElements;
        Taille   : Integer;
    end record;

    -- =========================================================
    --  Opérateur d'égalité (inchangé)
    -- =========================================================
    function "=" (Tab1, Tab2 : in T_Tableau) return Boolean is
        Indice : Integer;
    begin
        if Tab1.Taille /= Tab2.Taille then
            return False;
        end if;
        Indice := 1;
        while Indice <= Tab1.Taille
            and then Tab1.Elements (Indice) = Tab2.Elements (Indice)
        loop
            Indice := Indice + 1;
        end loop;
        return Indice > Tab1.Taille;
    end "=";

    -- =========================================================
    --  Affichage (inchangé)
    -- =========================================================
    procedure Ecrire (Tab : in T_Tableau) is
    begin
        Put ('[');
        if Tab.Taille > 0 then
            Put (Tab.Elements (1), 1);
            for I in 2 .. Tab.Taille loop
                Put (", ");
                Put (Tab.Elements (I), 1);
            end loop;
        end if;
        Put (']');
    end Ecrire;

    -- =========================================================
    --  Tri par sélection (inchangé)
    -- =========================================================
    procedure Trier (Tab : in out T_Tableau) is
        Indice_Min : Integer;
        Temp       : Integer;
    begin
        for I in 1 .. Tab.Taille - 1 loop
            Indice_Min := I;
            for J in I + 1 .. Tab.Taille loop
                if Tab.Elements (J) < Tab.Elements (Indice_Min) then
                    Indice_Min := J;
                end if;
            end loop;
            if Indice_Min /= I then
                Temp                     := Tab.Elements (I);
                Tab.Elements (I)         := Tab.Elements (Indice_Min);
                Tab.Elements (Indice_Min) := Temp;
            end if;
        end loop;
    end Trier;

    -- =========================================================
    --  Sous-programmes de vérification
    -- =========================================================

    -- Objectif : Vérifier que le tableau est trié en ordre croissant.
    -- Paramètre : Tab : le tableau à vérifier.
    -- Résultat  : True si chaque élément est <= au suivant.
    function Est_Trie (Tab : in T_Tableau) return Boolean is
    begin
        for I in 1 .. Tab.Taille - 1 loop
            if Tab.Elements (I) > Tab.Elements (I + 1) then
                return False;
            end if;
        end loop;
        return True;
    end Est_Trie;

    -- Objectif : Compter le nombre d'occurrences d'une valeur dans un tableau.
    -- Paramètres :
    --   Tab    : le tableau dans lequel chercher.
    --   Valeur : la valeur à compter.
    -- Résultat : le nombre d'occurrences de Valeur dans Tab.
    function Occurrences (Tab : in T_Tableau; Valeur : in Integer)
                          return Integer is
        Compteur : Integer := 0;
    begin
        for I in 1 .. Tab.Taille loop
            if Tab.Elements (I) = Valeur then
                Compteur := Compteur + 1;
            end if;
        end loop;
        return Compteur;
    end Occurrences;

    -- Objectif : Vérifier que les deux tableaux contiennent exactement
    --            les mêmes éléments avec les mêmes occurrences.
    -- Paramètres :
    --   Tab1 : le tableau original (avant tri).
    --   Tab2 : le tableau trié.
    -- Résultat : True si Tab1 et Tab2 sont des permutations l'un de l'autre.
    -- Remarque : On itère sur les éléments de Tab1 et on vérifie que chacun
    --            apparaît le même nombre de fois dans Tab2.
    function Memes_Elements (Tab1, Tab2 : in T_Tableau) return Boolean is
    begin
        -- Même taille obligatoire
        if Tab1.Taille /= Tab2.Taille then
            return False;
        end if;
        -- Pour chaque élément de Tab1, même nombre d'occurrences dans Tab2
        for I in 1 .. Tab1.Taille loop
            if Occurrences (Tab1, Tab1.Elements (I)) /=
               Occurrences (Tab2, Tab1.Elements (I))
            then
                return False;
            end if;
        end loop;
        return True;
    end Memes_Elements;

    -- =========================================================
    --  Vérification complète pour un tableau donné
    -- =========================================================

    -- Objectif : Vérifier que Trier fonctionne correctement sur Tab.
    --   1. Le résultat est trié en ordre croissant.
    --   2. Le résultat est une permutation du tableau original.
    -- Paramètre : Tab : le tableau à trier et à vérifier.
    -- Affiche le tableau original, le tableau trié, et le résultat
    -- de chaque vérification.
    procedure Verifier_Tri (Tab : in T_Tableau) is
        Copie : T_Tableau := Tab;
    begin
        Put ("Original : ");
        Ecrire (Tab);
        New_Line;

        Trier (Copie);

        Put ("Trié     : ");
        Ecrire (Copie);
        New_Line;

        -- Vérification 1 : ordre croissant
        pragma Assert (Est_Trie (Copie),
                       "ECHEC : le tableau trié n'est pas en ordre croissant !");

        -- Vérification 2 : mêmes éléments qu'avant le tri
        pragma Assert (Memes_Elements (Tab, Copie),
                       "ECHEC : le tableau trié ne contient pas les mêmes elements !");

        Put_Line ("=> OK");
        New_Line;
    end Verifier_Tri;

    -- =========================================================
    --  Procédure de test
    -- =========================================================
    procedure Tester_Trier is

        -- Générateur aléatoire d'entiers entre -50 et 50
        subtype T_Plage is Integer range -50 .. 50;
        package Aleatoire is new Ada.Numerics.Discrete_Random (T_Plage);
        Generateur : Aleatoire.Generator;

        -- Objectif : Construire un tableau de taille N avec des valeurs aléatoires.
        -- Paramètre : N : le nombre d'éléments souhaité (1 <= N <= Capacite).
        -- Résultat  : un T_Tableau de taille N rempli aléatoirement.
        function Tab_Aleatoire (N : in Integer) return T_Tableau is
            Tab : T_Tableau;
        begin
            Tab.Taille := N;
            for I in 1 .. N loop
                Tab.Elements (I) := Aleatoire.Random (Generateur);
            end loop;
            -- Mettre les cases inutilisées à 0 (bonne pratique)
            for I in N + 1 .. Capacite loop
                Tab.Elements (I) := 0;
            end loop;
            return Tab;
        end Tab_Aleatoire;

    begin
        -- ----- Tests sur des tableaux fixés -----
        Put_Line ("=== Tests sur tableaux fixes ===");
        New_Line;

        Verifier_Tri (( (1, 3, 4, 2, others => 0), 4));
        Verifier_Tri (( (4, 3, 2, 1, others => 0), 4));
        Verifier_Tri (( (-5, 3, 8, 1, -25, 0, 8, 1, 1, 1), 10));
        Verifier_Tri (( (others => 0), 0));   -- tableau vide
        Verifier_Tri (( (42, others => 0), 1)); -- un seul élément

        -- ----- 10 tests aléatoires -----
        Put_Line ("=== 10 tests aleatoires ===");
        New_Line;

        Aleatoire.Reset (Generateur);  -- initialise le générateur avec l'horloge

        for T in 1 .. 10 loop
            Put ("Test aleatoire ");
            Put (T, 2);
            Put (" (taille ");
            Put (Capacite, 1);
            Put (") : ");
            New_Line;
            Verifier_Tri (Tab_Aleatoire (Capacite));
        end loop;

        Put_Line ("Tous les tests ont reussi !");
    end Tester_Trier;

begin
    Tester_Trier;
end Tri_Selection;