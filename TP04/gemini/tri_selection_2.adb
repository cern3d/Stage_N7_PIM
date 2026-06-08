with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Numerics.Discrete_Random;

procedure Tri_Selection is

    Capacite: constant Integer := 10;

    type T_TableauElements is array (1..Capacite) of Integer;

    type T_Tableau is
        record
            Elements: T_TableauElements;
            Taille: Integer;
        end record;

    -------------------------------------------------------------------------
    -- Fonctions outils fournies de base
    -------------------------------------------------------------------------
    function "=" (Tab1, Tab2: in T_Tableau) return Boolean is
        Resultat: Boolean;
        Indice: Integer;
    begin
        if Tab1.Taille /= Tab2.Taille then
            Resultat := False;
        else
            Indice := 1;
            while Indice <= Tab1.Taille
                    and then Tab1.Elements (Indice) = Tab2.Elements (Indice)
            loop
                Indice := Indice + 1;
            end loop;
            Resultat := Indice > Tab1.Taille;
        end if;
        return Resultat;
    end "=";

    procedure Ecrire(Tab: in T_Tableau) is
    begin
        Put ('[');
        if Tab.Taille > 0 then
            Put (Tab.Elements (1), 1);
            for I in 2..Tab.Taille loop
                Put (", ");
                Put (Tab.Elements (I), 1);
            end loop;
        end if;
        Put (']');
    end Ecrire;

    -------------------------------------------------------------------------
    -- Implantation du Tri par Sélection
    -------------------------------------------------------------------------
    procedure Trier(Tab: in out T_Tableau) is
        Min_Idx : Integer;
        Tmp     : Integer;
    begin
        if Tab.Taille > 1 then
            for I in 1 .. Tab.Taille - 1 loop
                Min_Idx := I;
                for J in I + 1 .. Tab.Taille loop
                    if Tab.Elements(J) < Tab.Elements(Min_Idx) then
                        Min_Idx := J;
                    end if;
                end loop;
                if Min_Idx /= I then
                    Tmp := Tab.Elements(I);
                    Tab.Elements(I) := Tab.Elements(Min_Idx);
                    Tab.Elements(Min_Idx) := Tmp;
                end if;
            end loop;
        end if;
    end Trier;

    -------------------------------------------------------------------------
    -- Exercice 4 - Question 1 : Sous-programmes de vérification des propriétés
    -------------------------------------------------------------------------
    
    -- Propriété 1 : Vérifier si le tableau est trié dans l'ordre croissant
    function Est_Trie(Tab : in T_Tableau) return Boolean is
    begin
        if Tab.Taille <= 1 then
            return True;
        end if;
        
        for I in 1 .. Tab.Taille - 1 loop
            if Tab.Elements(I) > Tab.Elements(I + 1) then
                return False;
            end if;
        end loop;
        return True;
    end Est_Trie;

    -- Compte le nombre d'occurrences d'une valeur dans un tableau
    function Occurrences(Tab : in T_Tableau; Valeur : Integer) return Integer is
        Compteur : Integer := 0;
    begin
        for I in 1 .. Tab.Taille loop
            if Tab.Elements(I) = Valeur then
                Compteur := Compteur + 1;
            end if;
        end loop;
        return Compteur;
    end Occurrences;

    -- Propriété 2 : Vérifier que Tab1 et Tab2 ont la même taille et les mêmes éléments
    function Sont_Permutations(Tab1, Tab2 : in T_Tableau) return Boolean is
    begin
        -- 1. Même taille ?
        if Tab1.Taille /= Tab2.Taille then
            return False;
        end if;
        
        -- 2. Même nombre d'occurrences pour chaque élément ?
        for I in 1 .. Tab1.Taille loop
            if Occurrences(Tab1, Tab1.Elements(I)) /= Occurrences(Tab2, Tab1.Elements(I)) then
                return False;
            end if;
        end loop;
        
        return True;
    end Sont_Permutations;

    -- Procédure demandée au Q1 : Vérifie le bon fonctionnement pour un tableau donné
    procedure Verifier_Tri(Tab_Initial : in T_Tableau) is
        Tab_Modifie : T_Tableau;
    begin
        Tab_Modifie := Tab_Initial;
        Trier(Tab_Modifie);
        
        -- Validation des deux propriétés requises par l'énoncé
        pragma Assert(Est_Trie(Tab_Modifie));
        pragma Assert(Sont_Permutations(Tab_Initial, Tab_Modifie));
    end Verifier_Tri;

    -------------------------------------------------------------------------
    -- Exercice 4 - Questions 2 & 3 : Procédures de test
    -------------------------------------------------------------------------
    procedure Tester_Trier is
        -- Instanciation du générateur de nombres aléatoires entre -50 et 50
        subtype Range_Aleatoire is Integer range -50 .. 50;
        package Generateur_P is new Ada.Numerics.Discrete_Random(Range_Aleatoire);
        G : Generateur_P.Generator;
        
        Tab_Alea : T_Tableau;
    begin
        Put_Line("=== Debut des tests de validation ===");

        -- Q2 : Tests avec les tableaux imposés par l'énoncé
        Verifier_Tri(((1, 3, 4, 2, others => 0), 4));
        Verifier_Tri(((4, 3, 2, 1, others => 0), 4));
        Verifier_Tri(((-5, 3, 8, 1, -25, 0, 8, 1, 1, 1), 10));
        
        -- Tests aux limites additionnels (optionnels mais recommandés)
        Verifier_Tri(((others => 0), 0)); -- Tableau vide
        Verifier_Tri(((42, others => 0), 1)); -- Un seul élément
        
        Put_Line("Tests deterministes : OK");

        -- Q3 : Génération et test de 10 tableaux aléatoires
        Generateur_P.Reset(G); -- Initialisation de la graine
        
        Put_Line("Lancement de 10 tests aleatoires...");
        for Test in 1 .. 10 loop
            Tab_Alea.Taille := Capacite; -- On remplit le tableau au max (10 éléments)
            for I in 1 .. Tab_Alea.Taille loop
                Tab_Alea.Elements(I) := Generateur_P.Random(G);
            end loop;
            
            -- Tracer l'exécution (optionnel, pour voir ce qu'il se passe)
            Put("Test " & Integer'Image(Test) & " sur : ");
            Ecrire(Tab_Alea);
            
            -- Lancer la vérification automatique
            Verifier_Tri(Tab_Alea);
            
            Put_Line(" -> OK");
        end loop;
        
        Put_Line("=== Tous les tests ont reussi avec succes ! ===");
    end Tester_Trier;

    -- Variable globale de démonstration principale
    Tab1 : T_Tableau;
begin
    -- Démonstration simple demandée originellement dans le main
    Tab1 := ( (1, 3, 4, 2, others => 0), 4);
    Put("Tableau initial : "); Ecrire (Tab1); New_Line;

    Trier(Tab1);
    Put("Tableau trie    : "); Ecrire (Tab1); New_Line;
    New_Line;

    -- Lancement de la batterie de tests complète (Exercice 4)
    Tester_Trier;

end Tri_Selection;