// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/aventureScreens/mha/mhaGame.dart';
import 'package:test/aventureScreens/onePiece/onePieceAventureScreen.dart';
import 'package:test/aventureScreens/onePiece/onePieceGame.dart';
import 'package:test/aventureScreens/snk/snkAventureScreen.dart';
import 'package:test/aventureScreens/snk/snkGame.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';

// Empecher le retour en arriere
Future<bool> _onWillPop() async {
  return false; //<-- SEE HERE
}

showIsland(BuildContext context, String titre, int nbEtoiles, int record,
    String jsonFichier, int numeroIle, String nomOeuvre) async {
  double tailleEtoiles = 6.w;
  if (record == 1) {
    record = 0;
  }
  showDialog(
    barrierColor: Colors.white.withOpacity(0),
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: couleurBleuAlternatif.withOpacity(0.8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              4.w,
            ),
          ),
        ),
        contentPadding: EdgeInsets.only(
          top: 0.h,
        ),
        content: SizedBox(
          height: 25.h,
          width: 96.w,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: couleurBoutons, // Bordure de couleur
                width: 3, // Épaisseur de la bordure
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(4.w),
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 1.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 2.w),
                      child: Row(
                        children: [
                          for (int i = 0; i < 3; i++) ...[
                            Image.asset(
                              i < nbEtoiles
                                  ? 'assets/images/star.png'
                                  : 'assets/images/emptyStar.png',
                              width: tailleEtoiles,
                            ),
                            SizedBox(width: 1.w),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 2.w),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset(
                          'assets/images/croix.png',
                          width: 5.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 1.5.h,
                ),
                Center(
                  child: Text(
                    titre,
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 1.5.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 2.w,
                    ),
                    const Text(
                      "Record",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(
                      child: LinearPercentIndicator(
                        width: 45.w,
                        animation: true,
                        lineHeight: 20.0,
                        animationDuration: 0,
                        percent: record / 100,
                        barRadius: const Radius.circular(16),
                        progressColor: couleurBoutons,
                      ),
                    ),
                    Text(
                      record.toString(),
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(
                  height: 1.5.h,
                ),
                InkWell(
                  onTap: () async {
                    if (record == 0) {
                      record = 1;
                    }
                    int? nbVies = await getNbViesUtilisateurCourant();
                    if (nbVies! > 0) {
                      if (nomOeuvre == "onepiece") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnePieceGame(
                                fichierJson: jsonFichier,
                                nomIle: titre,
                                record: record,
                                numeroIle: numeroIle),
                          ),
                        );
                      } else if (nomOeuvre == "snk") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SNKGame(
                                fichierJson: jsonFichier,
                                nomIle: titre,
                                record: record,
                                numeroIle: numeroIle),
                          ),
                        );
                      } else if (nomOeuvre == "mha") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MHAGame(
                                fichierJson: jsonFichier,
                                nomIle: titre,
                                record: record,
                                numeroIle: numeroIle),
                          ),
                        );
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: "Vous n'avez plus de vies..",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 0,
                          backgroundColor: Colors.black,
                          textColor: Colors.blue,
                          fontSize: 16.0);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: couleurBoutons, // Bordure de couleur
                        width: 2, // Épaisseur de la bordure
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.w),
                      ),
                    ),
                    width: 35.w,
                    height: 6.h,
                    child: const Center(
                      child: Text(
                        "JOUER",
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

showResult(BuildContext context, int nbQuestion, int score, String jsonFichier,
    String nomIle, int record, int numeroIle, String nomOeuvre) async {
  int resultat = ((score / nbQuestion) * 100).round();
  double tailleEtoile = 12.w;

  String texteAfficher() {
    String phrase;
    if (resultat < 70) {
      phrase =
          'Votre score est de $resultat% vous ne pouvez pas passer au prochain niveau et perdez une vie...';
    } else if (resultat >= 70 && resultat < 80) {
      phrase =
          'Votre score est de  $resultat% bravo ! Vous pouvez passer au prochain niveau';
    } else if (resultat >= 80 && resultat < 90) {
      phrase =
          'Votre score est de  $resultat% bravo ! Vous pouvez passer au prochain niveau et gagnez 1 étoile !';
    } else if (resultat >= 90 && resultat < 100) {
      phrase =
          'Votre score est de  $resultat% bravo ! Vous pouvez passer au prochain niveau et gagnez 2 étoiles !';
    } else {
      phrase =
          'Votre score est de  $resultat% bravo GOAT ! Vous pouvez passer au prochain niveau et gagnez 3 étoiles !';
    }
    return phrase;
  }

  String afficherEtoiles(int positionEtoile) {
    String srcImg = imageEtoile;
    if (positionEtoile == 1) {
      if (resultat >= 80) {
        srcImg = 'assets/images/star.png';
      }
    }
    if (positionEtoile == 2) {
      if (resultat >= 90) {
        srcImg = 'assets/images/star.png';
      }
    }
    if (positionEtoile == 3) {
      if (resultat == 100) {
        srcImg = 'assets/images/star.png';
      }
    }
    return srcImg;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
          onWillPop: _onWillPop,
          child: AlertDialog(
            backgroundColor: couleurBleuAlternatif.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  4.w,
                ),
              ),
            ),
            contentPadding: EdgeInsets.only(
              top: 0.h,
            ),
            content: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: couleurBoutons, // Bordure de couleur
                  width: 3, // Épaisseur de la bordure
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(4.w),
                ),
              ),
              height: 48.h,
              width: 96.w,
              child: Stack(
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 0.h),
                          child: Image.asset(
                            afficherEtoiles(2),
                            width: tailleEtoile,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 0.h),
                              child: Image.asset(
                                afficherEtoiles(1),
                                width: tailleEtoile,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              margin: EdgeInsets.only(top: 0.h),
                              child: Image.asset(
                                afficherEtoiles(3),
                                width: tailleEtoile,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 2.w,
                            ),
                            SizedBox(
                              child: LinearPercentIndicator(
                                width: 60.w,
                                animation: true,
                                lineHeight: 20.0,
                                animationDuration: 0,
                                percent: resultat / 100,
                                barRadius: const Radius.circular(16),
                                progressColor: couleurBoutons,
                              ),
                            ),
                            Text(
                              '$resultat%',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          texteAfficher(),
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(
                                          0xff17c983), // Bordure de couleur
                                      width: 2, // Épaisseur de la bordure
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4.w),
                                    ),
                                  ),
                                  width: 35.w,
                                  height: 8.h,
                                  margin: EdgeInsets.only(top: 3.h),
                                  child: const Center(
                                    child: Text(
                                      "Rejouer",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  int? nbVies =
                                      await getNbViesUtilisateurCourant();
                                  if (nbVies! > 0) {
                                    if (nomOeuvre == "onepiece") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OnePieceGame(
                                            fichierJson: jsonFichier,
                                            nomIle: nomIle,
                                            record: record,
                                            numeroIle: numeroIle,
                                          ),
                                        ),
                                      );
                                    } else if (nomOeuvre == "snk") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SNKGame(
                                            fichierJson: jsonFichier,
                                            nomIle: nomIle,
                                            record: record,
                                            numeroIle: numeroIle,
                                          ),
                                        ),
                                      );
                                    } else if (nomOeuvre == "mha") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MHAGame(
                                            fichierJson: jsonFichier,
                                            nomIle: nomIle,
                                            record: record,
                                            numeroIle: numeroIle,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Vous n'avez plus de vies..",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 0,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.blue,
                                        fontSize: 16.0);
                                  }
                                }),
                            GestureDetector(
                                // Handle your onTap here.
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(
                                          0xff17c983), // Bordure de couleur
                                      width: 2, // Épaisseur de la bordure
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4.w),
                                    ),
                                  ),
                                  width: 35.w,
                                  height: 8.h,
                                  margin: EdgeInsets.only(top: 3.h),
                                  child: const Center(
                                    child: Text(
                                      "Continuer",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  if (nomOeuvre == "onepiece") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const OnePieceAventureScreen(),
                                      ),
                                    );
                                  } else if (nomOeuvre == "snk") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SNKAventureScreen(),
                                      ),
                                    );
                                  } else if (nomOeuvre == "mha") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SNKAventureScreen(),
                                      ),
                                    );
                                  }
                                }),
                          ],
                        ),
                      ])
                ],
              ),
            ),
          ));
    },
  );
}
