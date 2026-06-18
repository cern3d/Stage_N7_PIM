# Routeur LL — Manuel utilisateur (Version 1)

## Compilation

Sur les machines Linux de l'N7 (GNAT disponible) :

```bash
make
# ou manuellement :
mkdir obj
gnatmake -D obj src/routeur_ll.adb -o routeur_LL -gnata -gnatwa -g
```

## Utilisation

```
routeur_LL [options]
```

### Options

| Option             | Description                                      | Défaut        |
|--------------------|--------------------------------------------------|---------------|
| `-c <taille>`      | Taille du cache (0 = pas de cache)               | 10            |
| `-p FIFO\|LRU\|LFU`| Politique de remplacement du cache               | FIFO          |
| `-s`               | Afficher les statistiques (défaut)               | activé        |
| `-S`               | Ne pas afficher les statistiques                 |               |
| `-t <fichier>`     | Fichier de la table de routage                   | table.txt     |
| `-q <fichier>`     | Fichier des paquets à router                     | paquets.txt   |
| `-r <fichier>`     | Fichier des résultats                            | resultats.txt |

La même option peut apparaître plusieurs fois ; c'est la dernière occurrence qui fait foi.

### Exemple

```bash
routeur_LL -c 15 -t table.txt -q paquets.txt -r resultats.txt
# Équivalent (noms par défaut) :
routeur_LL -c 15
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

- `table` — affiche la table de routage sur le terminal
- `cache` — affiche le contenu du cache sur le terminal
- `stat`  — affiche les statistiques sur le terminal
- `fin`   — arrête le traitement (les paquets suivants sont ignorés)

```
table
212.212.212.212
cache
147.127.18.80
fin
```

### Résultats (`resultats.txt`)

```
212.212.212.212 eth3
147.127.18.80 eth1
```

## Algorithme de routage

Pour chaque paquet, le routeur parcourt la table de routage et cherche toutes
les routes dont le masque correspond à l'adresse destination
(`(destination AND masque) = (reseau AND masque)`).
Parmi celles-ci, il retient celle dont le masque est le plus long (LPM —
Longest Prefix Match), conformément au standard IP.

## Architecture des modules

```
routeur_ll       Programme principal
├── parametres   Analyse de la ligne de commande
├── e_s_fichiers Lecture table/paquets, écriture résultats
├── tables_routage  TAD liste chaînée de routes
└── adresses_ip  Type T_Adresse_IP et opérations bit-à-bit
```
