import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Calculatrice(),
  ));
}

class Calculatrice extends StatefulWidget {
  const Calculatrice({super.key});

  @override
  State<Calculatrice> createState() => _CalculatriceState();
}

class _CalculatriceState extends State<Calculatrice> {
  // ---------- Variables d'état ----------
  String affichage = '0'; // Nombre affiché en grand
  String operation = ''; // Petite ligne, ex : "12 +"
  double premierNombre = 0; // Premier nombre mémorisé
  String operateur = ''; // Opérateur choisi (+, -, ×, ÷, %)
  bool nouveauNombre = true; // true = le prochain chiffre démarre un nouveau nombre

  // ---------- Clavier (chaque ligne = une liste de touches) ----------
  final List<List<String>> touches = [
    ['C', '%', '÷', '×'],
    ['7', '8', '9', '-'],
    ['4', '5', '6', '+'],
    ['1', '2', '3', '='],
    ['0', '.'],
  ];

  // ---------- Quand on appuie sur une touche ----------
  void appuyer(String touche) {
    setState(() {
      // Après une erreur, on repart de zéro
      if (affichage == 'Erreur') reinitialiser();

      if (touche == 'C') {
        reinitialiser();
      } else if (touche == '.') {
        ajouterVirgule();
      } else if (touche == '=') {
        afficherResultat();
      } else if ('+-×÷%'.contains(touche)) {
        choisirOperateur(touche);
      } else {
        ajouterChiffre(touche);
      }
    });
  }

  // Bouton C : tout remettre à zéro
  void reinitialiser() {
    affichage = '0';
    operation = '';
    premierNombre = 0;
    operateur = '';
    nouveauNombre = true;
  }

  // Chiffres 0 à 9
  void ajouterChiffre(String chiffre) {
    if (nouveauNombre || affichage == '0') {
      affichage = chiffre; // On remplace l'affichage
    } else {
      affichage = affichage + chiffre; // On ajoute à la suite
    }
    nouveauNombre = false;
  }

  // Bouton . : un seul point par nombre
  void ajouterVirgule() {
    if (nouveauNombre) {
      affichage = '0.';
      nouveauNombre = false;
    } else if (!affichage.contains('.')) {
      affichage = affichage + '.';
    }
  }

  // Boutons + - × ÷ %
  void choisirOperateur(String op) {
    // Si un calcul est déjà en cours (ex : 2 + 3 puis +), on calcule d'abord
    if (operateur != '' && !nouveauNombre) {
      afficherResultat();
    }
    premierNombre = double.parse(affichage);
    operateur = op;
    operation = '${formater(premierNombre)} $op';
    nouveauNombre = true;
  }

  // Bouton =
  void afficherResultat() {
    if (operateur == '') return; // Rien à calculer

    double second = double.parse(affichage);
    double? resultat = calculer(premierNombre, operateur, second);

    operation = '${formater(premierNombre)} $operateur ${formater(second)}';
    affichage = resultat == null ? 'Erreur' : formater(resultat);
    operateur = '';
    nouveauNombre = true;
  }

  // Le calcul lui-même
  // Le bouton % est un MODULO (reste de la division) : 10 % 3 = 1
  double? calculer(double a, String op, double b) {
    if (op == '+') return a + b;
    if (op == '-') return a - b;
    if (op == '×') return a * b;
    if (op == '÷') return b == 0 ? null : a / b; // Division par zéro interdite
    if (op == '%') return b == 0 ? null : a % b;
    return null;
  }

  // Enlève le ".0" inutile : 5.0 -> "5"
  String formater(double nombre) {
    if (nombre == nombre.truncateToDouble()) {
      return nombre.toInt().toString();
    }
    // Arrondi pour éviter 0.30000000000000004
    String texte = nombre.toStringAsFixed(8);
    texte = texte.replaceAll(RegExp(r'0+$'), '');
    return texte;
  }

  // ---------- Interface ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Zone d'affichage
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Résultat (grand)
                    Text(
                      affichage,
                      style: const TextStyle(color: Colors.white, fontSize: 64),
                    ),
                    // Opération (petit)
                    Text(
                      operation,
                      style: const TextStyle(color: Colors.grey, fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
            // Clavier
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  for (var ligne in touches)
                    Expanded(
                      child: Row(
                        children: [
                          for (var touche in ligne) bouton(touche),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Un bouton du clavier
  Widget bouton(String touche) {
    return Expanded(
      flex: touche == '0' ? 3 : 1, // Le 0 est plus large
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => appuyer(touche),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                touche == '=' ? Colors.orange : const Color(0xFF333333),
            foregroundColor: Colors.white,
          ),
          child: Text(touche, style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}