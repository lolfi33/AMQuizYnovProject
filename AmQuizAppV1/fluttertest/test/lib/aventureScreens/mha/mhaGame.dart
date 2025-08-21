// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/DataBase/database.dart';
import 'package:test/aventureScreens/datas/dataIsland.dart';
import 'package:test/aventureScreens/datas/question.dart';
import 'package:test/globals.dart';
import 'package:test/widgets/timerWidget.dart';

class MHAGame extends StatefulWidget {
  final String fichierJson;
  final String nomIle;
  final int record;
  final int numeroIle;
  const MHAGame({
    super.key,
    required this.fichierJson,
    required this.nomIle,
    required this.record,
    required this.numeroIle,
  });

  @override
  State<MHAGame> createState() => _MHAGameState();
}

class _MHAGameState extends State<MHAGame> {
  // Timer
  final ValueNotifier<double> progress =
      ValueNotifier<double>(0); // Utilisation de ValueNotifier
  int tempsActuel = 0;
  int tempsReponseMax = 15;
  Timer? everySecond;
  bool onJoue = true;

  // Questions
  late Future<List<Question>> questionsFuture;
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
  int score = 0;
  bool onPeutCliquer = true;
  late Future<DocumentSnapshot>
      userDataFuture; // Déclarer un Future pour les données

  @override
  void initState() {
    super.initState();
    userDataFuture = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    initializeQuestions();
    beginTimer();
  }

  void initializeQuestions() {
    // Initialiser questionsFuture sans rendre initState async
    questionsFuture =
        DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .getQuestionsAventure("mha", widget.fichierJson);
  }

  void beginTimer() {
    // Initialiser le timer périodique
    everySecond = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Incrémentation de la valeur du progress avec ValueNotifier
      progress.value += 1 / tempsReponseMax;
      tempsActuel += 1;

      // Si le temps est écoulé pour cette question
      if (onJoue && tempsActuel >= tempsReponseMax) {
        if (indexQuestion == maxQuestion) {
          cancelTimer(); // Arrête le timer avant d'agir
          questionSuivanteClique();
        } else {
          questionSuivanteClique();
          resetTimer(); // Réinitialise les valeurs sans créer un nouveau timer
        }
      }
    });
  }

  void resetTimer() {
    // Met à jour les valeurs sans utiliser setState
    progress.value = 0;
    tempsActuel = 0;
  }

  void cancelTimer() {
    // Vérifier si le timer est actif avant de l'annuler
    if (everySecond != null && everySecond!.isActive) {
      everySecond!.cancel();
      everySecond = null; // Nettoyer la référence
    }
  }

  @override
  void dispose() {
    cancelTimer();
    reponseBloc1.dispose();
    reponseBloc2.dispose();
    reponseBloc3.dispose();
    reponseBloc4.dispose();
    super.dispose();
  }

  questionSuivanteClique() async {
    if (indexQuestion == maxQuestion) {
      setState(() {
        onJoue = false;
      });
      int realScore = ((score / (maxQuestion + 1)) * 100).round();
      if (realScore > widget.record) {
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .updateRecordsMHA(widget.numeroIle, realScore);
      }
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .debloqueProchaineIleMHA(widget.numeroIle, realScore);

      showResult(context, maxQuestion + 1, score, widget.fichierJson,
          widget.nomIle, widget.record, widget.numeroIle, "mha");
    } else {
      indexQuestion += 1;
      progress.value = 0;
      tempsActuel = 0;
      onJoue = true;
      setState(() {});
    }
    onPeutCliquer = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(fondPrincipal2),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        body: FutureBuilder<List<Question>>(
          future: questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              final questions = snapshot.data!;
              Question question = questions[indexQuestion];
              return Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(fondPrincipal2),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: buildQuestions(question));
            } else {
              return const Center(
                child: Text("Erreur lors du chargement des questions"),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildQuestions(Question question) => Column(
        children: [
          Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 3.w),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context); // Revenir à la page précédente
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 7.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        color: couleurBoutons,
                      ),
                      width: 10.5.w,
                      height: 5.h,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.w),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xff151692),
                              spreadRadius: 0,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        width: 10.5.w,
                        height: 5.h,
                        child: Image.asset(
                          'assets/images/back.png',
                          width: 5.w,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Container(
                    margin: EdgeInsets.only(top: 7.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.w),
                      color: couleurBoutons,
                    ),
                    height: 55,
                    child: Container(
                      width: 300,
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
                        widget.nomIle.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                    ),
                  ),
                ],
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
    return ValueListenableBuilder<Color>(
      valueListenable: reponseBloc,
      builder: (context, color, child) {
        return GestureDetector(
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
          onTap: () {
            if (onPeutCliquer) {
              if (question.reponse == reponseIndex.toString()) {
                if (audioActif) {
                  playSound('sounds/correct.wav');
                }
                reponseBloc.value = Colors.green;
                score++;
              } else {
                if (audioActif) {
                  playSound('sounds/wrong.wav');
                }
                reponseBloc.value = Colors.red;
              }
              onJoue = false;
              onPeutCliquer = false;
              Timer(const Duration(milliseconds: 500), () {
                reponseBloc.value = couleurBleuAlternatif;
                questionSuivanteClique();
              });
            }
          },
        );
      },
    );
  }
}
