import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/DataBase/database.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/widgets/widget.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  // Utilisateur aléatoire
  List<int> randomList = [];
  Future<List<String>>? randomUids;

  // Pour le bouton refresh
  int _clickCount = 0;
  static const int _maxClicksPerMinute = 10;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _chargerProfilsAleatoires();
  }

  void _chargerProfilsAleatoires() {
    randomUids = getRandomUid();
    setState(() {
      randomUids;
    });
  }

  void _onButtonPressed() {
    if (_clickCount < _maxClicksPerMinute) {
      setState(() {
        _clickCount++;
      });
      _chargerProfilsAleatoires();

      if (_clickCount == 1) {
        // Démarrer le timer pour réinitialiser le compteur après une minute
        _resetTimer = Timer(const Duration(minutes: 1), () {
          setState(() {
            _clickCount = 0;
          });
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: "Seulement 10 actualisations par minute.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.blue,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(fondPrincipal2),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.w),
                color: couleurBoutons,
              ),
              margin: EdgeInsets.only(
                top: 6.h,
                left: 5.w,
                right: 5.w,
              ),
              width: 98.w,
              height: 8.h,
              child: Container(
                width: 94.w,
                height: 7.h,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff151692),
                      spreadRadius: 0,
                      blurRadius: 20.0,
                    ),
                  ],
                ),
                child: Container(
                  margin: EdgeInsets.only(
                    left: 1.w,
                    right: 1.w,
                  ),
                  child: Center(
                    child: Text(
                      "Découvre des joueurs".toUpperCase(),
                      style: TextStyle(
                        fontSize: 5.w,
                        color: couleurBoutons,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            FutureBuilder<List<String>>(
              future: randomUids,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Container(
                      margin: EdgeInsets.only(top: 2.h),
                      height: 65.h,
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length < 4
                              ? snapshot.data!.length
                              : 4,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                menuDiscover(context, snapshot.data![index]);
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 1.h, right: 4.5.w, left: 4.5.w),
                                child: banniereSectionDiscover(
                                    snapshot.data![index]),
                              ),
                            );
                          }),
                    );
                  } else {
                    // Gérer le cas où aucune donnée n'est disponible ou moins de 5 UID
                    return const Center(
                        child: Text(
                            "Aucun UID disponible ou moins de 5 UID trouvés"));
                  }
                } else if (snapshot.hasError) {
                  // Gérer les erreurs de récupération des données
                  return const Center(
                      child:
                          Text("Erreur lors de la récupération des données"));
                } else {
                  // Afficher un indicateur de chargement pendant la récupération des données
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff16318F).withOpacity(0.8),
                ),
                onPressed: _onButtonPressed,
                child: const Icon(
                  Icons.refresh,
                  size: 30,
                  semanticLabel: 'Recharger',
                  color: Color(0xff17c983),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void menuDiscover(BuildContext context, String uidDeLautreJoueur) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uidDeLautreJoueur)
          .get();

      if (!documentSnapshot.exists) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            content: Text("Document n'existe pas"),
          ),
        );
        return;
      }

      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                color: couleurBoutons,
                borderRadius: BorderRadius.all(
                  Radius.circular(4.w),
                ),
              ),
              height: 240,
              width: 280,
              child: Container(
                height: 210,
                width: 270,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff151692),
                      spreadRadius: 0,
                      blurRadius: 30.0,
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        data['pseudo'],
                        style: TextStyle(fontSize: 5.w, color: couleurBoutons),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: couleurBoutons,
                          width: 2, // Épaisseur de la bordure
                        ),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      height: 40,
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          DatabaseService(uid: uidDeLautreJoueur)
                              .envoyerInvitation(uidDeLautreJoueur);

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          // fixedSize: Size(250, 50),
                        ),
                        child: const Center(
                          child: Text(
                            "Devenir ami",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: couleurBoutons,
                          width: 2, // Épaisseur de la bordure
                        ),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      height: 40,
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? dateDernierLike =
                              await getDateDernierLikeUtilisateurCourant();
                          // Récupérer la date actuelle
                          DateTime currentDate = DateTime.now();
                          // Comparer les dates sans tenir compte de l'heure
                          bool isSameDay =
                              dateDernierLike!.year == currentDate.year &&
                                  dateDernierLike.month == currentDate.month &&
                                  dateDernierLike.day == currentDate.day;
                          if (!isSameDay) {
                            try {
                              await DatabaseService(uid: uidDeLautreJoueur)
                                  .updateLike(uidDeLautreJoueur);
                              Fluttertoast.showToast(
                                msg: "Like envoyé à ${data['pseudo']}",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.black,
                                textColor: Colors.blue,
                                fontSize: 16.0,
                              );
                            } catch (e) {
                              print(
                                  "Erreur lors de la mise à jour du nombre de likes");
                              print(e);
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg:
                                  "Vous avez déjà envoyé un like aujourd'hui !",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.black,
                              textColor: Colors.blue,
                              fontSize: 16.0,
                            );
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          // fixedSize: Size(250, 50),
                        ),
                        child: const Center(
                          child: Text(
                            "Envoyer un like",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: couleurBoutons,
                          width: 2, // Épaisseur de la bordure
                        ),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      height: 40,
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          String uidAmiDefier =
                              await getUidByPseudo(data['pseudo']);
                          await DatabaseService(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .envoyerSignalement(
                                  "Pseudo offensant", uidAmiDefier, context);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          // fixedSize: Size(250, 50),
                        ),
                        child: const Center(
                          child: Text(
                            "Signaler",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text("error"),
        ),
      );
    }
  }
}
