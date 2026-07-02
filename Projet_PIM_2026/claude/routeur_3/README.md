# Routeur LL / LA — Manuel utilisateur

## Programmes

| Exécutable   | Table de routage | Cache          |
|--------------|------------------|----------------|
| `routeur_LL` | Liste chaînée    | Liste chaînée  |
| `routeur_LA` | Liste chaînée    | Arbre préfixe  |

## Compilation (machines Linux N7)

```bash
mkdir obj
# Les deux programmes d'un coup :
gprbuild -P routeur.gpr

# Ou manuellement :
gnatmake -D obj src/routeur_ll.adb -gnata -gnatwa -g -o routeur_LL
gnatmake -D obj src/routeur_la.adb -gnata -gnatwa -g -o routeur_LA
```

## Utilisation

```
routeur_LL [options]
routeur_LA [options]
```

### Options (identiques pour les deux programmes)

| Option             | Description                              | Défaut        |
|--------------------|------------------------------------------|---------------|
| `-c <taille>`      | Taille du cache (0 = pas de cache)       | 10            |
| `-p FIFO\|LRU\|LFU`| Politique de remplacement du cache       | FIFO          |
| `-s`               | Afficher les statistiques (défaut)       | activé        |
| `-S`               | Ne pas afficher les statistiques         |               |
| `-t <fichier>`     | Fichier de la table de routage           | table.txt     |
| `-q <fichier>`     | Fichier des paquets à router             | paquets.txt   |
| `-r <fichier>`     | Fichier des résultats                    | resultats.txt |

La même option peut apparaître plusieurs fois ; c'est la **dernière** occurrence qui fait foi.

### Exemples

```bash
# Cache de taille 15, politique LRU, fichiers par défaut
routeur_LL -c 15 -p LRU

# Equivalent explicite
routeur_LL -c 15 -p LRU -t table.txt -q paquets.txt -r resultats.txt

# Sans cache, sans statistiques
routeur_LL -c 0 -S

# Avec cache trie, politique LFU
routeur_LA -c 20 -p LFU -t ma_table.txt -q mes_paquets.txt -r res.txt
```

## Format des fichiers

### Table de routage (`table.txt`)

Une route par ligne : `<destination> <masque> <interface>`

```
147.127.16.0 255.255.240.0 eth0
147.127.18.0 255.255.255.0 eth1
0.0.0.0      0.0.0.0       eth0
```

### Paquets (`paquets.txt`)

Une adresse IP par ligne. Des commandes peuvent être intercalées :

| Commande | Effet                                              |
|----------|----------------------------------------------------|
| `table`  | Affiche la table de routage sur le terminal        |
| `cache`  | Affiche le contenu du cache sur le terminal        |
| `stat`   | Affiche les statistiques sur le terminal           |
| `fin`    | Arrête le traitement (paquets suivants ignorés)    |

```
table
212.212.212.212
cache
147.127.18.80
stat
fin
```

### Résultats (`resultats.txt`)

```
212.212.212.212 eth3
147.127.18.80 eth1
```

## Architecture des modules

```
adresses_ip          Type T_Adresse_IP (mod 2**32), opérations bit-à-bit
tables_routage       TAD liste chaînée de routes, LPM, masque discriminant
parametres           Analyse de la ligne de commande
caches_ll            Cache liste chaînée (FIFO/LRU/LFU) + cohérence §1.4.2
caches_trie          Cache arbre préfixe (FIFO/LRU/LFU) + cohérence §1.4.2
e_s_fichiers         Lecture/écriture + traitement paquets (pour routeur_LL)
e_s_fichiers_la      Idem pour routeur_LA (cache trie)
routeur_ll           Programme principal — cache liste chaînée
routeur_la           Programme principal — cache arbre préfixe
```

## Algorithmes clés

### Longest Prefix Match (LPM)
Pour chaque paquet, toutes les routes dont `(dest AND masque) = (reseau AND masque)` 
sont candidates. La route avec le masque le plus long (en bits à 1) est sélectionnée.

### Cohérence du cache (§1.4.2)
La route mise en cache utilise un **masque discriminant** : le plus long masque 
existant dans la table qui ne correspond *pas* à l'adresse du paquet. Cela garantit 
qu'une entrée du cache ne masquera jamais une route plus spécifique de la table.

### Politiques de remplacement
- **FIFO** : expulse l'entrée dont le numéro de séquence d'insertion est le plus petit.
- **LRU**  : expulse l'entrée dont le dernier accès (lecture ou insertion) est le plus ancien.
- **LFU**  : expulse l'entrée la moins souvent accédée depuis son insertion.

### Cache trie (routeur_LA)
L'arbre préfixe indexe les routes par les bits de leur adresse (MSB en premier).
La recherche descend bit par bit et retourne la route la plus profonde trouvée.
L'expulsion parcourt toutes les feuilles (nœuds portant une route) pour identifier 
la victime, puis élague les nœuds devenus inutiles (sans route ni fils).
