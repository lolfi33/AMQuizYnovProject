import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreen.dart';

class ScoreScreen extends StatefulWidget {
  final Map<String, int> scores;
  final String winner;
  final String profilJoueur1;
  final String profilJoueur2;

  const ScoreScreen({
    Key? key,
    required this.scores,
    required this.winner,
    required this.profilJoueur1,
    required this.profilJoueur2,
  }) : super(key: key);

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  // Empecher le retour en arriere
  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  void initState() {
    super.initState();

    // Initialisation du contrôleur d'animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 750), // Durée d'un cycle de rebond
      vsync: this,
    );

    // Initialisation de l'animation avec un Tween et une courbe easeInOut
    _animation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        // Rebondir en boucle
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    // Démarrer l'animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        width: double.infinity, // Prend toute la largeur
        height: double.infinity, // Prend toute la hauteur
        color: const Color(0xff151692),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150, // Largeur du conteneur
                    height: 250, // Hauteur du conteneur
                    decoration: BoxDecoration(
                      color: couleurBleuAlternatif, // Couleur de fond
                      border: Border.all(
                        color: couleurBoutons, // Couleur de la bordure
                        width: 2, // Épaisseur de la bordure
                      ),
                      borderRadius: BorderRadius.circular(
                          8), // Bords arrondis (optionnel)
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 2.h,
                        ),
                        Image.asset(
                          widget.profilJoueur1,
                          height: 110,
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          widget.scores.entries.first.key, // Affiche le pseudo
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          '${widget.scores.entries.first.value}/20', // Affiche le score
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Container(
                    width: 150, // Largeur du conteneur
                    height: 250,
                    decoration: BoxDecoration(
                      color: couleurBleuAlternatif, // Couleur de fond
                      border: Border.all(
                        color: couleurBoutons, // Couleur de la bordure
                        width: 2, // Épaisseur de la bordure
                      ),
                      borderRadius: BorderRadius.circular(
                          8), // Bords arrondis (optionnel)
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 2.h,
                        ),
                        Image.asset(
                          widget.profilJoueur2,
                          height: 110,
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          widget.scores.entries.last.key, // Affiche le pseudo
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          '${widget.scores.entries.last.value}/20', // Affiche le score
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5.h,
              ),
              const Text(
                "Vainqueur : ",
                style: const TextStyle(fontSize: 15, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 2.h,
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0, _animation.value), // Appliquer l'effet de rebond
                    child: child, // L'enfant est le logo
                  );
                },
                child: Text(
                  widget.winner,
                  style: const TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 239, 218, 24),
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 4.h,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainScreen(2),
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: couleurBoutons,
                  ),
                  child: Container(
                    width: 75,
                    height: 45,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xff151692),
                          spreadRadius: 0,
                          blurRadius: 20.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "OK".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xff17c983),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
