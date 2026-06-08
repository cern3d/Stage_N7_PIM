--
--  Les TODO dans le texte vous indique les parties de ce programme à compléter.
--  Les autres parties ne doivent pas être modifiées.
--
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Integer_Text_IO;
use Ada.Integer_Text_IO;
with Alea;

-- Objectif : Afficher un tableau trié suivant le principe du tri par sélection.

procedure Tri_Selection is

    Capacite: constant Integer := 10;   -- Cette taille est arbitraire

    type T_TableauElements is array (1..Capacite) of Integer;

    type T_Tableau is
        record
            Elements: T_TableauElements;
            Taille: Integer;
            -- Invariant: 0 <= Taille and Taille <= Capacite;
        end record;



    -- Objectif : Indiquer si deux tableaux son égaux.
    -- Paramètres :
    --     Tab1, Tab2 : les deux tableaux à comparer
    -- Résultat
    --     Vrai si et seulement si Tab1 et Tab2 sont égaux.
    --
    -- Remarque : Ici on redéfinit l'opérateur "=" déjà présent en Ada qui par
    -- défaut compara les tailles et tous les éléments de Elements.
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



    -- Objectif : Afficher le tableau.
    --    Les éléments sont affichés entre crochets, séparés par des virgules.
    -- Paramètres :
    --    Tab : le tableau à afficher.
    procedure Ecrire(Tab: in T_Tableau) is
    begin
        Put ('[');
        if Tab.Taille > 0 then
            -- Écrire le premier élément
            Put (Tab.Elements (1), 1);

            -- Écrire les autres éléments précédés d'une virgule
            for I in 2..Tab.Taille loop
                Put (", ");
                Put (Tab.Elements (I), 1);
            end loop;
        else
            null;
        end if;
        Put (']');
    end Ecrire;



    -- Vérifie si un tableau est trié en ordre croissant.
    function Est_Trier(Tab: in T_Tableau) return Boolean is
    begin
        if Tab.Taille > 1 then
            for I in 1..Tab.Taille - 1 loop
                if Tab.Elements(I) > Tab.Elements(I + 1) then
                    return False;
                end if;
            end loop;
        end if;
        return True;
    end Est_Trier;

    -- Calcule le nombre d'occurrences d'une valeur dans un tableau.
    function Frequence(Tab: in T_Tableau; Valeur: Integer) return Integer is
        Compteur: Integer := 0;
    begin
        for I in 1..Tab.Taille loop
            if Tab.Elements(I) = Valeur then
                Compteur := Compteur + 1;
            end if;
        end loop;
        return Compteur;
    end Frequence;

    -- Vérifie que deux tableaux contiennent les mêmes éléments avec les mêmes occurrences.
    function Meme_Elements(Tab1, Tab2: in T_Tableau) return Boolean is
    begin
        if Tab1.Taille /= Tab2.Taille then
            return False;
        end if;
        for I in 1..Tab1.Taille loop
            if Frequence(Tab1, Tab1.Elements(I))
                    /= Frequence(Tab2, Tab1.Elements(I)) then
                return False;
            end if;
        end loop;
        return True;
    end Meme_Elements;

    procedure Trier(Tab: in out T_Tableau) is
        Temp: Integer;
        MinIndex: Integer;
    begin
        if Tab.Taille > 1 then
            for I in 1..Tab.Taille - 1 loop
                MinIndex := I;
                for J in I+1..Tab.Taille loop
                    if Tab.Elements (J) < Tab.Elements (MinIndex) then
                        MinIndex := J;
                    end if;
                end loop;
                if MinIndex /= I then
                    Temp := Tab.Elements (I);
                    Tab.Elements (I) := Tab.Elements (MinIndex);
                    Tab.Elements (MinIndex) := Temp;
                end if;
            end loop;
        end if;
    end Trier;


    -- Programme de test de la procédure Trier.
    procedure Tester_Trier is

        package Random_Int is new Alea (Lower_Bound => -50, Upper_Bound => 50);
        use Random_Int;

        procedure Initialiser_Aleatoire(Tab: out T_Tableau; Taille: Integer) is
        begin
            Tab.Taille := Taille;
            for I in 1..Taille loop
                Get_Random_Number(Tab.Elements(I));
            end loop;
        end Initialiser_Aleatoire;

        procedure Verifier_Trie(Tab: in T_Tableau) is
            Copie: T_Tableau := Tab;
        begin
            Trier(Copie);
            pragma Assert(Est_Trier(Copie));
            pragma Assert(Meme_Elements(Tab, Copie));
        end Verifier_Trie;

        procedure Tester(Tab, Attendu: in T_Tableau) is
            Copie: T_Tableau := Tab;
        begin
            Trier(Copie);
            pragma Assert(Copie = Attendu);
            pragma Assert(Meme_Elements(Tab, Copie));
        end Tester;

    begin
        Tester (( (1, 9, others => 0), 2),
                ( (1, 9, others => 0), 2));
        Tester (( (4, 2, others => 0), 2),
                ( (2, 4, others => 0), 2));
        Tester (( (1, 3, 4, 2, others => 0), 4),
                ( (1, 2, 3, 4, others => 0), 4));
        Tester (( (4, 3, 2, 1, others => 0), 4),
                ( (1, 2, 3, 4, others => 0), 4));
        Tester (( (-5, 3, 8, 1, -25, 0, 8, 1, 1, 1), 10),
                ( (-25, -5, 0, 1, 1, 1, 1, 3, 8, 8), 10));
        Tester (( (others => 0), 0),
                ( (others => 0), 0));

        Verifier_Trie(( (1, 3, 4, 2, others => 0), 4));
        Verifier_Trie(( (4, 3, 2, 1, others => 0), 4));
        Verifier_Trie(( (-5, 3, 8, 1, -25, 0, 8, 1, 1, 1), 10));

        for I in 1..10 loop
            declare
                Aleat : T_Tableau;
            begin
                Initialiser_Aleatoire(Aleat, 10);
                Verifier_Trie(Aleat);
            end;
        end loop;
    end Tester_Trier;


    Tab1 : T_Tableau;
begin
    -- Initialiser le tableau
    Tab1 := ( (1, 3, 4, 2, others => 0), 4);

    -- Afficher le tableau
    Ecrire (Tab1);
    New_Line;

    -- Trier le tableau
        Trier(Tab1);

    -- Afficher le tableau trié
    Ecrire (Tab1);
    New_Line;

    Tester_Trier;

end Tri_Selection;
