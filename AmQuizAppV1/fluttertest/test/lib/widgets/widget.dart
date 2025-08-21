// ignore_for_file: non_constant_identifier_names

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:test/DataBase/database.dart';
import 'package:test/aventureScreens/datas/dataIsland.dart';
import 'package:test/globalFunctions.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreen.dart';
import 'package:test/miniGamesScreens/whoAmI.dart';
import 'package:test/multijoueur/findOpponentScreen.dart';

Widget banniereSection(Map<String, dynamic> userData) {
  // Récupérer les données nécessaires depuis userData
  final banniereData = userData['banniereProfil'] as Map<String, dynamic>;
  final pseudo = userData['pseudo'] as String;
  final titre = userData['titre'] as String;
  final nbLike = userData['nbLike'] as int;

  // Déterminer la couleur du conteneur en fonction de la rareté
  Color couleurContainerBanniere;
  if (banniereData['rarity'] == "ItemRarity.rare") {
    couleurContainerBanniere = Colors.grey;
  } else if (banniereData['rarity'] == "ItemRarity.legendaire") {
    couleurContainerBanniere = Colors.yellow;
  } else {
    couleurContainerBanniere = Colors.brown;
  }

  return Container(
    height: 140,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5.w),
      image: DecorationImage(
        image: AssetImage(banniereData['imageUrl']),
        fit: BoxFit.fill,
      ),
    ),
    child: Row(
      children: [
        Container(
          height: 115,
          margin: const EdgeInsets.only(left: 13),
          child: Image.asset(userData['urlImgProfil'], fit: BoxFit.fill),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: couleurContainerBanniere.withOpacity(0.5),
                    border: Border.all(
                      color: couleurContainerBanniere,
                      width: 3, // Épaisseur de la bordure
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  width: 170,
                  child: Text(
                    pseudo,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: couleurContainerBanniere.withOpacity(0.8),
                    border: Border.all(
                      color: couleurContainerBanniere,
                      width: 3, // Épaisseur de la bordure
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  width: 130,
                  child: Text(
                    titre,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: couleurContainerBanniere.withOpacity(0.8),
                    border: Border.all(
                      color: couleurContainerBanniere,
                      width: 3, // Épaisseur de la bordure
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  width: 62,
                  child: Row(
                    children: [
                      Text(
                        nbLike.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.heart_broken,
                        size: 13,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    ),
  );
}

Widget banniereSectionVSScreen(String uidAutiliser) =>
    StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(uidAutiliser)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("error");
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text("....");
          }
          if (snapshot.connectionState == ConnectionState.active) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            Color couleurContainerBanniere;
            if (data['banniereProfil']['rarity'] == "ItemRarity.rare") {
              couleurContainerBanniere = Colors.grey;
            } else if (data['banniereProfil']['rarity'] ==
                "ItemRarity.legendaire") {
              couleurContainerBanniere = Colors.yellow;
            } else {
              couleurContainerBanniere = Colors.brown;
            }
            return Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.w),
                image: DecorationImage(
                    image: AssetImage(data['banniereProfil']['imageUrl']),
                    fit: BoxFit.fill),
              ),
              child: Row(
                children: [
                  Container(
                    height: 115,
                    margin: const EdgeInsets.only(
                      left: 13,
                    ),
                    child: Image.asset(data['urlImgProfil'], fit: BoxFit.fill),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: couleurContainerBanniere.withOpacity(0.5),
                              border: Border.all(
                                color: couleurContainerBanniere,
                                width: 3, // Épaisseur de la bordure
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            width: 170,
                            child: Text(
                              data['pseudo'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: couleurContainerBanniere.withOpacity(0.8),
                              border: Border.all(
                                color: couleurContainerBanniere,
                                width: 3, // Épaisseur de la bordure
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            width: 130,
                            child: Text(
                              data['titre'],
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: couleurContainerBanniere.withOpacity(0.8),
                              border: Border.all(
                                color: couleurContainerBanniere,
                                width: 3, // Épaisseur de la bordure
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 10, right: 5),
                            width: 62,
                            child: Row(
                              children: [
                                Text(
                                  data['nbLike'].toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                const Icon(
                                  Icons.heart_broken,
                                  size: 13,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return Container(
              height: 140,
              color: Colors.transparent,
              child: const Text("Chargement..."));
        });

Widget banniereSectionDiscover(String uidAleatoire) =>
    StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(uidAleatoire)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("error");
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text("Document n'existe pas");
          }
          if (snapshot.connectionState == ConnectionState.active) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            Color couleurContainerBanniere;
            if (data['banniereProfil']['rarity'] == "ItemRarity.rare") {
              couleurContainerBanniere = Colors.grey;
            } else if (data['banniereProfil']['rarity'] ==
                "ItemRarity.legendaire") {
              couleurContainerBanniere = Colors.yellow;
            } else {
              couleurContainerBanniere = Colors.brown;
            }
            return Container(
              height: 125,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.w),
                image: DecorationImage(
                    image: AssetImage(data['banniereProfil']['imageUrl']),
                    fit: BoxFit.fill),
              ),
              child: Row(
                children: [
                  Container(
                    height: 105,
                    margin: const EdgeInsets.only(
                      left: 13,
                    ),
                    child: Image.asset(data['urlImgProfil'], fit: BoxFit.fill),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: couleurContainerBanniere.withOpacity(0.8),
                              border: Border.all(
                                color: couleurContainerBanniere,
                                width: 3, // Épaisseur de la bordure
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            width: 170,
                            child: Text(
                              data['pseudo'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: couleurContainerBanniere.withOpacity(0.8),
                              border: Border.all(
                                color: couleurContainerBanniere,
                                width: 3, // Épaisseur de la bordure
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            width: 140,
                            child: Text(
                              data['titre'],
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: couleurContainerBanniere.withOpacity(0.8),
                              border: Border.all(
                                color: couleurContainerBanniere,
                                width: 3, // Épaisseur de la bordure
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 10, right: 5),
                            width: 63,
                            child: Row(
                              children: [
                                Text(
                                  data['nbLike'].toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                const Icon(
                                  Icons.heart_broken,
                                  size: 12,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return Container(
              height: 140,
              color: Colors.transparent,
              child: const Text("Chargement..."));
        });

// Widget coupSpecial(CoupSpeciaux coup) => Image.asset(
//       coup.imageUrl,
//       width: 70,
//       height: 70,
//     );

Future reWatchTuto(BuildContext context, List<GlobalKey> showcaseKeys) =>
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      5.w,
                    ),
                  ),
                ),
                child: Container(
                  height: 25.h,
                  width: 98.w,
                  decoration: BoxDecoration(
                    color: couleurBoutons,
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.w),
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xff151692),
                          spreadRadius: 0,
                          blurRadius: 30.0,
                        ),
                      ],
                    ),
                    height: 24.h,
                    width: 93.w,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 72.w, top: 1.5.h),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Image.asset(
                              'assets/images/croix.png',
                              width: 5.w,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          margin: EdgeInsets.only(
                            left: 2.w,
                            right: 2.w,
                          ),
                          child: Center(
                            child: Text(
                              "Revoir le tutoriel ?",
                              style: TextStyle(
                                fontSize: 4.5.w,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(30.w, 5.h),
                                backgroundColor: couleurBoutons,
                              ),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                              child: Text(
                                'Non',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 3.w,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(30.w, 5.h),
                                backgroundColor: couleurBoutons,
                              ),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  ShowCaseWidget.of(context)
                                      .startShowCase(showcaseKeys);
                                });
                              },
                              child: Text(
                                'Oui',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 3.w,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ));
          },
        );
      },
    );

Future askLeaveAventure(BuildContext context) => showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      5.w,
                    ),
                  ),
                ),
                child: Container(
                  height: 28.h,
                  width: 98.w,
                  decoration: BoxDecoration(
                    color: couleurBoutons,
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.w),
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xff151692),
                          spreadRadius: 0,
                          blurRadius: 30.0,
                        ),
                      ],
                    ),
                    height: 27.h,
                    width: 93.w,
                    child: Column(
                      children: [
                        SizedBox(height: 5.h),
                        Container(
                          margin: EdgeInsets.only(
                            left: 2.w,
                            right: 2.w,
                          ),
                          child: Center(
                            child: Text(
                              "Si vous revenez en arrière vous perdrez une vie",
                              style: TextStyle(
                                fontSize: 4.5.w,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(30.w, 5.h),
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Annuler',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 4.w,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(30.w, 5.h),
                                backgroundColor: couleurBoutons,
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                await DatabaseService(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .debloqueProchaineIleOnePiece(0, 0);
                              },
                              child: Text(
                                'Ok',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 4.w,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ));
          },
        );
      },
    );

const colorizeTextStyleForShop = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.bold,
);

Widget bronzeTextAnimer() => AnimatedTextKit(
      repeatForever: true,
      pause: const Duration(seconds: 5),
      animatedTexts: [
        ColorizeAnimatedText(
          "Bronze".toUpperCase(),
          textStyle: colorizeTextStyleForShop,
          colors: bronzeColors,
        ),
      ],
    );

Widget argentTextAnimer() => AnimatedTextKit(
      repeatForever: true,
      pause: const Duration(seconds: 5),
      animatedTexts: [
        ColorizeAnimatedText(
          "Argent".toUpperCase(),
          textStyle: colorizeTextStyleForShop,
          colors: silverColors,
        ),
      ],
    );

Widget orTextAnimer() => AnimatedTextKit(
      repeatForever: true,
      pause: const Duration(seconds: 5),
      animatedTexts: [
        ColorizeAnimatedText(
          "Or".toUpperCase(),
          textStyle: colorizeTextStyleForShop,
          colors: goldColors,
        ),
      ],
    );

Widget nbAmes() => Container(
      decoration: BoxDecoration(
        color: couleurBleuAlternatif.withOpacity(0.9),
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(2.w),
      ),
      width: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(width: 2.w),
          StreamBuilder<DocumentSnapshot>(
            stream: usersCollection
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("ERREUR");
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return const Text("ERREUR");
              }

              if (snapshot.connectionState == ConnectionState.active) {
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                return Text(
                  data['nbAmes'].toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                );
              }

              return const Text("...");
            },
          ),
          SizedBox(width: 2.w),
          Container(
            margin: (EdgeInsets.symmetric(vertical: 1.w)),
            width: 37,
            height: 40,
            child: Image.asset(
              'assets/images/ame5.png',
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(width: 1.w),
        ],
      ),
    );

Widget nbAmes2() => Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: couleurBoutons,
          width: 2, // Épaisseur de la bordure
        ),
        color: const Color(0xff16318F).withOpacity(0.9),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(width: 2.w),
          StreamBuilder<DocumentSnapshot>(
            stream: usersCollection
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("ERREUR");
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return const Text("ERREUR");
              }

              if (snapshot.connectionState == ConnectionState.active) {
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                return Text(
                  data['nbAmes'].toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                );
              }

              return const Text("...");
            },
          ),
          SizedBox(width: 2.w),
          Container(
            margin: (EdgeInsets.symmetric(vertical: 1.w)),
            width: 30,
            height: 30,
            child: Image.asset(
              'assets/images/ame5.png',
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(width: 1.w),
        ],
      ),
    );

Widget ItemsObtenable() => Icon(
      Icons.info_outline,
      color: couleurBoutons,
      size: 8.w,
    );

Widget nbVies(BuildContext c) => Positioned(
      top: 6.h,
      right: 2.w,
      child: InkWell(
        onTap: () => Navigator.push(
          c,
          MaterialPageRoute(
            builder: (context) => MainScreen(0),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: couleurBoutons,
              width: 2, // Épaisseur de la bordure
            ),
            color: const Color(0xff16318F).withOpacity(0.9),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 8,
              ),
              SizedBox(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: usersCollection
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("ERREUR");
                    }

                    if (snapshot.hasData && !snapshot.data!.exists) {
                      return const Text("ERREUR");
                    }

                    if (snapshot.connectionState == ConnectionState.active) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Text(
                        data['nbVie'].toString(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      );
                    }

                    return const Text("...");
                  },
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              SizedBox(
                child: Image.asset(
                  'assets/images/coeur.png',
                  width: 27,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
        ),
      ),
    );

Future miniJeux(
  BuildContext context,
) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5.w),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff151692),
            borderRadius: BorderRadius.circular(15), // Bord arrondi
            border: Border.all(
              color: couleurBoutons,
              width: 2,
            ),
          ),
          width: 95.w,
          height: 95.w,
          child: Column(
            children: [
              SizedBox(
                height: 1.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        color: couleurBoutons,
                      ),
                      width: 7.w,
                      height: 3.5.h,
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
                        width: 7.w,
                        height: 3.5.h,
                        child: Image.asset(
                          'assets/images/cross.png',
                          width: 3.w,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 3.w,
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      listeQuizs(context);
                    },
                    child: _buildStack(
                      context,
                      'assets/images/quiz.png',
                      "Quizs multijoueur",
                      const Color(0xff1616f6),
                      Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WhoAmI(
                            fichierJson: "whoAmI",
                          ),
                        ),
                      );
                    },
                    child: _buildStack(
                      context,
                      'assets/images/quiSuisJe.png',
                      "Qui suis-je ?",
                      const Color(0xffd7f616),
                      Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Espace entre les lignes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // _buildStack(
                  //   context,
                  //   'assets/images/quiEsTu.png',
                  //   "Qui es-tu ?",
                  //   const Color(0xff16f63b),
                  //   Colors.black,
                  // ),
                  Container(
                    width: 35.w,
                    height: 35.w,
                    decoration: BoxDecoration(
                      color: const Color(0xff666666),
                      borderRadius: BorderRadius.circular(15), // Bord arrondi
                      border: Border.all(
                        color: couleurBoutons,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "A venir..".toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildStack(BuildContext context, String asset, String label,
    Color color, Color textColor) {
  return Stack(
    children: [
      Container(
        width: 35.w,
        height: 35.w,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15), // Bord arrondi
          border: Border.all(
            color: couleurBoutons,
            width: 2,
          ),
        ),
      ),
      Positioned(
        top: 20,
        left: 30,
        child: Image.asset(
          asset,
          width: 40, // Taille de chaque image
          height: 40,
        ),
      ),
      Positioned(
        top: 60,
        left: 115,
        child: Image.asset(
          asset,
          width: 30, // Taille de chaque image
          height: 30,
        ),
      ),
      Positioned(
        top: 100,
        left: 10,
        child: Image.asset(
          asset,
          width: 30, // Taille de chaque image
          height: 30,
        ),
      ),
      Positioned(
        top: 115,
        left: 100,
        child: Image.asset(
          asset,
          width: 40, // Taille de chaque image
          height: 40,
        ),
      ),
      SizedBox(
        width: 35.w,
        height: 35.w,
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  );
}

Future<void> listeQuizs(BuildContext context) {
  List<String> themeQuiz = [
    "Toutes œuvres",
    "One Piece",
    "Naruto",
    "Attaque des titans",
    "Dragon Ball Z",
    "Kingdom"
  ];
  TextEditingController searchController = TextEditingController();
  List<String> filteredList = List.from(themeQuiz);

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Color(0xff17c983)),
            ),
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: const Color(0xff151692),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.w),
                          color: couleurBoutons,
                        ),
                        width: 7.w,
                        height: 3.5.h,
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
                          width: 7.w,
                          height: 3.5.h,
                          child: Image.asset(
                            'assets/images/cross.png',
                            width: 3.w,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                          minHeight: 40, // Divise la hauteur
                          maxHeight: 40),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            filteredList = themeQuiz
                                .where((quiz) => quiz
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher une oeuvre',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xff17c983),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xff1616f6),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xff17c983),
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xff17c983)),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredList.map((quizName) {
                            return InkWell(
                              onTap: () {
                                String jsonFichier = 'questionsOnePiece2';
                                String themeQuizz = "onepiece";
                                if (quizName == "One Piece") {
                                  jsonFichier = 'questionsOnePiece2';
                                  themeQuizz = "onepiece";
                                } else if (quizName == "Naruto") {
                                  jsonFichier = 'questionsOnePiece2';
                                  themeQuizz = "naruto";
                                } else if (quizName == "Attaque des titans") {
                                  jsonFichier = 'questionsOnePiece2';
                                  themeQuizz = "Attaque des titans";
                                }
                                DatabaseService(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .faireQuizMulti(themeQuizz);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FindOpponentScreen(
                                      quizName: jsonFichier,
                                      themeQuizz: themeQuizz,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xff1616f6),
                                  border:
                                      Border.all(color: Colors.green, width: 2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10.w),
                                child: Center(
                                  child: Text(
                                    quizName,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.sp),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
    },
  );
}

Future<void> listeQuizsDefis(BuildContext context, String uidCurrentUser,
    String uidAmiADefier, Socket socket) {
  List<String> themeQuiz = [
    "Toutes œuvres",
    "One Piece",
    "Naruto",
    "Attaque des titans",
    "Dragon Ball Z",
    "Kingdom"
  ];
  TextEditingController searchController = TextEditingController();
  List<String> filteredList = List.from(themeQuiz);

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Color(0xff17c983)),
            ),
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: const Color(0xff151692),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.w),
                          color: couleurBoutons,
                        ),
                        width: 7.w,
                        height: 3.5.h,
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
                          width: 7.w,
                          height: 3.5.h,
                          child: Image.asset(
                            'assets/images/cross.png',
                            width: 3.w,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                          minHeight: 40, // Divise la hauteur
                          maxHeight: 40),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            filteredList = themeQuiz
                                .where((quiz) => quiz
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher une oeuvre',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xff17c983),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xff1616f6),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xff17c983),
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xff17c983)),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredList.map((quizName) {
                            return InkWell(
                              onTap: () async {
                                String themeQuizz = "onepiece";
                                if (quizName == "One Piece") {
                                  themeQuizz = "onepiece";
                                } else if (quizName == "Naruto") {
                                  themeQuizz = "naruto";
                                } else if (quizName == "Attaque des titans") {
                                  themeQuizz = "Attaque des titans";
                                }
                                DatabaseService(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .faireQuizMultiAvecAmi();
                                print('Socket connected: ${socket.connected}');
                                String pseudoAdversaire =
                                    await getPseudoByUid(uidAmiADefier);
                                socket.emit('sendChallenge', {
                                  'senderUid': uidCurrentUser,
                                  'receiverUid': uidAmiADefier,
                                  'nomOeuvre': themeQuizz,
                                });
                                print(
                                    'Défi envoyé : $uidCurrentUser défie $uidAmiADefier sur $quizName');
                                Fluttertoast.showToast(
                                    msg: "Défi envoyé à $pseudoAdversaire",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 0,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.blue,
                                    fontSize: 16.0);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xff1616f6),
                                  border:
                                      Border.all(color: Colors.green, width: 2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10.w),
                                child: Center(
                                  child: Text(
                                    quizName,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.sp),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
    },
  );
}

Widget ileAventureOnePiece(
    BuildContext context,
    double intervalle,
    int avanceeIle,
    String jsonFile,
    String nomile,
    int recordIle,
    int numeroIle) {
  double tailleEtoiles = 25;
  int nbEtoiles = nbEtoilesAventure(recordIle);

  return Row(
    children: [
      SizedBox(width: intervalle),
      Column(
        children: [
          recordIle > 0
              ? Row(
                  children: [
                    SizedBox(width: 1.w),
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
                )
              : const SizedBox(height: 25),
          SizedBox(height: 1.h),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff151692),
              border: Border.all(
                color: couleurBleuAlternatif,
                width: 2.0, // Une bordure fine
              ),
            ),
            child: recordIle > 0
                ? InkWell(
                    onTap: () {
                      showIsland(context, nomile, nbEtoiles, recordIle,
                          jsonFile, numeroIle, "onepiece");
                    },
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: Text(
                          nomile,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .white, // Ajuster la couleur du texte si nécessaire
                          ),
                        ),
                      ),
                    ),
                  )
                : Shimmer.fromColors(
                    baseColor: const Color(0xff151692),
                    highlightColor: const Color.fromARGB(255, 113, 113, 211),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300], // Fond pour l'effet shimmer
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ],
  );
}

Widget ileAventureSNK(BuildContext context, double intervalle, int avanceeIle,
    String jsonFile, String nomile, int recordIle, int numeroIle) {
  double tailleEtoiles = 25;
  int nbEtoiles = nbEtoilesAventure(recordIle);

  return Row(
    children: [
      SizedBox(width: intervalle),
      Column(
        children: [
          recordIle > 0
              ? Row(
                  children: [
                    SizedBox(width: 1.w),
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
                )
              : const SizedBox(height: 25),
          SizedBox(height: 1.h),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff151692),
              border: Border.all(
                color: couleurBleuAlternatif,
                width: 2.0, // Une bordure fine
              ),
            ),
            child: recordIle > 0
                ? InkWell(
                    onTap: () {
                      showIsland(
                        context,
                        nomile,
                        nbEtoiles,
                        recordIle,
                        jsonFile,
                        numeroIle,
                        "snk",
                      );
                    },
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: Text(
                          nomile,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .white, // Ajuster la couleur du texte si nécessaire
                          ),
                        ),
                      ),
                    ),
                  )
                : Shimmer.fromColors(
                    baseColor: const Color(0xff151692),
                    highlightColor: const Color.fromARGB(255, 113, 113, 211),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300], // Fond pour l'effet shimmer
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ],
  );
}

Widget ileAventureMHA(BuildContext context, double intervalle, int avanceeIle,
    String jsonFile, String nomile, int recordIle, int numeroIle) {
  double tailleEtoiles = 25;
  int nbEtoiles = nbEtoilesAventure(recordIle);

  return Row(
    children: [
      SizedBox(width: intervalle),
      Column(
        children: [
          recordIle > 0
              ? Row(
                  children: [
                    SizedBox(width: 1.w),
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
                )
              : const SizedBox(height: 25),
          SizedBox(height: 1.h),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff151692),
              border: Border.all(
                color: couleurBleuAlternatif,
                width: 2.0, // Une bordure fine
              ),
            ),
            child: recordIle > 0
                ? InkWell(
                    onTap: () {
                      showIsland(
                        context,
                        nomile,
                        nbEtoiles,
                        recordIle,
                        jsonFile,
                        numeroIle,
                        "mha",
                      );
                    },
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: Text(
                          nomile,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .white, // Ajuster la couleur du texte si nécessaire
                          ),
                        ),
                      ),
                    ),
                  )
                : Shimmer.fromColors(
                    baseColor: const Color(0xff151692),
                    highlightColor: const Color.fromARGB(255, 113, 113, 211),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300], // Fond pour l'effet shimmer
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ],
  );
}
