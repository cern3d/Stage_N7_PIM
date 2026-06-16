const { Document, Packer, Paragraph, TextRun, AlignmentType, HeadingLevel, BorderStyle } = require('docx');
const fs = require('fs');

const mono = (text) => new TextRun({ text, font: "Courier New", size: 20 });
const bold = (text) => new TextRun({ text, bold: true, size: 22 });
const boldMono = (text) => new TextRun({ text, bold: true, font: "Courier New", size: 20 });
const normal = (text) => new TextRun({ text, size: 22 });
const italic = (text) => new TextRun({ text, italics: true, size: 20, color: "555555" });

const p = (children, opts = {}) => new Paragraph({ children, spacing: { after: 0, before: 0 }, ...opts });
const code = (children, indent = 0) => new Paragraph({
  children,
  spacing: { after: 0, before: 0 },
  indent: { left: indent * 360 }
});
const blank = () => new Paragraph({ children: [new TextRun("")], spacing: { after: 60, before: 0 } });
const title = (text) => new Paragraph({
  children: [new TextRun({ text, bold: true, size: 28 })],
  spacing: { before: 300, after: 120 },
  border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: "2E75B6", space: 1 } }
});

const sections_content = [
  // TITRE
  new Paragraph({
    children: [new TextRun({ text: "Raffinages — PR3 : Stockage et exploitation de tables de routage", bold: true, size: 32 })],
    alignment: AlignmentType.CENTER,
    spacing: { after: 200, before: 200 }
  }),

  // R0
  title("R0 — Action principale"),
  p([bold("R0 : "), normal("Stocker et exploiter la table de routage d'un routeur en routant des paquets IP,")]),
  p([normal("     en utilisant un cache (liste chaînée ou arbre préfixe) avec une politique FIFO, LRU ou LFU.")]),
  blank(),
  p([bold("Exemples :"), normal(" table.txt + paquets.txt → resultats.txt")]),
  p([mono("  147.127.18.0 255.255.255.0 eth1"), italic("   (route dans la table)")]),
  p([mono("  147.127.18.80"), italic("                          (paquet destination)")]),
  p([mono("  → 147.127.18.80 eth1"), italic("                  (résultat attendu)")]),
  blank(),
  p([mono("  0.0.0.0 0.0.0.0 eth0"), italic("           (route par défaut)")]),
  p([mono("  8.8.8.8"), italic("                                 (destination inconnue)")]),
  p([mono("  → 8.8.8.8 eth0"), italic("                          (route par défaut utilisée)")]),
  blank(),

  // R1
  title("R1 — Décomposition de R0"),
  code([boldMono("R1 : "), mono("Comment « Stocker et exploiter la table de routage d'un routeur » ?")]),
  blank(),
  code([mono("Analyser la ligne de commande"), italic("                              Options : out")], 1),
  code([mono("{ Options.Taille_Cache >= 0 ET Options.Politique ∈ {FIFO, LRU, LFU} }")], 1),
  blank(),
  code([mono("Charger la table de routage depuis Options.Fichier_Table"), italic("   Options : in ; Table : out")], 1),
  code([mono("{ Table contient toutes les routes du fichier, liste chaînée non vide }")], 1),
  blank(),
  code([mono("Initialiser le cache"), italic("                    Options : in ; Cache : out")], 1),
  code([mono("{ Cache vide, taille = Options.Taille_Cache, politique = Options.Politique,")], 1),
  code([mono("  Stats.Nb_Demandes = 0, Stats.Nb_Defauts = 0 }")], 1),
  blank(),
  code([mono("Traiter les paquets depuis Options.Fichier_Paquets"), italic("        Table, Cache, Options : in out")], 1),
  code([mono("{ Tous les paquets lus et routés, résultats dans Options.Fichier_Resultats }")], 1),
  blank(),
  code([mono("SI Options.Afficher_Stats ALORS"), italic("                           Cache : in")], 1),
  code([mono("    Afficher les statistiques du cache")], 1),
  code([mono("FIN SI")], 1),
  blank(),
  code([mono("Libérer Table et Cache"), italic("                                     Table, Cache : in out")], 1),
  code([mono("{ Toute la mémoire dynamique est libérée }")], 1),
  blank(),

  // R2 - Analyser ligne de commande
  title("R2 — Décomposition de « Analyser la ligne de commande »"),
  code([boldMono("R2 : "), mono("Comment « Analyser la ligne de commande » ?")]),
  blank(),
  code([mono("Options <-- valeurs par défaut")], 1),
  code([mono("{ Options.Taille_Cache = 10, Options.Politique = FIFO,")], 1),
  code([mono("  Options.Afficher_Stats = vrai,")], 1),
  code([mono("  Options.Fichier_Table = \"table.txt\",")], 1),
  code([mono("  Options.Fichier_Paquets = \"paquets.txt\",")], 1),
  code([mono("  Options.Fichier_Resultats = \"resultats.txt\" }")], 1),
  blank(),
  code([mono("i <-- 1")], 1),
  code([mono("TANT QUE i <= Argument_Count FAIRE"), italic("   i : in out")], 1),
  code([mono("{ Variant : Argument_Count - i }")], 2),
  code([mono("SELON Argument(i) FAIRE")], 2),
  code([mono("\"-c\" --> Options.Taille_Cache <-- Entier(Argument(i+1))  ;  i <-- i + 2")], 3),
  code([mono("\"-p\" --> Options.Politique    <-- Lire_Politique(Argument(i+1))  ;  i <-- i + 2")], 3),
  code([mono("\"-s\" --> Options.Afficher_Stats <-- vrai  ;  i <-- i + 1")], 3),
  code([mono("\"-S\" --> Options.Afficher_Stats <-- faux  ;  i <-- i + 1")], 3),
  code([mono("\"-t\" --> Options.Fichier_Table    <-- Argument(i+1)  ;  i <-- i + 2")], 3),
  code([mono("\"-q\" --> Options.Fichier_Paquets  <-- Argument(i+1)  ;  i <-- i + 2")], 3),
  code([mono("\"-r\" --> Options.Fichier_Resultats <-- Argument(i+1)  ;  i <-- i + 2")], 3),
  code([mono("sinon --> lever exception Argument_Inconnu")], 3),
  code([mono("FIN SELON")], 2),
  code([mono("FIN TANT QUE")], 1),
  code([mono("{ Options contient les valeurs de la dernière occurrence de chaque option }")], 1),
  blank(),

  // R2 - Charger table
  title("R2 — Décomposition de « Charger la table de routage »"),
  code([boldMono("R2 : "), mono("Comment « Charger la table de routage depuis Fichier_Table » ?")]),
  blank(),
  code([mono("Ouvrir Fichier_Table en lecture --> F"), italic("   Fichier_Table : in ; F : out")], 1),
  code([mono("{ F est ouvert en lecture }")], 1),
  blank(),
  code([mono("Table <-- liste vide"), italic("                      Table : out")], 1),
  blank(),
  code([mono("TANT QUE NON Fin_De_Fichier(F) FAIRE")], 1),
  code([mono("{ Variant : nombre de lignes restantes dans F }")], 2),
  code([mono("Lire_Ligne(F) --> Ligne"), italic("                    F : in out ; Ligne : out")], 2),
  code([mono("Parser_Route(Ligne) --> (Destination, Masque, Interface)")], 2),
  code([italic("                                    Ligne : in ; Destination, Masque, Interface : out")], 2),
  code([mono("{ (Destination AND Masque) = Destination ET Masque valide }")], 2),
  code([mono("Insérer (Destination, Masque, Interface) en tête de Table"), italic("   Table : in out")], 2),
  code([mono("FIN TANT QUE")], 1),
  blank(),
  code([mono("Fermer F"), italic("                                         F : in out")], 1),
  code([mono("{ Table contient toutes les routes du fichier }")], 1),
  blank(),

  // R2 - Traiter paquets
  title("R2 — Décomposition de « Traiter les paquets »"),
  code([boldMono("R2 : "), mono("Comment « Traiter les paquets depuis Fichier_Paquets » ?")]),
  blank(),
  code([mono("Ouvrir Fichier_Paquets en lecture  --> F_Paq"), italic("    Options : in ; F_Paq : out")], 1),
  code([mono("Ouvrir Fichier_Resultats en écriture --> F_Res"), italic("  Options : in ; F_Res : out")], 1),
  code([mono("Fin <-- faux"), italic("                                          Fin : out")], 1),
  blank(),
  code([mono("TANT QUE NON Fin_De_Fichier(F_Paq) ET NON Fin FAIRE")], 1),
  code([mono("{ Variant : nombre de lignes restantes dans F_Paq }")], 2),
  code([mono("Lire_Ligne(F_Paq) --> (Ligne, Num_Ligne)"), italic("   F_Paq : in out ; Ligne, Num_Ligne : out")], 2),
  blank(),
  code([mono("SI Ligne est une commande ALORS")], 2),
  code([mono("    Exécuter la commande Ligne"), italic("   Ligne, Num_Ligne, Table, Cache : in out ; Fin : out")], 2),
  code([mono("SINON")], 2),
  code([mono("    Parser_Adresse_IP(Ligne) --> Destination"), italic("   Ligne : in ; Destination : out")], 2),
  code([mono("    Router le paquet Destination"), italic("               Destination : in ; Table, Cache : in out ; Interface : out")], 2),
  code([mono("    Écrire Destination & \" \" & Interface dans F_Res"), italic("   F_Res : in out")], 2),
  code([mono("FIN SI")], 2),
  code([mono("FIN TANT QUE")], 1),
  blank(),
  code([mono("Fermer F_Paq, F_Res")], 1),
  code([mono("{ Tous les paquets avant \"fin\" sont routés et écrits dans F_Res }")], 1),
  blank(),

  // R3 - Router paquet
  title("R3 — Décomposition de « Router le paquet Destination »"),
  code([boldMono("R3 : "), mono("Comment « Router le paquet de destination Destination » ?")]),
  blank(),
  code([mono("Stats.Nb_Demandes <-- Stats.Nb_Demandes + 1"), italic("   Stats : in out")], 1),
  blank(),
  code([mono("SI Options.Taille_Cache > 0 ALORS")], 1),
  code([mono("Chercher Destination dans Cache --> (Trouvé, Interface)")], 2),
  code([italic("                                Cache : in out ; Trouvé : out ; Interface : out")], 2),
  code([mono("SI Trouvé ALORS")], 2),
  code([mono("    Mettre à jour Cache selon la politique"), italic("   Cache : in out")], 2),
  code([mono("    { Pour LRU : déplacer en tête ; pour LFU : incrémenter compteur }")], 2),
  code([mono("    RETOURNER Interface")], 2),
  code([mono("FIN SI")], 2),
  code([mono("FIN SI")], 1),
  blank(),
  code([mono("{ Défaut de cache }")], 1),
  code([mono("Stats.Nb_Defauts <-- Stats.Nb_Defauts + 1"), italic("   Stats : in out")], 1),
  blank(),
  code([mono("Chercher la route par plus long préfixe (Destination, Table) --> (Interface, Masque_Lu)")], 1),
  code([italic("    Destination : in ; Table : in ; Interface : out ; Masque_Lu : out")], 1),
  code([mono("{ Masque_Lu est le masque le plus long tel que")], 1),
  code([mono("  (Destination AND Masque_Lu) = (Dest_Route AND Masque_Lu) }")], 1),
  blank(),
  code([mono("SI Options.Taille_Cache > 0 ALORS")], 1),
  code([mono("Calculer la route à insérer en cache"), italic("   Destination, Interface, Table : in ; Route_Cache : out")], 2),
  code([mono("Insérer Route_Cache dans Cache"), italic("          Cache : in out")], 2),
  code([mono("{ Si Cache plein : appliquer la politique d'éviction avant insertion }")], 2),
  code([mono("FIN SI")], 1),
  blank(),
  code([mono("RETOURNER Interface")], 1),
  code([mono("{ Interface est l'interface de sortie correcte pour Destination }")], 1),
  blank(),

  // R3 - Chercher LPM
  title("R3 — Décomposition de « Chercher la route par plus long préfixe »"),
  code([boldMono("R3 : "), mono("Comment « Chercher la route par plus long préfixe pour Destination » ?")]),
  blank(),
  code([mono("Interface_Trouvée <-- \"\""), italic("   Interface_Trouvée : out")], 1),
  code([mono("Masque_Max <-- 0"), italic("           Masque_Max : out")], 1),
  code([mono("Courant <-- Tête(Table)"), italic("    Table : in ; Courant : out")], 1),
  blank(),
  code([mono("TANT QUE Courant /= null FAIRE")], 1),
  code([mono("{ Variant : longueur de la sous-liste à partir de Courant }")], 2),
  code([mono("{ Invariant : Interface_Trouvée est l'interface du masque le plus long")], 2),
  code([mono("  correspondant à Destination parmi les routes déjà examinées }")], 2),
  blank(),
  code([mono("SI (Destination AND Masque(Courant)) = (Dest(Courant) AND Masque(Courant)) ALORS")], 2),
  code([mono("SI Masque(Courant) >= Masque_Max ALORS")], 3),
  code([mono("    Interface_Trouvée <-- Interface(Courant)")], 3),
  code([mono("    Masque_Max        <-- Masque(Courant)")], 3),
  code([mono("FIN SI")], 3),
  code([mono("FIN SI")], 2),
  blank(),
  code([mono("Courant <-- Suivant(Courant)")], 2),
  code([mono("FIN TANT QUE")], 1),
  blank(),
  code([mono("{ Interface_Trouvée est l'interface du masque le plus long correspondant,")], 1),
  code([mono("  Masque_Max est ce masque (= 0 si aucune route trouvée) }")], 1),
  blank(),

  // R3 - Calculer route cache
  title("R3 — Décomposition de « Calculer la route à insérer en cache »"),
  code([boldMono("R3 : "), mono("Comment « Calculer la route à insérer en cache pour Destination » ?")]),
  blank(),
  code([italic("{ Objectif : trouver le masque discriminant Destination de toutes les routes")], 1),
  code([italic("  d'interface différente, pour éviter les faux hits futurs dans le cache }")], 1),
  blank(),
  code([mono("Masque_Disc <-- Masque_Lu"), italic("   Masque_Disc : out")], 1),
  blank(),
  code([mono("TANT QUE il existe une route R dans Table telle que Interface(R) /= Interface")], 1),
  code([mono("         ET (Destination AND Masque_Disc) = (Dest(R) AND Masque_Disc) FAIRE")], 1),
  code([mono("{ Variant : nombre de routes non encore discriminées }")], 2),
  code([mono("Déterminer le masque discriminant entre Destination et Dest(R)")], 2),
  code([italic("    Destination, Dest(R) : in ; Masque_Disc : in out")], 2),
  code([mono("{ Masque_Disc permet de distinguer Destination de Dest(R) }")], 2),
  code([mono("FIN TANT QUE")], 1),
  blank(),
  code([mono("Dest_Cache <-- Destination AND Masque_Disc"), italic("   Dest_Cache : out")], 1),
  code([mono("Route_Cache <-- (Dest_Cache, Masque_Disc, Interface)")], 1),
  code([mono("{ Route_Cache peut être insérée sans risque de faux hit futur }")], 1),
  blank(),

  // R3 - Insérer dans cache
  title("R3 — Décomposition de « Insérer Route_Cache dans Cache »"),
  code([boldMono("R3 : "), mono("Comment « Insérer Route_Cache dans Cache avec politique si plein » ?")]),
  blank(),
  code([mono("SI Cache_Plein(Cache) ALORS"), italic("   Cache : in")], 1),
  code([mono("SELON Options.Politique FAIRE")], 2),
  code([mono("FIFO --> Supprimer le premier inséré (élément le plus ancien)")], 3),
  code([mono("LRU  --> Supprimer le moins récemment utilisé (fin de liste ordonnée par accès)")], 3),
  code([mono("LFU  --> Chercher et supprimer l'élément au compteur d'accès minimal")], 3),
  code([mono("FIN SELON")], 2),
  code([mono("FIN SI")], 1),
  blank(),
  code([mono("Ajouter Route_Cache en tête de Cache"), italic("   Cache : in out")], 1),
  code([mono("{ Cache contient Route_Cache, taille(Cache) <= Options.Taille_Cache }")], 1),
  blank(),

  // R3 - Exécuter commande
  title("R3 — Décomposition de « Exécuter la commande Ligne »"),
  code([boldMono("R3 : "), mono("Comment « Exécuter la commande Ligne lue à la ligne Num_Ligne » ?")]),
  blank(),
  code([mono("Écrire une ligne vide sur la sortie standard")], 1),
  code([mono("Écrire Ligne & \" (ligne \" & Num_Ligne & \")\" sur la sortie standard")], 1),
  blank(),
  code([mono("SELON Ligne FAIRE")], 1),
  code([mono("\"table\" --> Afficher toutes les routes de Table"), italic("   Table : in")], 2),
  code([mono("            { Pour chaque nœud : Destination Masque Interface }")], 2),
  code([mono("\"cache\" --> Afficher toutes les routes de Cache"), italic("   Cache : in")], 2),
  code([mono("            { Pour chaque nœud : Destination Masque Interface }")], 2),
  code([mono("\"stat\"  --> Afficher les statistiques"), italic("              Cache : in")], 2),
  code([mono("            { Nb_Demandes, Nb_Defauts, Taux = Nb_Defauts / Nb_Demandes }")], 2),
  code([mono("\"fin\"   --> Fin <-- vrai"), italic("                              Fin : out")], 2),
  code([mono("sinon   --> ignorer la ligne")], 2),
  code([mono("FIN SELON")], 1),
  code([mono("{ Fin = vrai si et seulement si la commande était \"fin\" }")], 1),
];

const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 22 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 26, bold: true, font: "Arial", color: "2E75B6" },
        paragraph: { spacing: { before: 240, after: 80 } } },
    ]
  },
  sections: [{
    properties: {
      page: {
        size: { width: 11906, height: 16838 },
        margin: { top: 1000, right: 900, bottom: 1000, left: 900 }
      }
    },
    children: sections_content
  }]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync("./raffinages_PR3.docx", buffer);
  console.log("OK");
});