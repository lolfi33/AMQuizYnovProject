// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/DataBase/database.dart';
import 'package:test/aventureScreens/datas/question.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreen.dart';
import 'package:test/multijoueur/scoreScreen.dart';
import 'package:test/widgets/shakeWidget.dart';
import 'package:test/widgets/timerWidget.dart';

class QuizOnline extends StatefulWidget {
  final List<Question> questions;
  final String nomOeuvre;
  final String roomId;

  const QuizOnline({
    super.key,
    required this.questions,
    required this.nomOeuvre,
    required this.roomId,
  });

  @override
  State<QuizOnline> createState() => _QuizOnlineState();
}

class _QuizOnlineState extends State<QuizOnline> {
  // Timer
  final ValueNotifier<double> progress =
      ValueNotifier<double>(0); // Utilisation de ValueNotifier
  int tempsActuel = 0;
  int tempsReponseMax = 10;
  Timer? everySecond;
  bool onJoue = true;

  // Questions
  late List<Question> questions;
  ValueNotifier<Color> reponseBloc1 =
      ValueNotifier<Color>(couleurBleuAlternatif);
  ValueNotifier<Color> reponseBloc2 =
      ValueNotifier<Color>(couleurBleuAlternatif);
  ValueNotifier<Color> reponseBloc3 =
      ValueNotifier<Color>(couleurBleuAlternatif);
  ValueNotifier<Color> reponseBloc4 =
      ValueNotifier<Color>(couleurBleuAlternatif);
  int indexQuestion = 0;
  int maxQuestion = 3;
  bool onPeutCliquer = true;
  late Future<DocumentSnapshot>
      userDataFuture; // Déclarer un Future pour les données

  // Pour mode multijoueur
  late int score;
  late int opponentScore;
  late bool isWaiting;
  late bool hasAnswered;
  late String roomId;

  // Empecher le retour en arriere
  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  void initState() {
    super.initState();

    socket.on('playerLeft', (_) {
      Fluttertoast.showToast(
        msg: "Votre adversaire a quitté la partie.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 0,
        backgroundColor: Colors.black,
        textColor: Colors.blue,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(2),
        ),
      );
    });

    startTimer();
    userDataFuture = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    score = 0;
    opponentScore = 0;
    isWaiting = true;
    hasAnswered = false;
    questions = widget.questions;

    socket.on('nextQuestion', (data) {
      print('Événement "nextQuestion" reçu : $data');
      setState(() {
        score = data['scores']
            .firstWhere((player) => player['id'] == socket.id)['score'];
        opponentScore = data['scores']
            .firstWhere((player) => player['id'] != socket.id)['score'];

        if (indexQuestion < maxQuestion) {
          indexQuestion += 1;
          hasAnswered = false;
          onPeutCliquer = true;

          // Redémarrer le timer pour la nouvelle question
          startTimer();
        } else {
          socket.emit('endQuiz', {'roomId': widget.roomId});
        }
      });
    });

    socket.on('quizEnded', (data) async {
      final scores = Map<String, int>.from(data['scores']);
      final winner = data['winner'];
      final uid = List<String>.from(data['uid']);
      String? pseudoCourant = await getPseudoUtilisateurCourant();
      if (winner == pseudoCourant) {
        DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .gagnerQuizEnLigne();
      }

      // Récupérer les profils de manière asynchrone
      final profilJoueur1 = await getProfilActuelAdversaire(uid[0]);
      final profilJoueur2 = await getProfilActuelAdversaire(uid[1]);

      print("Profil Joueur 1: $profilJoueur1");
      print("Profil Joueur 2: $profilJoueur2");
      print("Score Joueurs: $scores");

      // Naviguer vers la page ScoreScreen avec les profils récupérés
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreScreen(
            scores: scores,
            winner: winner,
            profilJoueur1: profilJoueur1 ?? '', // Fournir une valeur par défaut
            profilJoueur2: profilJoueur2 ?? '', // Fournir une valeur par défaut
          ),
        ),
      );
    });
  }

  void submitAnswer(bool isCorrect) {
    print("État du socket : ${socket.connected}");
    if (socket.connected) {
      print(
          "submitAnswer appelé avec : $isCorrect pour la question index $indexQuestion");
      socket.emit('submitAnswer', {
        'roomId': widget.roomId,
        'isCorrect': isCorrect,
      });
      print("socket.emit exécuté pour la question index $indexQuestion");
    } else {
      print("Socket non connecté, impossible d'envoyer la réponse.");
    }
  }

  void startTimer() {
    tempsActuel = 0; // Réinitialiser le compteur

    // Assurez-vous d'annuler tout timer précédent
    everySecond?.cancel();

    // Lancer un nouveau timer
    everySecond = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (tempsActuel >= tempsReponseMax) {
        if (onPeutCliquer) {
          socket.emit('submitAnswer', {
            'roomId': widget.roomId,
            'isCorrect':
                false, // Considérer une réponse manquée comme incorrecte
          });
        }

        timer.cancel();
      } else {
        setState(() {
          tempsActuel += 1;
          progress.value =
              tempsActuel / tempsReponseMax; // Mise à jour du widget
        });
      }
    });
  }

  @override
  void dispose() {
    everySecond?.cancel();
    reponseBloc1.dispose();
    reponseBloc2.dispose();
    reponseBloc3.dispose();
    reponseBloc4.dispose();
    socket.emit('leaveRoom');
    socket.off('playerLeft');
    socket.off('nextQuestion');
    socket.off('quizEnded');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      // Si la liste de questions est vide, afficher un message ou un indicateur de chargement
      return const Center(
        child: Text("Aucune question disponible."),
      );
    }

    // Récupérer la question actuelle
    final Question question = questions[indexQuestion];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(fondPrincipal2),
            fit: BoxFit.fill,
          ),
        ),
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(fondPrincipal2),
                fit: BoxFit.fill,
              ),
            ),
            child: buildQuestions(question),
          ),
        ),
      ),
    );
  }

  Widget buildQuestions(Question question) => Column(
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 7.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.w),
                  color: couleurBoutons,
                ),
                height: 55,
                child: Container(
                  width: 350,
                  height: 55,
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
                    widget.nomOeuvre.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )),
                ),
              ),
            ],
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffbfbfde),
                borderRadius: BorderRadius.circular(15), // Bord arrondi
                border: Border.all(
                  color: couleurBoutons,
                  width: 2,
                ),
              ),
              margin: EdgeInsets.only(top: 5.h),
              width: 70,
              height: 50,
              child: Center(
                child: Text(
                  '${indexQuestion + 1}/20',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffdfdff2),
                borderRadius: BorderRadius.circular(15), // Bord arrondi
                border: Border.all(
                  color: couleurBoutons,
                  width: 3,
                ),
              ),
              margin: EdgeInsets.only(top: 7.h),
              width: 90.w,
              height: 25.h,
              child: Center(
                child: Text(
                  question.question,
                  style: TextStyle(fontSize: 5.w),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 1.h,
          ),
          TimerWidget(progress: progress),
          // Center(
          //   child: Container(
          //     margin: EdgeInsets.only(top: 2.h),
          //     child: FutureBuilder<DocumentSnapshot>(
          //       future: userDataFuture, // Utiliser le Future stocké
          //       builder: (context, snapshot) {
          //         if (snapshot.hasError) {
          //           return const Text('Erreur de chargement');
          //         }

          //         if (!snapshot.hasData ||
          //             snapshot.connectionState == ConnectionState.waiting) {
          //           return const SizedBox(
          //             width: 70,
          //             height: 70,
          //           );
          //         }

          //         // Extraction des données
          //         var userData = snapshot.data!.data() as Map<String, dynamic>;
          //         var coupSpecialMap = userData['coupSpecial'];
          //         CoupSpeciaux coupSpecialActuel =
          //             CoupSpeciaux.fromMap(coupSpecialMap);

          //         return InkWell(
          //           onTap: () {
          //             effetCoupSpecialOnePiece(tempsActuel, coupSpecialActuel);
          //           },
          //           child: coupSpecial(coupSpecialActuel),
          //         );
          //       },
          //     ),
          //   ),
          // ),
          SizedBox(
            height: 7.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildReponse(1, reponseBloc1, question),
              buildReponse(2, reponseBloc2, question),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildReponse(3, reponseBloc3, question),
              buildReponse(4, reponseBloc4, question),
            ],
          ),
        ],
      );

  Widget buildReponse(
      int reponseIndex, ValueNotifier<Color> reponseBloc, Question question) {
    final shakeController = GlobalKey<ShakeWidgetState>();
    return ValueListenableBuilder<Color>(
      valueListenable: reponseBloc,
      builder: (context, color, child) {
        return GestureDetector(
            child: ShakeWidget(
              key: shakeController,
              shouldShake: false,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: couleurBoutons,
                    width: 2,
                  ),
                ),
                margin: EdgeInsets.only(top: 1.h),
                width: 45.w,
                height: 11.h,
                child: Center(
                  child: Text(
                    question.options[reponseIndex - 1],
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            onTap: () {
              if (!onPeutCliquer) {
                // Déclencher le tremblement si onPeutCliquer est faux
                shakeController.currentState?.shake();
                return; // Assurez-vous que les clics sont ignorés si désactivé
              }
              print("onTap détecté sur le client.");
              setState(() {
                onPeutCliquer = false;
              });

              bool isCorrect = question.reponse == reponseIndex.toString();

              print("Clic détecté, réponse correcte ? $isCorrect");
              submitAnswer(isCorrect);
              print("cest envoyé");

              if (isCorrect) {
                playSound('sounds/correct.wav'); // Bonne réponse
                score++;
              } else {
                playSound('sounds/wrong.wav'); // Mauvaise réponse
              }

              // Change la couleur du bloc pour feedback visuel
              reponseBloc.value = isCorrect ? Colors.green : Colors.red;

              // Réinitialise la couleur après un court délai
              Timer(const Duration(milliseconds: 500), () {
                reponseBloc.value = couleurBleuAlternatif;
              });
            });
      },
    );
  }
}
