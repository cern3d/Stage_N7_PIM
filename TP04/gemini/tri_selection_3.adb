with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
-- On suppose que le fichier alea.ads / alea.adb est disponible dans le projet
with Alea; 

procedure Tri_Selection is

    Capacite: constant Integer := 10;

    type T_TableauElements is array (1..Capacite) of Integer;

    type T_Tableau is
        record
            Elements: T_TableauElements;
            Taille: Integer;
        end record;

    -------------------------------------------------------------------------
    -- Fonctions outils
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
    -- Sous-programmes de vérification des propriétés
    -------------------------------------------------------------------------
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

    function Sont_Permutations(Tab1, Tab2 : in T_Tableau) return Boolean is
    begin
        if Tab1.Taille /= Tab2.Taille then
            return False;
        end if;
        
        for I in 1 .. Tab1.Taille loop
            if Occurrences(Tab1, Tab1.Elements(I)) /= Occurrences(Tab2, Tab1.Elements(I)) then
                return False;
            end if;
        end loop;
        
        return True;
    end Sont_Permutations;

    procedure Verifier_Tri(Tab_Initial : in T_Tableau) is
        Tab_Modifie : T_Tableau;
    begin
        Tab_Modifie := Tab_Initial;
        Trier(Tab_Modifie);
        
        pragma Assert(Est_Trie(Tab_Modifie));
        pragma Assert(Sont_Permutations(Tab_Initial, Tab_Modifie));
    end Verifier_Tri;

    -------------------------------------------------------------------------
    -- Procédure de test utilisant le package générique Alea
    -------------------------------------------------------------------------
    procedure Tester_Trier is
        
        -- Instanciation du package générique Alea pour générer 
        -- des nombres compris entre -50 et 50
        package Mon_Generateur_Alea is new Alea(Lower_Bound => -50, Upper_Bound => 50);
        
        Tab_Alea : T_Tableau;
        Valeur_Aleatoire : Integer;
    begin
        Put_Line("=== Debut des tests de validation ===");

        -- Tests avec les tableaux imposés
        Verifier_Tri(((1, 3, 4, 2, others => 0), 4));
        Verifier_Tri(((4, 3, 2, 1, others => 0), 4));
        Verifier_Tri(((-5, 3, 8, 1, -25, 0, 8, 1, 1, 1), 10));
        
        Put_Line("Tests deterministes : OK");

        -- Génération et test de 10 tableaux aléatoires
        Put_Line("Lancement de 10 tests aleatoires via le package Alea...");
        for Test in 1 .. 10 loop
            Tab_Alea.Taille := Capacite; -- On remplit les 10 cases
            
            for I in 1 .. Tab_Alea.Taille loop
                -- Appel de la procédure out du package instancié
                Mon_Generateur_Alea.Get_Random_Number(Valeur_Aleatoire);
                Tab_Alea.Elements(I) := Valeur_Aleatoire;
            end loop;
            
            -- Affichage textuel du test en cours
            Put("Test " & Integer'Image(Test) & " sur : ");
            Ecrire(Tab_Alea);
            
            -- Lancement de la vérification croisée (Trie & Permutation)
            Verifier_Tri(Tab_Alea);
            
            Put_Line(" -> OK");
        end loop;
        
        Put_Line("=== Tous les tests ont reussi avec succes ! ===");
    end Tester_Trier;

    Tab1 : T_Tableau;
begin
    Tab1 := ( (1, 3, 4, 2, others => 0), 4);
    Put("Tableau initial : "); Ecrire (Tab1); New_Line;

    Trier(Tab1);
    Put("Tableau trie    : "); Ecrire (Tab1); New_Line;
    New_Line;

    -- Appel de la batterie de tests
    Tester_Trier;

end Tri_Selection;