with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Integer_Text_IO;
use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;
with Alea;

-- Évaluer la qualité du générateur aléatoire dans plusieurs
-- configurations.
procedure Evaluer_Alea is

    -- Évaluer la qualité du générateur de nombre aléatoire Alea sur un
    -- intervalle donné en calculant les fréquences absolues minimales et
    -- maximales des entiers obtenus lors de plusieurs tirages aléatoire
    -- ainsi que la fréquence moyenne théorique.
    --
    -- Paramètres :
    --    Borne: in Entier  -- le nombre aléatoire est dans 1..Borne
    --    Taille: in Entier -- nombre de tirages à faire (taille de l'échantillon)
    --    Min, Max: out Entier -- fréquence minimale et maximale
    --    Moyenne: out Float   -- fréquence moyenne théorique
    --
    -- Nécessite :
    --    Borne > 1
    --    Taille > 1
    --
    -- Assure : -- poscondition peu intéressante !
    --    0 <= Min Et Min <= Taille
    --    0 <= Max Et Max <= Taille
    --    Min + Max <= Taille
    --    Moyenne = Réel(Taille) / Réel(Borne)
    --    Min <= Moyenne Et Moyenne <= Max
    --
    -- Remarque : On ne peut ni formaliser les 'vraies' postconditions,
    -- ni écrire de programme de test car on ne maîtrise par le générateur
    -- aléatoire.  Pour écrire un programme de test, on pourrait remplacer
    -- le générateur par un générateur qui fournit une séquence connue
    -- d'entiers et pour laquelle on pourrait déterminer les données
    -- statistiques demandées.
    -- Ici, pour tester on peut afficher les nombres aléatoires et refaire
    -- les calculs par ailleurs pour vérifier que le résultat produit est
    -- le bon.
    procedure Calculer_Statistiques (
        Borne    : in Integer;  -- Borne supérieur de l'intervalle de recherche
        Taille   : in Integer;  -- Taille de l'échantillon
        Min, Max : out Integer; -- min et max des fréquences de l'échantillon
        Moyenne  : out Float    -- moyenne des fréquences
    ) with
        Pre => Borne > 1 and Taille > 1,
        Post => 0 <= Min and Min <= Taille
            and 0 <= Max and Max <= Taille
            and Min + Max <= Taille
            and Moyenne = Float (Taille) / Float (Borne)
            and Float (Min) <= Moyenne and Moyenne <= Float (Max)
    is
        package Mon_Alea is
            new Alea (1, Borne);
        use Mon_Alea;

        type Comptages is array (Integer range <>) of Integer;
        Tab : Comptages (1 .. Borne) := (others => 0);
        Valeur : Integer;

    begin
        for I in 1 .. Taille loop
            Get_Random_Number (Valeur);
            Tab (Valeur) := Tab (Valeur) + 1;
        end loop;

        Min := Taille;
        Max := 0;
        for I in Tab'Range loop
            if Tab (I) < Min then
                Min := Tab (I);
            end if;
            if Tab (I) > Max then
                Max := Tab (I);
            end if;
        end loop;

        Moyenne := Float (Taille) / Float (Borne);
    end Calculer_Statistiques;


    -- Afficher les données statistiques
    -- Paramètres:
    --   Min, Max : in Entier -- le min et le max
    --   Moyenne : in Réel -- la moyenne
    procedure Afficher_Statistiques (Min, Max: Integer; Moyenne: in Float) is
    begin
        Put_Line ("Min     =" & Integer'Image (Min));
        Put_Line ("Max     =" & Integer'Image (Max));
        Put ("Moyenne = ");
        Put (Moyenne, 1, 2, 0);
            -- Put d'un réel accepte trois paramètres supplémentaires
            -- le nombre de positions à utiliser avant le '.' (ici 1)
            -- le nombre de positions pour la partie décimale (ici 2)
            -- le nombre de positions pour l'exposant (ici 0)
        New_Line;
    end Afficher_Statistiques;


    Min, Max: Integer; -- fréquence minimale et maximale d'un échantillon
    Moyenne: Float;    -- fréquences moyenne de l'échantillon
begin
    -- Calculer les statistiques pour un dé à 6 faces et un petit échantillon
    Calculer_Statistiques (6, 20, Min, Max, Moyenne);
    Afficher_Statistiques (Min, Max, Moyenne);
    New_Line;

--  -- Calculer les statistiques pour un dé à 6 faces et un échantillon grand
--  Calculer_Statistiques (6, 10000, Min, Max, Moyenne);
--  Afficher_Statistiques (Min, Max, Moyenne);
--  New_Line;
--
--  -- Calculer les statistiques pour un dé à 6 faces et un échantillon
    -- très grand
--  Calculer_Statistiques (6, 10e6, Min, Max, Moyenne);
--  Afficher_Statistiques (Min, Max, Moyenne);
--  New_Line;
--
--  -- Calculer les statistiques pour un dé à 6 faces et un échantillon
    -- très, très grand
--  Calculer_Statistiques (6, 10e8, Min, Max, Moyenne);
--  Afficher_Statistiques (Min, Max, Moyenne);
--  New_Line;
end Evaluer_Alea;



--  x86_64-linux-gnu-gcc-13 -c -I./ -gnatwa -I- ./evaluer_alea.adb
--  evaluer_alea.adb:3:09: warning: no entities of "Ada.Integer_Text_IO" are referenced [-gnatwu]
--  evaluer_alea.adb:4:01: warning: use clause for package "Integer_Text_IO" has no effect [-gnatwu]
--  x86_64-linux-gnu-gcc-13 -c -I./ -gnatwa -I- ./alea.adb
--  x86_64-linux-gnu-gnatbind-13 -x evaluer_alea.ali
--  x86_64-linux-gnu-gnatlink-13 evaluer_alea.ali
