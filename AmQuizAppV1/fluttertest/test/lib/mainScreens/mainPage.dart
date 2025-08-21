// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:test/DataBase/database.dart';
import 'package:test/auth.dart';
import 'package:test/authentification/forgotPasswordScreen.dart';
import 'package:test/authentification/supprimerCompte.dart';
import 'package:test/aventureScreens/datas/question.dart';
import 'package:test/aventureScreens/menuAventure.dart';
import 'package:test/globalFunctions.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/main.dart';
import 'package:test/mainScreen.dart';
import 'package:test/mainScreens/datas/datasFriends.dart';
import 'package:test/multijoueur/vsScreen.dart';
import 'package:test/widgets/widget.dart';
import 'package:http/http.dart' as http;

const colorButtons = Color(0xFF2596be);

class MainPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final GlobalKey keyHome;
  final GlobalKey keyShop;
  final GlobalKey keyChecklist;
  final GlobalKey keyDiscover;
  final GlobalKey keyProfile;
  final GlobalKey keyParam;
  final GlobalKey keyTuto;
  final GlobalKey keyAmes;
  final GlobalKey keyBanniere;
  final GlobalKey keyFriends;
  final GlobalKey keySucess;
  final GlobalKey keyMiniGames;
  final GlobalKey keyAventures;
  final GlobalKey keyFinTuto;

  const MainPage({
    required this.userData,
    required this.keyHome,
    required this.keyShop,
    required this.keyChecklist,
    required this.keyDiscover,
    required this.keyProfile,
    required this.keyParam,
    required this.keyTuto,
    required this.keyAmes,
    required this.keyBanniere,
    required this.keyFriends,
    required this.keySucess,
    required this.keyMiniGames,
    required this.keyAventures,
    required this.keyFinTuto,
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final controller = PageController(initialPage: 0);

// Pour afficher rond vert quand amis en ligne
  Map<String, bool> friendsPresence = {};
// Amis page variables
  final List<String> _tabsFriends = ['Amis', 'Invitations'];

  // Pour ajouter un ami
  final addPseudoController = TextEditingController();
  bool userExist = false;
  bool userSajouteLuiMeme = true;
  bool userDejaAmis = true;
  bool userDejaInvite = true;
  final _formKeyAddFriend = GlobalKey<FormState>();

  // Daily missions
  final bool _isLoading = true;

  String nbFriends() {
    if (myFriends.isEmpty) {
      return "0";
    } else {
      return (myFriends.length).toString();
    }
  }

  @override
  void initState() {
    super.initState();
    getDataListeSucces();
    getDataInvitationsAndFriends();
    socket.off('receiveChallenge');
    socket.off('startPrivateGame');
    socket.onConnect((_) {
      print('Connecté au serveur Socket.IO');
      socket.emit('authenticate', FirebaseAuth.instance.currentUser!.uid);
    });

    socket.on('receiveChallenge', (data) async {
      print('Défi reçu : $data');
      String uidJoueur1 = data['senderUid']; // Défi envoyé par le joueur 1
      String nomOeuvre = data['nomOeuvre'];

      String pseudoJoueur1 = await getPseudoByUid(uidJoueur1);
      String pseudoJoueur2 = await getPseudoByUid(
        FirebaseAuth.instance.currentUser!.uid,
      );

      showTopSnackBar(
        context,
        "$pseudoJoueur1 vous défie sur $nomOeuvre",
        () {
          // Action pour "Accepter"
          socket.emit('acceptChallenge', {
            'uidJoueur1': uidJoueur1, // L'UID du joueur 1
            'uidJoueur2': FirebaseAuth.instance.currentUser!.uid, // Joueur 2
            'nomOeuvre': nomOeuvre,
            'pseudoJoueur1': pseudoJoueur1,
            'pseudoJoueur2': pseudoJoueur2,
          });
        },
        () {
          // Action pour "Refuser"
          socket.emit('declineChallenge', {'uidJoueur1': uidJoueur1});
        },
      );
    });

    socket.on('startPrivateGame', (data) {
      print('Données reçues dans startPrivateGame : $data');
      String roomId = data['roomId'];
      String quizName = data['quizName'];
      String nomOeuvre = data['nomOeuvre'];
      String uidJoueur1 = data['uidJoueur1'];
      String uidJoueur2 = data['uidJoueur2'];
      List<Question> questions =
          (data['questions'] as List).map((q) => Question.fromJson(q)).toList();

      // Déterminez l'UID ennemi
      String currentUid = FirebaseAuth.instance.currentUser!.uid;
      String uidEnnemi = currentUid == uidJoueur1 ? uidJoueur2 : uidJoueur1;

      // Navigation vers l'écran VsScreen
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => VsScreen(
            quizName: quizName,
            questions: questions,
            nomOeuvre: nomOeuvre,
            roomId: roomId,
            uidEnnemi: uidEnnemi,
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

  @override
  void dispose() {
    super.dispose();
  }

  void showTopSnackBar(BuildContext context, String message,
      VoidCallback onAccept, VoidCallback onDecline) {
    late OverlayEntry overlayEntry;
    bool isOverlayVisible = false; // Pour suivre l'état de l'overlay

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40.0, // Position en haut
        left: 16.0,
        right: 16.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 21, 69, 146),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (isOverlayVisible) {
                          onDecline();
                          overlayEntry.remove();
                          isOverlayVisible = false;
                        }
                      },
                      child: const Text(
                        "Refuser",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (isOverlayVisible) {
                          onAccept();
                          overlayEntry.remove();
                          isOverlayVisible = false;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleurBoutons,
                      ),
                      child: const Text("Accepter"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Ajouter l'Overlay
    Overlay.of(context).insert(overlayEntry);
    isOverlayVisible = true;
  }

  // Succes page variables
  final List<String> _tabsSucess = ['En cours', 'Terminé'];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(fondPrincipal3),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Showcase(
          key: widget.keyFinTuto,
          description: 'Tutoriel terminé, amusez-vous !',
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 5.h,
                      margin: EdgeInsets.only(top: 5.h, left: 0),
                      child: Row(
                        children: [
                          SizedBox(width: 3.w),
                          Showcase(
                            key: widget.keyParam,
                            description:
                                'Les paramètres, pour couper le son et se déconnecter par exemple',
                            child: SizedBox(
                              width: 17.w,
                              height: 5.h,
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    alignment: Alignment.center,
                                    backgroundColor:
                                        couleurBleuAlternatif.withOpacity(0.9),
                                    elevation: 3, // Effet d'ombre légère
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5.w), // Coins arrondis
                                      side: const BorderSide(
                                          color: Colors.black,
                                          width: 1), // Bordure personnalisée
                                    ),
                                  ),
                                  onPressed: () {
                                    paramView(context);
                                  },
                                  child: const Icon(
                                    Icons.build,
                                    semanticLabel: 'parametres',
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.0.w),
                          Showcase(
                            key: widget.keyTuto,
                            description: 'Pour re voir le tutoriel',
                            child: SizedBox(
                              width: 17.w,
                              height: 5.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      couleurBleuAlternatif.withOpacity(0.9),
                                  elevation: 3, // Effet d'ombre légère
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5.w), // Coins arrondis
                                    side: const BorderSide(
                                        color: Colors.black,
                                        width: 1), // Bordure personnalisée
                                  ),
                                ),
                                onPressed: () => reWatchTuto(context, [
                                  widget.keyHome,
                                  widget.keyShop,
                                  widget.keyChecklist,
                                  widget.keyDiscover,
                                  widget.keyDiscover,
                                  widget.keyParam,
                                  widget.keyTuto,
                                  widget.keyAmes,
                                  widget.keyBanniere,
                                  widget.keyFriends,
                                  widget.keySucess,
                                  widget.keyMiniGames,
                                  widget.keyAventures,
                                  widget.keyFinTuto,
                                ]),
                                child: Icon(
                                  Icons.help,
                                  semanticLabel: 'tutoriel',
                                  size: 2.h,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Showcase(
                            key: widget.keyAmes,
                            description:
                                'Le nombre d\'âmes que vous avez, les âmes sont la monnaie de l\'application',
                            child: Container(
                              margin: EdgeInsets.only(right: 2.w),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainScreen(0)));
                                },
                                child: nbAmes(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Showcase(
                      key: widget.keyBanniere,
                      description:
                          'Votre profil, contient pseudo, photo de profil, banniere, titre et nombre de like reçus',
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainScreen(4)));
                        },
                        child: Container(
                            margin: EdgeInsets.only(
                                top: 2.h, right: 4.5.w, left: 4.5.w),
                            child: banniereSection(widget.userData)),
                      ),
                    ),
                    twoButtonsSection(context),
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 76.w,
                            height: 34.h,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: 35.h,
                                viewportFraction: 1,
                                enlargeCenterPage: false,
                                autoPlayInterval: const Duration(seconds: 5),
                                autoPlay: true,
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                              ),
                              items: <Widget>[
                                SizedBox(
                                  child: Image.asset('assets/images/coeur.png',
                                      semanticLabel: 'coeur1'),
                                ),
                                SizedBox(
                                  child: Image.asset('assets/images/coeur.png',
                                      semanticLabel: 'coeur2'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    combatButtonsSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget twoButtonsSection(BuildContext context) => Container(
        height: 6.h,
        margin: EdgeInsets.only(top: 3.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Showcase(
                  key: widget.keyFriends,
                  description: 'Gérez vos amis et défiez les sur des quizs',
                  child: SizedBox(
                    width: 20.w,
                    height: 6.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleurBleuAlternatif
                            .withOpacity(0.8), // Bleu avec opacité
                        elevation: 3, // Effet d'ombre légère
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5.w), // Coins arrondis
                          side: const BorderSide(
                              color: Colors.black,
                              width: 1), // Bordure personnalisée
                        ),
                      ),
                      onPressed: () {
                        getDataInvitationsAndFriends().then((result) {
                          friendsView(context);
                        });
                      },
                      child: Icon(
                        Icons.people,
                        semanticLabel: 'amis',
                        size: 3.h,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<List<String>>(
                  valueListenable: invitationEnCoursNotifier,
                  builder: (context, myUidInvitations, child) {
                    if (myUidInvitations.isNotEmpty) {
                      return Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return const SizedBox
                        .shrink(); // Retourne un widget vide si la liste est vide
                  },
                ),
              ],
            ),
            SizedBox(width: 5.w),
            Showcase(
              key: widget.keySucess,
              description: 'Liste de missions permettant de gagner des âmes',
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 6.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleurBleuAlternatif
                            .withOpacity(0.8), // Bleu avec opacité
                        elevation: 3, // Effet d'ombre légère
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5.w), // Coins arrondis
                          side: const BorderSide(
                              color: Colors.black,
                              width: 1), // Bordure personnalisée
                        ),
                      ),
                      onPressed: () async {
                        await getDataListeSucces();
                        sucessView(context);
                      },
                      child: Icon(
                        Icons.local_play,
                        semanticLabel: 'succes',
                        size: 3.h,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: succesTermineNotifier,
                    builder: (context, succesTermine, child) {
                      if (succesTermine.isNotEmpty) {
                        return Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return const SizedBox
                          .shrink(); // Retourne un widget vide si la liste est vide
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Future sucessView(
    BuildContext context,
  ) {
    return (showDialog(
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
                height: 75.h,
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
                  height: 72.h,
                  width: 93.w,
                  child: DefaultTabController(
                    length: _tabsSucess.length,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 68.w, top: 1.5.h),
                          child: InkWell(
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
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          width: 98.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.w)),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.indigo,
                                spreadRadius: 0,
                                blurRadius: 15.0,
                              ),
                            ],
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.w)),
                            ),
                            height: 5.h,
                            child: TabBar(
                              dividerColor: Colors.transparent,
                              indicatorColor: Colors.transparent,
                              indicatorWeight: 1.w,
                              indicatorSize: TabBarIndicatorSize.label,
                              tabs: _tabsSucess
                                  .asMap()
                                  .entries
                                  .map((MapEntry map) {
                                String tab = map.value;
                                return Tab(
                                  child: Text(
                                    tab.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 4.w,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                              labelColor: couleurBoutons,
                              unselectedLabelColor: Colors.white,
                              onTap: (int index) {},
                            ),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: <Widget>[
                              Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.only(
                                        top: 2.h,
                                        right: 1.w,
                                        left: 1.w,
                                      ),
                                      itemCount: succesEncours?.length ?? 0,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        String key = succesEncours!.keys
                                            .elementAt(index);
                                        String missionName = succesEncours?[key]
                                                ?['name'] ??
                                            'Nom non défini';
                                        int progress = succesEncours?[key]
                                                ?['progress'] ??
                                            0;
                                        int total =
                                            succesEncours?[key]?['total'] ?? 0;
                                        int nbRecompenses = succesEncours?[key]
                                                ?['nbRecompenses'] ??
                                            0;

                                        String displayText = "$progress/$total";

                                        return Column(
                                          children: [
                                            Container(
                                              height: 10.h,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/Item1.png'),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 4.w),
                                                    height: 7.h,
                                                    width: 53.w,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        missionName,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 3.w,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 3.w,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: 8.w,
                                                        width: 12.w,
                                                        color: const Color(
                                                            0xff151692),
                                                        child: Stack(
                                                          alignment: Alignment
                                                              .center, // Centre le contenu du Stack
                                                          children: [
                                                            Center(
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/ame5.png',
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            ),
                                                            Positioned(
                                                              // Positionne le texte. Ajustez top, right, bottom, ou left selon le besoin
                                                              top:
                                                                  0, // Par exemple, pour le positionner en haut du container
                                                              right:
                                                                  0, // et à droite
                                                              child: Container(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.3), // Un fond semi-transparent pour le texte, si nécessaire
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        2), // Un petit padding autour du texte
                                                                child: Text(
                                                                  'X$nbRecompenses',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: 3
                                                                        .w, // Ajustez la taille du texte selon le besoin
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 1.h,
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: SizedBox(
                                                          height: 3.h,
                                                          width: 12.w,
                                                          child: Center(
                                                            child: Text(
                                                              displayText,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.only(
                                          top: 2.h, right: 1.w, left: 1.w),
                                      itemCount: succesTermine.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final mission = succesTermine[index];

                                        return Column(
                                          children: [
                                            Container(
                                              height: 10.h,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/Item1.png'),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 4.w),
                                                    height: 7.h,
                                                    width: 53.w,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        mission[
                                                            'name'], // Nom de la mission
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 3.w,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 3.w,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: 8.w,
                                                        width: 12.w,
                                                        color: const Color(
                                                            0xff151692),
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Center(
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/ame5.png',
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child: Container(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.3),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(2),
                                                                child: Text(
                                                                  'X${mission['nbRecompenses']}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        3.w,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 1.h,
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            final userId =
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid; // Remplacez par l'ID réel
                                                            final missionKey =
                                                                mission[
                                                                    'key']; // Utilisation de la clé
                                                            final nbRecompenses =
                                                                mission[
                                                                    'nbRecompenses'];

                                                            await DatabaseService(
                                                                    uid: FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                .obtenirRecompense(
                                                                    userId,
                                                                    missionKey,
                                                                    nbRecompenses);

                                                            setState(() {
                                                              succesTermine
                                                                  .removeAt(
                                                                      index);
                                                            });
                                                            await getDataListeSucces();
                                                          },
                                                          child: Container(
                                                            height: 3.h,
                                                            width: 13.w,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color(
                                                                  0xff17c983),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "Obtenir",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      2.5.w,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ));
  }

  Future paramView(BuildContext context) => showDialog(
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
                    height: 75.h,
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
                      height: 72.h,
                      width: 93.w,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 68.w, top: 1.5.h),
                            child: InkWell(
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
                          ),
                          SizedBox(height: 1.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: couleurBoutons,
                            ),
                            margin: EdgeInsets.only(
                              left: 5.w,
                              right: 5.w,
                            ),
                            width: 98.w,
                            height: 6.h,
                            child: Container(
                              width: 94.w,
                              height: 5.h,
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
                                    "Paramètres".toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 4.w,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 7.h),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(40.w, 8.h),
                                backgroundColor: colorAudioButton(audioActif),
                                side: const BorderSide(
                                    color: Colors.white, width: 1.0),
                              ),
                              onPressed: () {
                                setState(() {
                                  audioActif = !audioActif;
                                });
                              },
                              child: const Text(
                                'Audio',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(40.w, 8.h),
                                backgroundColor: couleurBleuAlternatif,
                                side: const BorderSide(
                                    color: Colors.white, width: 1.0),
                              ),
                              onPressed: () async {
                                await DatabaseService(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .updateUserPresence(false);
                                navigatorKey.currentState!.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const AuthScreen(),
                                  ),
                                );

                                print(
                                    '${FirebaseAuth.instance.currentUser!.uid} utilisateur déconnecté');
                                socket.disconnect();
                                FirebaseAuth.instance.signOut();
                                GoogleSignIn().signOut();
                              },
                              child: Text(
                                'Déconnexion',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 3.w,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(30.w, 5.h),
                                    backgroundColor: couleurBleuAlternatif,
                                    side: const BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    'Changer de mot de passe',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 2.5.w,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(30.w, 5.h),
                                    backgroundColor: couleurBleuAlternatif,
                                    side: const BorderSide(
                                        color: Colors.white, width: 1.0),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    DeleteAccountView1(context);
                                  },
                                  child: Text(
                                    'Supprimer mon compte',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 2.5.w,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(30.w, 5.h),
                                  backgroundColor: couleurBleuAlternatif,
                                  side: const BorderSide(
                                      color: Colors.white, width: 1.0),
                                ),
                                onPressed: () {
                                  final Uri toLaunch = Uri(
                                    scheme: 'https',
                                    host: 'drive.google.com',
                                    path:
                                        'file/d/1XR9DRlxMCGvWvSfm_smGFnQzksW4N8Zf/view',
                                  );
                                  launchInBrowser(toLaunch);
                                },
                                child: Text(
                                  'Conditions d\'utilisation',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 2.5.w),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    'Un problème ? Me contacter sur Twitter @AMQuiz_',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 3.w,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ));
            },
          );
        },
      );

  Future DeleteAccountView1(BuildContext context) => showDialog(
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
                    height: 40.h,
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
                      height: 47.h,
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
                                "Êtes-vous sur de vouloir supprimer votre compte ?",
                                style: TextStyle(
                                  fontSize: 4.5.w,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            margin: EdgeInsets.only(
                              left: 2.w,
                              right: 2.w,
                            ),
                            child: Center(
                              child: Text(
                                "Vos données seront perdues à tout jamais.",
                                style: TextStyle(
                                  fontSize: 4.w,
                                  color: Colors.red,
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
                                  backgroundColor: couleurBoutons,
                                ),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Text(
                                  'Annuler',
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
                                onPressed: () async {
                                  try {
                                    final user =
                                        FirebaseAuth.instance.currentUser;

                                    if (user != null) {
                                      // Vérifier si l'utilisateur est connecté via Google
                                      bool isGoogleUser = user.providerData.any(
                                        (info) =>
                                            info.providerId == 'google.com',
                                      );

                                      if (isGoogleUser) {
                                        // Supprimer le compte Google
                                        try {
                                          String? idToken = await FirebaseAuth
                                              .instance.currentUser
                                              ?.getIdToken();
                                          // Envoyer la requête au serveur pour supprimer le document associé dans Firestore
                                          final response = await http.delete(
                                            Uri.parse(
                                                '$urlServeur/api/users/supprimer-compte/${user.uid}'),
                                            headers: {
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization':
                                                  'Bearer $idToken', // Ajout du token dans le header
                                            },
                                          );
                                          await user.delete();
                                          if (response.statusCode == 200) {
                                            Fluttertoast.showToast(
                                                msg: "Compte supprimé",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 0,
                                                backgroundColor: Colors.black,
                                                textColor: Colors.blue,
                                                fontSize: 16.0);

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AuthScreen(),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          print(
                                              "Erreur lors de la suppression du compte Google : $e");
                                          Fluttertoast.showToast(
                                            msg:
                                                "Erreur lors de la suppression du compte Google. Veuillez réessayer",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.TOP,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        }
                                      } else {
                                        // Si ce n'est pas un compte Google, naviguer vers SupprimerCompte
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SupprimerCompte(),
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print(
                                        "Erreur lors de la gestion de la suppression du compte : $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Erreur lors de la suppression du compte."),
                                      ),
                                    );
                                  }
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

  Future friendsView(BuildContext context) => (showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: SingleChildScrollView(
                  child: Dialog(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          5.w,
                        ),
                      ),
                    ),
                    child: Container(
                      height: 75.h,
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
                        height: 72.h,
                        width: 93.w,
                        child: DefaultTabController(
                          length: _tabsFriends.length,
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 68.w, top: 1.5.h),
                                child: InkWell(
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
                                        borderRadius:
                                            BorderRadius.circular(5.w),
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
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 3.w),
                                width: 98.w,
                                height: 5.h,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.w)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.indigo,
                                      spreadRadius: 0,
                                      blurRadius: 15.0,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.w)),
                                  ),
                                  height: 5.h,
                                  child: TabBar(
                                    dividerColor: Colors.transparent,
                                    indicatorColor: Colors.transparent,
                                    indicatorWeight: 1.w,
                                    indicatorSize: TabBarIndicatorSize.label,
                                    tabs: _tabsFriends
                                        .asMap()
                                        .entries
                                        .map((MapEntry map) {
                                      String tab = map.value;
                                      return Tab(
                                        child: Text(
                                          tab.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 4.w,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    }).toList(),
                                    labelColor: couleurBoutons,
                                    unselectedLabelColor: Colors.white,
                                    onTap: (int index) {},
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: <Widget>[
                                    Center(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 1.h,
                                          ),
                                          Container(
                                            height: 6.h,
                                            width: 12.w,
                                            decoration: const BoxDecoration(
                                              color: Color(0xff17c983),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              height: 5.h,
                                              width: 10.w,
                                              decoration: const BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0xff151692),
                                                    spreadRadius: 0,
                                                    blurRadius: 15.0,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${nbFriends()}/50',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 4.w,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 1.h,
                                          ),
                                          SizedBox(
                                            height: 47.h,
                                            child: ListView.builder(
                                              padding: EdgeInsets.only(
                                                bottom: 2.h,
                                              ),
                                              itemCount: myFriends.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    showFriendsView(
                                                            myFriends[index],
                                                            index)
                                                        .then((result) {
                                                      setState(() {});
                                                    });
                                                  },
                                                  child: Column(
                                                    children: [
                                                      FutureBuilder<
                                                          List<String>>(
                                                        future:
                                                            getFriendsInfosByPseudo(
                                                                myFriends[
                                                                    index]),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return const CircularProgressIndicator(); // Affiche un indicateur de chargement pendant l'attente
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return Text(
                                                                'Erreur : ${snapshot.error}');
                                                          } else if (snapshot
                                                              .hasData) {
                                                            List<String>
                                                                infosAmis =
                                                                snapshot.data!;
                                                            return Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.w),
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      infosAmis[
                                                                          1]),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              height: 8.h,
                                                              width: 75.w,
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                      width:
                                                                          5.w),
                                                                  Stack(
                                                                    children: [
                                                                      CircleAvatar(
                                                                        radius:
                                                                            28,
                                                                        backgroundImage:
                                                                            AssetImage(infosAmis[0]),
                                                                      ),
                                                                      FutureBuilder<
                                                                          bool>(
                                                                        future:
                                                                            getPresenceByPseudo(myFriends[index]), // Fonction asynchrone qui retourne Future<bool>
                                                                        builder: (BuildContext
                                                                                context,
                                                                            AsyncSnapshot<bool>
                                                                                snapshot) {
                                                                          if (snapshot.connectionState == ConnectionState.done &&
                                                                              snapshot.data == true) {
                                                                            return Positioned(
                                                                              right: 8.w,
                                                                              bottom: 0,
                                                                              child: Container(
                                                                                width: 5.w,
                                                                                height: 2.h,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                  color: couleurBoutons,
                                                                                  border: Border.all(
                                                                                    color: Colors.black,
                                                                                    width: 1,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          } else {
                                                                            return const SizedBox.shrink(); // ou Container()
                                                                          }
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10.w),
                                                                  Container(
                                                                    width: 30.w,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.w),
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    child: Text(
                                                                      myFriends[
                                                                          index],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          2.w),
                                                                ],
                                                              ),
                                                            );
                                                          } else {
                                                            return const Text(
                                                                'Aucune information trouvée');
                                                          }
                                                        },
                                                      ),
                                                      SizedBox(height: 1.h),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            height: 1.h,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              addFriendView(context);
                                            },
                                            child: Container(
                                              height: 5.h,
                                              width: 15.w,
                                              decoration: BoxDecoration(
                                                color: couleurBoutons,
                                                borderRadius:
                                                    BorderRadius.circular(5.w),
                                              ),
                                              child: Container(
                                                height: 4.h,
                                                width: 12.w,
                                                decoration: const BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0xff151692),
                                                      spreadRadius: 0,
                                                      blurRadius: 15.0,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.person_add,
                                                    semanticLabel:
                                                        'ajouter ami',
                                                    size: 2.5.h,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Expanded(
                                          child: ListView.builder(
                                              padding: EdgeInsets.only(
                                                  top: 2.h,
                                                  right: 0.5.h,
                                                  left: 0.5.h),
                                              itemCount: myInvitations.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    print("a faire");
                                                  },
                                                  child: Column(
                                                    children: [
                                                      FutureBuilder<
                                                          List<String>>(
                                                        future:
                                                            getFriendsInfosByPseudo(
                                                                myInvitations[
                                                                    index]),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return const CircularProgressIndicator(); // Affiche un indicateur de chargement pendant l'attente
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return Text(
                                                                'Erreur : ${snapshot.error}');
                                                          } else if (snapshot
                                                              .hasData) {
                                                            List<String>
                                                                infosAmis =
                                                                snapshot.data!;
                                                            return Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.w),
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      infosAmis[
                                                                          1]),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              height: 8.h,
                                                              width: 75.w,
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                      width:
                                                                          5.w),
                                                                  CircleAvatar(
                                                                    radius: 28,
                                                                    backgroundImage:
                                                                        AssetImage(
                                                                            infosAmis[0]),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          2.w),
                                                                  Container(
                                                                    width: 30.w,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.w),
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    child: Text(
                                                                      myInvitations[
                                                                          index],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 2.w,
                                                                  ),
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      if (myFriends
                                                                              .length <
                                                                          50) {
                                                                        try {
                                                                          await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).addUserListeFriends(
                                                                              myUidInvitations[index],
                                                                              myInvitations[index]);
                                                                          await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                                                                              .deleteUserListeInvitations(index);
                                                                          setState(
                                                                              () {
                                                                            getDataInvitationsAndFriends();
                                                                          });
                                                                        } catch (e) {
                                                                          print(
                                                                              "Erreur lors de l'ajout de l'ami ou de la suppression de l'invitation");
                                                                          print(
                                                                              e);
                                                                        }
                                                                      } else {
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                "Vous avez déjà 50 amis",
                                                                            toastLength: Toast
                                                                                .LENGTH_LONG,
                                                                            gravity: ToastGravity
                                                                                .BOTTOM,
                                                                            timeInSecForIosWeb:
                                                                                0,
                                                                            backgroundColor:
                                                                                Colors.black,
                                                                            textColor: Colors.blue,
                                                                            fontSize: 16.0);
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                          .green,
                                                                      height:
                                                                          4.h,
                                                                      width:
                                                                          8.w,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .check,
                                                                        semanticLabel:
                                                                            'valider',
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            6.w,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 2.w,
                                                                  ),
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      try {
                                                                        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                                                                            .deleteUserListeInvitations(index);
                                                                        setState(
                                                                            () {
                                                                          getDataInvitationsAndFriends();
                                                                        });
                                                                      } catch (e) {
                                                                        print(
                                                                            "Erreur lors de la suppression de l'invitation");
                                                                        print(
                                                                            e);
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                          .red,
                                                                      height:
                                                                          4.h,
                                                                      width:
                                                                          8.w,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .close,
                                                                        semanticLabel:
                                                                            'fermer',
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            6.w,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          } else {
                                                            return const Text(
                                                                'Aucune information trouvée');
                                                          }
                                                        },
                                                      ),
                                                      SizedBox(
                                                        height: 1.h,
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ));

  Future addFriendView(BuildContext context) => (showDialog(
        barrierDismissible: false,
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
                  height: 27.h,
                  width: 68.w,
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
                      width: 66.w,
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(height: 2.h),
                            Text(
                              'Ajouter un ami',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 5.w,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Form(
                              key: _formKeyAddFriend,
                              child: SizedBox(
                                width: 55.w,
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  controller: addPseudoController,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.only(top: 0.2.h, left: 2.w),
                                    hintText: 'Pseudo',
                                    hintStyle: const TextStyle(
                                      color: Colors.white60,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 0.2.w,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: couleurBoutons,
                                        width: 0.2.w,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) async {
                                    final checkPseudoExiste =
                                        await userExists(value);
                                    final checkSiIlSajouteLuiMeme =
                                        await userIsIsSelf(value);
                                    final checkSiIlsSontDejaAmis =
                                        await userDejaAmi(value);
                                    final checkSiIlsSontDejaInvite =
                                        await userDejaInvit(value);
                                    setState(() {
                                      userExist = checkPseudoExiste;
                                      userSajouteLuiMeme =
                                          checkSiIlSajouteLuiMeme;
                                      userDejaAmis = checkSiIlsSontDejaAmis;
                                      userDejaInvite = checkSiIlsSontDejaInvite;
                                    });
                                  },
                                  validator: (value) {
                                    if (!RegExp("^[a-zA-Z0-9_]*\$")
                                        .hasMatch(value!)) {
                                      return "Un ou des caractère n'est pas valide";
                                    }
                                    if (!userExist) {
                                      return "Ce pseudo n'existe pas";
                                    }
                                    if (userSajouteLuiMeme) {
                                      return "C'est vous !";
                                    }
                                    if (userDejaAmis) {
                                      return "Vous êtes déjà amis !";
                                    }
                                    if (userDejaInvite) {
                                      return "Invitation déjà envoyée !";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      color: couleurBoutons,
                                    ),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xff151692),
                                            spreadRadius: 0,
                                            blurRadius: 15.0,
                                          ),
                                        ],
                                      ),
                                      width: 25.w,
                                      height: 5.h,
                                      child: Center(
                                        child: Text(
                                          'Annuler',
                                          style: TextStyle(
                                              fontSize: 4.w,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .pop(addPseudoController.text);
                                    addPseudoController.clear();
                                  },
                                ),
                                GestureDetector(
                                  // Handle your onTap here.
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      color: couleurBoutons,
                                    ),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xff151692),
                                            spreadRadius: 0,
                                            blurRadius: 15.0,
                                          ),
                                        ],
                                      ),
                                      width: 25.w,
                                      height: 5.h,
                                      child: Center(
                                        child: Text(
                                          'Ajouter',
                                          style: TextStyle(
                                              fontSize: 4.w,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    if (_formKeyAddFriend.currentState!
                                        .validate()) {
                                      try {
                                        String pseudoInvite =
                                            addPseudoController.text.trim();
                                        String uidAmiInvite =
                                            await getUidByPseudo(pseudoInvite);
                                        await DatabaseService(uid: uidAmiInvite)
                                            .envoyerInvitation(uidAmiInvite);
                                        Navigator.of(context)
                                            .pop(addPseudoController.text);
                                        addPseudoController.clear();
                                        setState(() {
                                          getDataInvitationsAndFriends();
                                        });
                                      } catch (e) {
                                        print("petit flop de l'invitation mec");
                                        print(e);
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                ),
              );
            },
          );
        },
      ));

  Future showFriendsView(String pseudo, int index) => (showDialog(
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
                        pseudo,
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
                          String uidAmi = await getUidByPseudo(pseudo);
                          await DatabaseService(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .supprimerAmi(uidAmi, index);

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          // fixedSize: Size(250, 50),
                        ),
                        child: const Center(
                          child: Text(
                            "Supprimer ami",
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
      ));

  Widget imageAndTextSection = Container(
    margin: EdgeInsets.only(top: 4.h, right: 5.5.w, left: 5.5.w),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.w),
        color: Colors.white,
      ),
      width: 82.w,
      height: 35.h,
      child: Container(
        width: 80.w,
        height: 34.h,
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
          child: Image.asset('assets/images/caca.jpg', fit: BoxFit.cover),
        ),
      ),
    ),
  );

  Widget combatButtonsSection(BuildContext c) => Container(
        height: 9.h,
        margin: EdgeInsets.only(top: 4.h, right: 5.5.w, left: 5.5.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Showcase(
              key: widget.keyMiniGames,
              description: 'Différents mini jeux, en ligne ou non',
              child: InkWell(
                onTap: () => miniJeux(context),
                child: Container(
                  width: 40.w,
                  height: 9.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: couleurBleuAlternatif.withOpacity(0.9),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        // Texte avec la bordure noire
                        Text(
                          "MINI-JEUX".toUpperCase(),
                          style: TextStyle(
                            fontSize: 23,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1 // Épaisseur de la bordure
                              ..color = Colors.black, // Couleur de la bordure
                          ),
                        ),
                        // Texte principal en blanc
                        Text(
                          "MINI-JEUX".toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Showcase(
              key: widget.keyAventures,
              description:
                  'Le mode aventure qui propose des quizs sur des oeuvres en suivant l\'ordre chronologique',
              child: InkWell(
                onTap: () => Navigator.push(
                  c,
                  MaterialPageRoute(
                    builder: (context) => const MenuAventure(),
                  ),
                ),
                child: Container(
                  width: 40.w,
                  height: 9.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: couleurBleuAlternatif.withOpacity(0.9),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        // Texte avec la bordure noire
                        Text(
                          "Aventure".toUpperCase(),
                          style: TextStyle(
                            fontSize: 23,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1 // Épaisseur de la bordure
                              ..color = Colors.black, // Couleur de la bordure
                          ),
                        ),
                        // Texte principal en blanc
                        Text(
                          "Aventure".toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
