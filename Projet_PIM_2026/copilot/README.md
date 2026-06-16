Simple Ada router (version 1) — routeur_LL

Files:
- src/routeur_LL.adb : Ada implementation of the simple router (no cache)
- table.txt : sample routing table
- paquets.txt : sample packets and commands

To compile (GNAT):

```sh
cd src
gnatmake routeur_LL.adb -o routeur_LL
```

Run:

```sh
..\routeur_LL -t ..\table.txt -q ..\paquets.txt -r ..\resultats.txt
```
