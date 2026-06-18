# Makefile pour routeur_LL (version 1 - sans cache)
# Utilise gnatmake ou gprbuild selon ce qui est disponible

GNATMAKE = gnatmake
GPRBUILD = gprbuild
SRC      = src
OBJ      = obj
BIN      = routeur_LL

.PHONY: all clean test

all: $(OBJ)
	$(GNATMAKE) -P routeur.gpr 2>/dev/null || \
	$(GNATMAKE) -D $(OBJ) $(SRC)/routeur_ll.adb -o $(BIN) \
	    -gnata -gnatwa -g

$(OBJ):
	mkdir -p $(OBJ)

# Test avec les fichiers fournis dans le sujet
test: all
	@echo "=== Test avec paquets.txt ==="
	./$(BIN) -c 0 -t table.txt -q paquets.txt -r resultats.txt
	@echo ""
	@echo "=== Résultats ===" 
	@cat resultats.txt

# Test sans cache (taille 0)
test_simple: all
	@echo "=== Routeur simple (sans cache) ==="
	./$(BIN) -c 0 -S -t table.txt -q paquets_complets.txt -r resultats.txt
	cat resultats.txt

clean:
	rm -rf $(OBJ) $(BIN) resultats.txt b~*.ad?
