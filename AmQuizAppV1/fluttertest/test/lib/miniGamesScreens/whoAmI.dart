// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/DataBase/database.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreen.dart';
import 'package:test/miniGamesScreens/datas/datasMainTrainingScreen.dart';

class WhoAmI extends StatefulWidget {
  final String fichierJson;
  const WhoAmI({
    super.key,
    required this.fichierJson,
  });

  @override
  State<WhoAmI> createState() => _WhoAmIState();
}

class _WhoAmIState extends State<WhoAmI> {
  // Empecher le retour en arriere
  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  final reponseController = TextEditingController();

  bool onJoue = true;

  // Questions
  late Future<List<Indice>> questionsFuture;
  int indexQuestion = 0;
  int maxQuestion = 4;
  int score = 0;
  bool onPeutCliquer = true;

  // Pour suivre l'indice actuellement affiché
  ValueNotifier<int> currentIndice = ValueNotifier<int>(1);

  // Pour afficher les messages d'erreur et de points
  String feedbackMessage = '';
  Color feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    initializeQuestions();
  }

  void initializeQuestions() {
    questionsFuture =
        DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .getIndices("whoAmI", widget.fichierJson);
  }

  @override
  void dispose() {
    reponseController.dispose();
    currentIndice.dispose();
    super.dispose();
  }

  void questionSuivante() {
    if (indexQuestion < maxQuestion) {
      indexQuestion++;
      currentIndice.value =
          1; // Réinitialiser les indices pour la prochaine question
      reponseController.clear(); // Réinitialiser le champ texte
      feedbackMessage = ''; // Réinitialiser les messages
      feedbackColor = Colors.transparent;
    } else {
      onJoue = false;
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .gagnerPtsQuiSuiJe(score);
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .jouerQuiSuiJe();
      showQuizEndDialog(context, score); // Affiche le dialogue à la fin
    }
    setState(() {});
  }

  void verifierReponse(Indice question) {
    final reponse = reponseController.text.trim().toLowerCase();
    final List<String> reponsesPossibles =
        question.reponsesPossibles.map((e) => e.toLowerCase()).toList();

    if (reponsesPossibles.contains(reponse)) {
      // Calculer les points en fonction de l'indice actuel
      int pointsGagnes = 0;
      switch (currentIndice.value) {
        case 1:
          pointsGagnes = 3;
          break;
        case 2:
          pointsGagnes = 2;
          break;
        case 3:
          pointsGagnes = 1;
          break;
      }
      score += pointsGagnes;

      // Afficher le feedback positif
      setState(() {
        feedbackMessage = "+$pointsGagnes Points !";
        feedbackColor = Colors.green;
      });

      // Temporisation avant de passer à la question suivante
      Future.delayed(const Duration(seconds: 2), () {
        questionSuivante();
      });
    } else {
      // Mauvaise réponse
      if (currentIndice.value < 3) {
        // Passer à l'indice suivant
        currentIndice.value++;
        setState(() {
          feedbackMessage = "FAUX";
          feedbackColor = Colors.red;
        });
      } else {
        // Dernier indice utilisé, passer à la question suivante
        setState(() {
          feedbackMessage = "FAUX !!";
          feedbackColor = Colors.red;
        });
        Future.delayed(const Duration(seconds: 2), () {
          questionSuivante();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            resizeToAvoidBottomInset: true,
            body: FutureBuilder<List<Indice>>(
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
                  Indice question = questions[indexQuestion];
                  return Container(
                      height: 100.h,
                      color: const Color(0xff151692),
                      child: Stack(children: [
                        Positioned(
                          top: 6.h,
                          left: 3.w,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.w),
                                color: const Color.fromARGB(255, 188, 215, 13),
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
                        ),
                        Center(
                          child: SingleChildScrollView(
                            child: buildQuestions(question),
                          ),
                        ),
                      ]));
                } else {
                  return const Center(
                    child: Text("Erreur lors du chargement des questions"),
                  );
                }
              },
            ),
          ),
        ));
  }

  Widget buildQuestions(Indice question) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffbfbfde),
                borderRadius: BorderRadius.circular(15), // Bord arrondi
                border: Border.all(
                  color: const Color.fromARGB(255, 188, 215, 13),
                  width: 2,
                ),
              ),
              margin: EdgeInsets.only(top: 5.h),
              width: 70,
              height: 50,
              child: Center(
                child: Text(
                  '${indexQuestion + 1}/5',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Afficher les indices
          ValueListenableBuilder<int>(
            valueListenable: currentIndice,
            builder: (context, current, child) {
              return Column(
                children: [
                  if (current >= 1) _buildIndiceContainer(question.indice1),
                  if (current >= 2) _buildIndiceContainer(question.indice2),
                  if (current >= 3) _buildIndiceContainer(question.indice3),
                ],
              );
            },
          ),

          SizedBox(height: 3.h),

          // Indice Row avec "Indice X/3"
          Center(
            child: Container(
              width: 33.w,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15), // Bord arrondi
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: InkWell(
                onTap: () {
                  if (currentIndice.value < 3) {
                    FocusScope.of(context).unfocus();
                    currentIndice.value++;
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: currentIndice,
                      builder: (context, current, child) {
                        return Text(
                          "Indice $current/3".toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 1.w),
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 8.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          // Afficher le feedback
          Text(
            feedbackMessage,
            style: TextStyle(
              color: feedbackColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          const Center(
            child: Text(
              "Je suis ...",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 70.w,
                height: 5.h,
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: reponseController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 0.5.w,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 188, 215, 13),
                        width: 0.5.w,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 2.w,
              ),
              Container(
                width: 12.w,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15), // Bord arrondi
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      verifierReponse(
                          question); // Vérifie la réponse de l'utilisateur
                    },
                    child: Icon(
                      Icons.forward,
                      color: Colors.white,
                      size: 8.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildIndiceContainer(String indice) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffdfdff2),
        borderRadius: BorderRadius.circular(15), // Bord arrondi
        border: Border.all(
          color: const Color.fromARGB(255, 188, 215, 13),
          width: 3,
        ),
      ),
      margin: EdgeInsets.only(top: 1.h),
      width: 90.w,
      height: 10.h,
      child: Center(
        child: Text(
          indice,
          style: TextStyle(fontSize: 5.w),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

void showQuizEndDialog(BuildContext context, int score) {
  showDialog(
    context: context,
    barrierDismissible: false, // Empêche la fermeture en appuyant à l'extérieur
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: const Color(0xff151692),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Score : $score/15",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MainScreen(2)),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
                child: const Text(
                  "Ok",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
