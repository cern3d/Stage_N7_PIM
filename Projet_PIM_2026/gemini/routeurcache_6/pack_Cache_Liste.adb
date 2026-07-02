package body Pack_Cache_Liste is

   procedure Initialiser (Cache : out T_Cache; Capacite : in Natural; Politique : in T_Politique) is
   begin
      Cache.Tete := null;
      Cache.Taille := 0;
      Cache.Capacite := Capacite;
      Cache.Politique := Politique;
   end Initialiser;

   ----------------------------------------------------------------------------
   -- RECHERCHE (Avec mise à jour LRU / LFU)
   ----------------------------------------------------------------------------
   procedure Chercher (
      Cache       : in out T_Cache;
      IP          : in T_Adresse_IP;
      Interface_R : out Unbounded_String;
      Trouve      : out Boolean
   ) is
      Courant, Precedent : T_Lien_Cache;
   begin
      Trouve := False;
      Interface_R := To_Unbounded_String("");
      
      if Cache.Capacite = 0 or Cache.Tete = null then
         return;
      end if;

      Courant := Cache.Tete;
      Precedent := null;

      -- Parcours de la liste du cache
      while Courant /= null loop
         -- Vérification de la correspondance avec la route du cache
         if (IP and Courant.Masque) = Courant.Destination then
            Trouve := True;
            Interface_R := Courant.Interface_R;

            -- Mises à jour selon la politique de cache
            case Cache.Politique is
               when LRU =>
                  -- On déplace l'élément trouvé au début de la liste (le plus récemment utilisé)
                  if Precedent /= null then
                     Precedent.Suivant := Courant.Suivant;
                     Courant.Suivant := Cache.Tete;
                     Cache.Tete := Courant;
                  end if;

               when LFU =>
                  -- On incrémente sa fréquence d'utilisation
                  Courant.Frequence := Courant.Frequence + 1;

               when FIFO =>
                  -- FIFO ne modifie pas l'ordre lors d'un "Hit" (succès)
                  null;
            end case;
            
            return; -- Route trouvée, on quitte
         end if;
         
         Precedent := Courant;
         Courant := Courant.Suivant;
      end loop;
   end Chercher;

   ----------------------------------------------------------------------------
   -- INSERTION (Avec Éjection FIFO / LRU / LFU si plein)
   ----------------------------------------------------------------------------
   procedure Enregistrer (
      Cache       : in out T_Cache;
      Destination : in T_Adresse_IP;
      Masque      : in T_Adresse_IP;
      Interface_R : in Unbounded_String
   ) is
      Nouveau, Courant, Precedent : T_Lien_Cache;
      Cible, Cible_Prec          : T_Lien_Cache;
      Min_Freq                   : Natural;
   begin
      if Cache.Capacite = 0 then
         return;
      end if;

      -- ÉTAPE 1 : Si le cache est plein, il faut éjecter un élément
      if Cache.Taille >= Cache.Capacite then
         
         case Cache.Politique is
            when FIFO | LRU =>
               -- Pour FIFO et LRU, l'élément à éjecter est TOUJOURS le dernier de la liste
               -- (car on insère toujours en tête, et LRU remet en tête les succès)
               Courant := Cache.Tete;
               Precedent := null;
               while Courant.Suivant /= null loop
                  Precedent := Courant;
                  Courant := Courant.Suivant;
               end loop;
               
               -- Supprimer le dernier élément
               if Precedent = null then
                  Cache.Tete := null;
               else
                  Precedent.Suivant := null;
               end if;
               -- Libérer la mémoire de la cellule éjectée
               -- (Optionnel mais recommandé : Free(Courant))

            when LFU =>
               -- Pour LFU, on cherche l'élément qui a la plus petite Fréquence
               Courant := Cache.Tete;
               Precedent := null;
               Cible := Cache.Tete;
               Cible_Prec := null;
               Min_Freq := Courant.Frequence;

               while Courant /= null loop
                  if Courant.Frequence < Min_Freq then
                     Min_Freq := Courant.Frequence;
                     Cible := Courant;
                     Cible_Prec := Precedent;
                  end if;
                  Precedent := Courant;
                  Courant := Courant.Suivant;
               end loop;

               -- Supprimer l'élément cible (Fréquence minimale)
               if Cible_Prec = null then
                  Cache.Tete := Cache.Tete.Suivant;
               else
                  Cible_Prec.Suivant := Cible.Suivant;
               end if;
         end case;

         Cache.Taille := Cache.Taille - 1;
      end if;

      -- ÉTAPE 2 : Insertion du nouvel élément en TÊTE de liste
      Nouveau := new T_Cellule_Cache'(
         Destination => Destination,
         Masque      => Masque,
         Interface_R => Interface_R,
         Frequence   => 1,
         Suivant     => Cache.Tete
      );
      
      Cache.Tete := Nouveau;
      Cache.Taille := Cache.Taille + 1;

   end Enregistrer;

   ----------------------------------------------------------------------------
   -- VIDAGE DU CACHE
   ----------------------------------------------------------------------------
   procedure Vider (Cache : in out T_Cache) is
      Suivant : T_Lien_Cache;
   begin
      while Cache.Tete /= null loop
         Suivant := Cache.Tete.Suivant;
         -- Ici tu peux appeler une procédure Free pour désallouer proprement la mémoire
         Cache.Tete := Suivant;
      end loop;
      Cache.Taille := 0;
   end Vider;

   ----------------------------------------------------------------------------
   -- AFFICHAGE DU CACHE
   ----------------------------------------------------------------------------
   procedure Afficher_Cache (Cache : in T_Cache) is
      Courant : T_Lien_Cache := Cache.Tete;
   begin
      while Courant /= null loop
         Put_Line(IP_To_String(Courant.Destination) & " " &
                  IP_To_String(Courant.Masque) & " " &
                  To_String(Courant.Interface_R));
         Courant := Courant.Suivant;
      end loop;
   end Afficher_Cache;

end Pack_Cache_Liste;