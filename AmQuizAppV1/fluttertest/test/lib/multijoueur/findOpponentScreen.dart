import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/multijoueur/vsScreen.dart';
import 'package:test/aventureScreens/datas/question.dart';

class FindOpponentScreen extends StatefulWidget {
  final String quizName;
  final String themeQuizz;

  const FindOpponentScreen(
      {super.key, required this.quizName, required this.themeQuizz});

  @override
  _FindOpponentScreenState createState() => _FindOpponentScreenState();
}

class _FindOpponentScreenState extends State<FindOpponentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool isFinding;
  String? roomId;
  List<Question> questions = [];

  // Empecher le retour en arriere
  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  void clearSocketListeners() {
    socket.off('vsScreen');
  }

  @override
  void initState() {
    super.initState();

    // Initialisation du contrôleur d'animation
    _controller = AnimationController(
      duration:
          const Duration(milliseconds: 1000), // Durée d'un cycle de rebond
      vsync: this,
    );

    // Initialisation de l'animation avec un Tween et une courbe easeInOut
    _animation = Tween<double>(begin: 0, end: -20).animate(
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

    isFinding = true;

    joinRoom();

    socket.on('vsScreen', (data) {
      print("Données reçues dans vsScreen : $data");

      // Vérifiez que les données des joueurs sont correctes
      final enemyPlayer = data['players'].firstWhere(
        (player) => player['id'] != socket.id,
        orElse: () =>
            null, // Fournissez une alternative si aucun joueur n'est trouvé
      );

      if (enemyPlayer == null) {
        print("Aucun adversaire trouvé !");
        return; // Arrêtez si les données sont incorrectes
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => VsScreen(
            quizName: widget.quizName,
            questions: const [], // Vide, rempli dans `startQuiz`
            nomOeuvre: widget.themeQuizz,
            roomId: data['roomId'],
            uidEnnemi: enemyPlayer['uid'] ??
                "UID inconnu", // Ajoutez une valeur par défaut
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  Future<void> joinRoom() async {
    // Récupérer le pseudo et l'UID de l'utilisateur courant
    String? pseudo = await getPseudoUtilisateurCourant();
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    print('🎮 Tentative de joinRoom:');
    print('  - quizName: ${widget.quizName}');
    print('  - pseudo: $pseudo');
    print('  - themeQuizz: ${widget.themeQuizz}');
    print('  - uid: $uid');
    print('  - socket connecté: ${socket.connected}');
    if (pseudo != null && uid != null) {
      socket.emit('joinRoom', {
        'quizName': widget.quizName,
        'pseudo': pseudo,
        'themeQuizz': widget.themeQuizz,
        'uid': uid, // Ajout de l'UID ici
      });
    } else {
      print("Pseudo ou UID utilisateur est null !");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    clearSocketListeners();
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
                Text(
                  "Recherche d'adversaire ${widget.themeQuizz} ...",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8.h,
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
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 30.w,
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                InkWell(
                  onTap: () {
                    socket.emit('leaveRoom');
                    clearSocketListeners();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: couleurBoutons,
                    ),
                    child: Container(
                      width: 90,
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
                          "Annuler".toUpperCase(),
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
            )),
      ),
    );
  }
}
