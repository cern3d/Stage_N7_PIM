# Makefile — routeur_LL et routeur_LA
# Nécessite GNAT (gnatmake ou gprbuild)

SRC     = src
OBJ     = obj
BIN_LL  = routeur_LL
BIN_LA  = routeur_LA

# Fichiers sources communs
SRC_COMMUNS = $(SRC)/adresses_ip.adb \
              $(SRC)/tables_routage.adb \
              $(SRC)/parametres.adb

# Sources spécifiques LL (cache liste chaînée)
SRC_LL = $(SRC_COMMUNS) \
         $(SRC)/caches_ll.adb \
         $(SRC)/e_s_fichiers.adb \
         $(SRC)/routeur_ll.adb

# Sources spécifiques LA (cache trie)
SRC_LA = $(SRC_COMMUNS) \
         $(SRC)/caches_ll.adb \
         $(SRC)/caches_trie.adb \
         $(SRC)/e_s_fichiers_la.adb \
         $(SRC)/routeur_la.adb

.PHONY: all ll la clean test test_ll test_la

all: $(OBJ) ll la

$(OBJ):
	mkdir -p $(OBJ)

# Compilation via gprbuild (recommandé) ou gnatmake en fallback
ll: $(OBJ)
	gprbuild -P routeur.gpr -XMAIN=routeur_ll 2>/dev/null || \
	gnatmake -D $(OBJ) $(SRC)/routeur_ll.adb \
	    -gnata -gnatwa -g -o $(BIN_LL)

la: $(OBJ)
	gprbuild -P routeur.gpr -XMAIN=routeur_la 2>/dev/null || \
	gnatmake -D $(OBJ) $(SRC)/routeur_la.adb \
	    -gnata -gnatwa -g -o $(BIN_LA)

# Tests avec le fichier d'exemple du sujet
test: test_ll test_la

test_ll: ll
	@echo "=== Test routeur_LL (cache liste, FIFO, taille 2) ==="
	./$(BIN_LL) -c 2 -p FIFO -t table.txt -q paquets.txt -r resultats_ll.txt
	@echo "--- Résultats ---"
	@cat resultats_ll.txt

test_la: la
	@echo "=== Test routeur_LA (cache trie, LRU, taille 2) ==="
	./$(BIN_LA) -c 2 -p LRU -t table.txt -q paquets.txt -r resultats_la.txt
	@echo "--- Résultats ---"
	@cat resultats_la.txt

# Test sans cache
test_sans_cache: ll
	@echo "=== Test sans cache ==="
	./$(BIN_LL) -c 0 -S -t table.txt -q paquets_complets.txt -r resultats.txt
	@cat resultats.txt

clean:
	rm -rf $(OBJ) $(BIN_LL) $(BIN_LA) resultats*.txt b~*.ad?
