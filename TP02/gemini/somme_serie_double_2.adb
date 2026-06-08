--  with Ada.Text_IO;          use Ada.Text_IO;
--  with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

--  -- Afficher la somme des valeurs d'un série dont les valeurs sont lues au
--  -- clavier. Pour marquer la fin de la série, la dernière valeur est doublée.
--  -- En conséquence, il ne peut pas y avoir deux valeurs consécutives égales dans
--  -- la série.
--  --
--  -- Exemples :
--  --
--  -- série                   ->  longueur (Somme)
--  -- ------------------------------------
--  --  1  2  3  3             ->    6
--  --  1  2  1  3  1  4  1  1 ->   13
--  -- -4  8  1  3 29 29       ->   37
--  --  0  0                   ->    0
--  -- -5 -1 -5 -5             ->  -11
--  --
--  procedure Somme_Serie_Double is

--     Somme : Integer := 0;      -- Somme des valeurs de la série (initialisée à 0)
--     Precedent : Integer;       -- Stocke la valeur précédente
--     Courant   : Integer;       -- Stocke la valeur courante

--  begin
--     -- Déterminer la somme des valeurs d'une série lue au clavier
   
--     -- Lecture du tout premier élément
--     Get (Precedent);
   
--     -- Lecture du deuxième élément pour pouvoir initier la comparaison
--     Get (Courant);
   
--     -- Boucle tant que la valeur courante est différente de la précédente
--     while Courant /= Precedent loop
--        Somme     := Somme + Precedent; -- On ajoute l'élément validé à la somme
--        Precedent := Courant;           -- Le courant devient le précédent
--        Get (Courant);                  -- On lit le nombre suivant
--     end loop;
   
--     -- Attention au cas particulier : si les deux premiers nombres sont identiques (ex: 0 0),
--     -- la boucle ne s'exécute pas. Si la boucle s'est exécutée, il reste le dernier élément 
--     -- valide (le "Precedent") à ajouter à la somme avant de s'arrêter.
--     if Courant /= Somme or (Precedent /= Courant) then
--        Somme := Somme + Precedent;
--     end if;

--     -- Afficher la somme
--     Put ("Somme : ");
--     Put (Somme, 1);
--     New_Line;

--  end Somme_Serie_Double;



with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

-- Afficher la somme des valeurs d'un série dont les valeurs sont lues au
-- clavier. Pour marquer la fin de la série, la dernière valeur est doublée.
-- En conséquence, il ne peut pas y avoir deux valeurs consécutives égales dans
-- la série.
--
procedure Somme_Serie_Double is

   Somme : Integer := 0;      -- Somme des valeurs de la série
   Precedent : Integer;       -- Stocke la valeur précédente
   Courant   : Integer;       -- Stocke la valeur courante

begin
   -- Déterminer la somme des valeurs d'une série lue au clavier
   
   -- On lit la toute première valeur pour initialiser "Precedent"
   Get (Precedent);
   
   -- On lit ensuite la deuxième valeur
   Get (Courant);
   
   loop
      -- Répéter : On ajoute la valeur validée (Precedent) à la somme
      Somme := Somme + Precedent;
      
      -- Jusqu'à ce que la valeur courante soit égale à la précédente
      exit when Courant = Precedent;
      
      -- Si on n'est pas sorti, on avance : le courant devient le précédent
      Precedent := Courant;
      
      -- Et on lit la valeur suivante
      Get (Courant);
   end loop;

   -- Afficher la somme
   Put ("Somme : ");
   Put (Somme, 1);
   New_Line;

end Somme_Serie_Double;


--  Algorithme Somme_Série_Doublon

--  Variables:
--      somme : Entier
--      precedent : Entier
--      courant : Entier

--  Début
--      // Initialisation
--      somme ← 0
    
--      // Lecture des deux premières valeurs indispensables pour démarrer
--      Écrire("Saisir la première valeur : ")
--      Lire(precedent)
    
--      Écrire("Saisir la deuxième valeur : ")
--      Lire(courant)
    
--      Répéter
--          // On ajoute la valeur validée (precedent) à la somme
--          somme ← somme + precedent
        
--          // Si le doublon est atteint, on s'arrête avant d'avancer
--          Si courant ≠ precedent Alors
--              precedent ← courant      // Le courant devient le précédent
--              Écrire("Saisir la valeur suivante : ")
--              Lire(courant)            // On lit une nouvelle valeur
--          FinSi
        
--      Jusqu'à courant = precedent
    
--      // Affichage du résultat final
--      Écrire("Somme : ", somme)

--  Fin