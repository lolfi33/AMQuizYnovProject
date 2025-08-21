// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:test/DataBase/database.dart';
import 'package:test/globalFunctions.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreens/datas/datasChestEnvelop.dart';
import 'package:test/widgets/widget.dart';

import 'datas/datasChestScreen.dart';

class ChestScreen extends StatefulWidget {
  const ChestScreen({super.key});

  @override
  State<ChestScreen> createState() => _ChestScreenState();
}

class _ChestScreenState extends State<ChestScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => false;

  // Les items a obtenir
  Item? selectedItem;
  Item? selectedItemProfilSilver;
  Item? selectedItemProfilGold;
  Item? selectedItemBanniereBronze;
  Item? selectedItemBanniereSilver;
  Item? selectedItemBanniereGold;
  bool isButtonDisabled = false;

  // Pour animation ouvertures
  late AnimationController _controller;
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late AnimationController _controller4;
  late AnimationController _controller5;
  late Animation<double> _animation;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;
  late Animation<double> _animation4;
  late Animation<double> _animation5;
  late AnimationController _logoController;
  late AnimationController _logoController1;
  late AnimationController _logoController2;
  late AnimationController _logoController3;
  late AnimationController _logoController4;
  late AnimationController _logoController5;
  late Animation<double> _logoAnimation;
  late Animation<double> _logoAnimation1;
  late Animation<double> _logoAnimation2;
  late Animation<double> _logoAnimation3;
  late Animation<double> _logoAnimation4;
  late Animation<double> _logoAnimation5;

  //Pour animation gain d'ames
  bool _showImages = false;
  late AnimationController _controllerAme1;
  late AnimationController _controllerAme2;
  late AnimationController _controllerAme3;

  late TabController _tabController;
  // Pour changer le fond d'ecran
  ValueNotifier<String> fondNotifier = ValueNotifier(fondPrincipal4);
  String fondActuel = fondPrincipal4; // Image de fond initiale

  // Pour vendre profil et bannière
  int valeurVente = 0;

  // Pour vendre profil
  bool profilChoisi = false;
  Item? profilSelectionne;
  bool aSelectionnerProfil = false;

  // Pour vendre bannière
  bool banniereChoisi = false;
  Item? banniereSelectionne;
  bool aSelectionnerBanniere = false;

  static const colorizeTextStyle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  static const colorizeTextStyleDrop = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  final List<String> _tabsTitres = ['Ouverture', 'Vendre'];

  @override
  void dispose() {
    _controller.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    _logoController.dispose();
    _logoController1.dispose();
    _logoController2.dispose();
    _logoController3.dispose();
    _logoController4.dispose();
    _logoController5.dispose();
    _tabController.dispose();
    _controllerAme1.dispose();
    _controllerAme2.dispose();
    _controllerAme3.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (isButtonDisabled) return; // Ignore les clics si le bouton est désactivé

    setState(() {
      isButtonDisabled = true; // Désactive le bouton
    });

    if (index == 0) {
      // Récupérer l'item du serveur avant de lancer l'animation
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .ouvrirCoffre("commun")
          .then((item) {
        if (item != null) {
          setState(() {
            selectedItem = item;
          });

          // Lancer l'animation une fois l'item mis à jour
          _controller.forward();
        } else {
          print("Aucun item reçu du serveur");
        }
      }).catchError((error) {
        print("Erreur lors de l'ouverture du coffre : $error");
      });

      _logoController.forward();
    }
    if (index == 1) {
      // Récupérer l'item du serveur avant de lancer l'animation
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .ouvrirCoffre("rare")
          .then((item) {
        if (item != null) {
          setState(() {
            selectedItemProfilSilver = item;
          });

          // Lancer l'animation une fois l'item mis à jour
          _controller1.forward();
        } else {
          print("Aucun item reçu du serveur");
        }
      }).catchError((error) {
        print("Erreur lors de l'ouverture du coffre : $error");
      });

      _logoController1.forward();
    }
    if (index == 2) {
      // Récupérer l'item du serveur avant de lancer l'animation
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .ouvrirCoffre("legendaire")
          .then((item) {
        if (item != null) {
          setState(() {
            selectedItemProfilGold = item;
          });

          // Lancer l'animation une fois l'item mis à jour
          _controller2.forward();
        } else {
          print("Aucun item reçu du serveur");
        }
      }).catchError((error) {
        print("Erreur lors de l'ouverture du coffre : $error");
      });

      _logoController2.forward();
    }
    if (index == 3) {
      // Récupérer l'item du serveur avant de lancer l'animation
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .ouvrirEnveloppe("commun")
          .then((item) {
        if (item != null) {
          setState(() {
            selectedItemBanniereBronze = item;
          });

          // Lancer l'animation une fois l'item mis à jour
          _controller3.forward();
        } else {
          print("Aucun item reçu du serveur");
        }
      }).catchError((error) {
        print("Erreur lors de l'ouverture du coffre : $error");
      });

      _logoController3.forward();
    }
    if (index == 4) {
      // Récupérer l'item du serveur avant de lancer l'animation
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .ouvrirEnveloppe("rare")
          .then((item) {
        if (item != null) {
          setState(() {
            selectedItemBanniereSilver = item;
          });

          // Lancer l'animation une fois l'item mis à jour
          _controller4.forward();
        } else {
          print("Aucun item reçu du serveur");
        }
      }).catchError((error) {
        print("Erreur lors de l'ouverture du coffre : $error");
      });

      _logoController4.forward();
    }
    if (index == 5) {
      // Récupérer l'item du serveur avant de lancer l'animation
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .ouvrirEnveloppe("legendaire")
          .then((item) {
        if (item != null) {
          setState(() {
            selectedItemBanniereGold = item;
          });

          // Lancer l'animation une fois l'item mis à jour
          _controller5.forward();
        } else {
          print("Aucun item reçu du serveur");
        }
      }).catchError((error) {
        print("Erreur lors de l'ouverture du coffre : $error");
      });

      _logoController5.forward();
    }
    // Réactiver le bouton après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isButtonDisabled = false; // Réactive le bouton
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadSelectedItems();
    getDataChestScreen();
    _tabController = TabController(length: _tabsTitres.length, vsync: this);
    _chargerProfils();
    _chargerBannieres();
    // Pour animation ouverture
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller4 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller5 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _animation1 = Tween<double>(begin: 1.0, end: 0.0).animate(_controller1);
    _animation2 = Tween<double>(begin: 1.0, end: 0.0).animate(_controller2);
    _animation3 = Tween<double>(begin: 1.0, end: 0.0).animate(_controller3);
    _animation4 = Tween<double>(begin: 1.0, end: 0.0).animate(_controller4);
    _animation5 = Tween<double>(begin: 1.0, end: 0.0).animate(_controller5);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoController3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoController4 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoController5 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_logoController);
    _logoAnimation1 =
        Tween<double>(begin: 1.0, end: 0.0).animate(_logoController1);
    _logoAnimation2 =
        Tween<double>(begin: 1.0, end: 0.0).animate(_logoController2);
    _logoAnimation3 =
        Tween<double>(begin: 1.0, end: 0.0).animate(_logoController3);
    _logoAnimation4 =
        Tween<double>(begin: 1.0, end: 0.0).animate(_logoController4);
    _logoAnimation5 =
        Tween<double>(begin: 1.0, end: 0.0).animate(_logoController5);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Affiche le dialogue à la fin de l'animation
        _showMyDialog(selectedItem);
        _controller.reset();
        _logoController.reset();
      }
    });

    _controller1.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Affiche le dialogue à la fin de l'animation
        _showMyDialog(selectedItemProfilSilver);
        _controller1.reset();
        _logoController1.reset();
      }
    });

    _controller2.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Affiche le dialogue à la fin de l'animation
        _showMyDialog(selectedItemProfilGold);
        _controller2.reset();
        _logoController2.reset();
      }
    });

    _controller3.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Affiche le dialogue à la fin de l'animation
        _showMyDialog(selectedItemBanniereBronze);
        _controller3.reset();
        _logoController3.reset();
      }
    });

    _controller4.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Affiche le dialogue à la fin de l'animation
        _showMyDialog(selectedItemBanniereSilver);
        print(selectedItemBanniereSilver?.type);
        _controller4.reset();
        _logoController4.reset();
      }
    });

    _controller5.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Affiche le dialogue à la fin de l'animation
        _showMyDialog(selectedItemBanniereGold);
        _controller5.reset();
        _logoController5.reset();
      }
    });

    // Créer les contrôleurs d'animation
    _controllerAme1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controllerAme2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controllerAme3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void _chargerProfils() async {
    var listesProfils = await getListeProfils();
    if (listesProfils != null) {
      setState(() {
        profilOP = listesProfils['listeProfilOnePiece'] ?? [];
        profilNaruto = listesProfils['listeProfilNaruto'] ?? [];
        profilMHA = listesProfils['listeProfilMHA'] ?? [];
      });
    }
  }

  void _chargerBannieres() async {
    var listesBannieres = await getListeBannieres();
    if (listesBannieres != null) {
      setState(() {
        banniereOP = listesBannieres['listeBanniereOnePiece'] ?? [];
        banniereSNK = listesBannieres['listeBanniereNaruto'] ?? [];
        banniereMHA = listesBannieres['listeBanniereMHA'] ?? [];
      });
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    getDataChestScreen();
  }

  void loadSelectedItems() {
    setState(() {
      selectedItem = Item(
        name: 'defaultBronze',
        number: 1,
        type: ItemType.profil,
        rarity: ItemRarity.commun,
        imageUrl: 'assets/images/profil/luffy.png',
        oeuvre: ItemOeuvre.onePiece,
      );

      selectedItemProfilSilver = Item(
        name: 'defaultSilver',
        number: 1,
        type: ItemType.profil,
        rarity: ItemRarity.rare,
        imageUrl: 'assets/images/profil/luffy.png',
        oeuvre: ItemOeuvre.onePiece,
      );

      selectedItemProfilGold = Item(
        name: 'defaultGold',
        number: 1,
        type: ItemType.profil,
        rarity: ItemRarity.legendaire,
        imageUrl: 'assets/images/profil/luffy.png',
        oeuvre: ItemOeuvre.onePiece,
      );

      selectedItemBanniereBronze = Item(
        name: 'defaultBannerBronze',
        number: 1,
        type: ItemType.banniere,
        rarity: ItemRarity.commun,
        imageUrl: 'assets/images/laboonBanner.png',
        oeuvre: ItemOeuvre.onePiece,
      );

      selectedItemBanniereSilver = Item(
        name: 'defaultBannerSilver',
        number: 1,
        type: ItemType.banniere,
        rarity: ItemRarity.rare,
        imageUrl: 'assets/images/laboonBanner.png',
        oeuvre: ItemOeuvre.onePiece,
      );

      selectedItemBanniereGold = Item(
        name: 'defaultBannerGold',
        number: 1,
        type: ItemType.banniere,
        rarity: ItemRarity.legendaire,
        imageUrl: 'assets/images/laboonBanner.png',
        oeuvre: ItemOeuvre.onePiece,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Nécessaire pour AutomaticKeepAliveClientMixin
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: fondNotifier,
          builder: (context, String fondActuel, child) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      fondActuel), // Assurez-vous que cette image est correctement référencée
                  fit: BoxFit.cover,
                ),
              ),
              child: DefaultTabController(
                length: _tabsTitres.length,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 5.h),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        color: couleurBoutons,
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      height: 8.h,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                        width: 98.w,
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
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.w)),
                          ),
                          height: 6.h,
                          child: TabBar(
                              controller: _tabController,
                              indicatorColor: couleurBoutons,
                              indicatorWeight: 1.w,
                              indicatorSize: TabBarIndicatorSize.label,
                              tabs: _tabsTitres
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
                              onTap: (index) {
                                fondNotifier.value = (index == 1)
                                    ? 'assets/images/Bar_Color.webp'
                                    : fondPrincipal4;
                              }),
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                          stream: usersCollection
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const Text("ERREUR");
                            }

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text("ERREUR");
                            }

                            // Ici, vous devez décomposer les données du snapshot pour mettre à jour l'interface utilisateur
                            Map<String, dynamic> data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            // Mise à jour des variables à partir des données Firestore
                            coffreCommun.nbExemplaire =
                                data['nbCoffreCommun'] ?? 0;
                            coffreRare.nbExemplaire = data['nbCoffreRare'] ?? 0;
                            coffreLeg.nbExemplaire =
                                data['nbCoffreLegendaire'] ?? 0;
                            enveloppeCommune.nbExemplaire =
                                data['nbLettreCommun'] ?? 0;
                            enveloppeRare.nbExemplaire =
                                data['nbLettreRare'] ?? 0;
                            enveloppeLeg.nbExemplaire =
                                data['nbLettreLegendaire'] ?? 0;

                            return TabBarView(
                              controller: _tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: <Widget>[
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 4.w),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () async {
                                            List<Item> itemsCommun =
                                                await getItemsCommun();
                                            List<Item> itemsRare =
                                                await getItemsRare();
                                            List<Item> itemsLegendaire =
                                                await getItemsLegendaire();

                                            itemsObtenableDialogue(
                                                context,
                                                itemsCommun,
                                                itemsRare,
                                                itemsLegendaire);
                                          },
                                          child: ItemsObtenable(),
                                        ),
                                      ),
                                    ),
                                    if (coffreCommun.nbExemplaire > 0 ||
                                        coffreRare.nbExemplaire > 0 ||
                                        coffreLeg.nbExemplaire > 0 ||
                                        enveloppeCommune.nbExemplaire > 0 ||
                                        enveloppeRare.nbExemplaire > 0 ||
                                        enveloppeLeg.nbExemplaire > 0)
                                      Container(
                                        padding: EdgeInsets.only(top: 1.h),
                                        alignment: Alignment.center,
                                        child: CarouselSlider(
                                          options: CarouselOptions(
                                            enableInfiniteScroll: false,
                                            height: 70.h,
                                            viewportFraction: 0.65,
                                            enlargeCenterPage: true,
                                          ),
                                          items: <Widget>[
                                            if (coffreCommun.nbExemplaire > 0)
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.w),
                                                        color: Colors.brown,
                                                      ),
                                                      height: 55,
                                                      child: Container(
                                                        width: 350,
                                                        height: 45.h,
                                                        decoration:
                                                            const BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xff151692),
                                                              spreadRadius: 0,
                                                              blurRadius: 20.0,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child:
                                                              AnimatedTextKit(
                                                            repeatForever: true,
                                                            pause:
                                                                const Duration(
                                                                    milliseconds:
                                                                        5),
                                                            animatedTexts: [
                                                              ColorizeAnimatedText(
                                                                "Item de bronze"
                                                                    .toUpperCase(),
                                                                textStyle:
                                                                    colorizeTextStyle,
                                                                colors:
                                                                    bronzeColors,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 8.h,
                                                    ),
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (!isButtonDisabled) {
                                                            _onTap(0);
                                                          }
                                                        },
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            // Image de Zoro qui devient progressivement visible
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        10,
                                                                    blurRadius:
                                                                        10,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ClipOval(
                                                                child:
                                                                    Image.asset(
                                                                  selectedItem!
                                                                      .imageUrl,
                                                                  width: 200,
                                                                  height: 200,
                                                                ),
                                                              ),
                                                            ),
                                                            // Cercle bleu avec effet shimmer qui disparaît progressivement
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _animation,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _animation
                                                                          .value,
                                                                  child: Shimmer
                                                                      .fromColors(
                                                                    baseColor:
                                                                        Colors
                                                                            .brown,
                                                                    highlightColor:
                                                                        Colors.brown[
                                                                            300]!,
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          200,
                                                                      height:
                                                                          200,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Colors
                                                                            .blue,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.green,
                                                                          width:
                                                                              50,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Bordure qui disparaît à la même vitesse que l'image logo
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    width:
                                                                        204, // Ajusté pour inclure la bordure
                                                                    height:
                                                                        204, // Ajusté pour inclure la bordure
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .brown[700]!,
                                                                        width:
                                                                            3,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Image au centre avec effet d'ombre qui disparaît deux fois plus vite que le cercle bleu
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.2),
                                                                          spreadRadius:
                                                                              2,
                                                                          blurRadius:
                                                                              30,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/logo.png',
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2.w),
                                                        color: Colors.brown,
                                                      ),
                                                      height: 50,
                                                      width: 50,
                                                      child: Center(
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    10.0,
                                                              ),
                                                            ],
                                                          ),
                                                          height: 40,
                                                          width: 40,
                                                          child: Center(
                                                            child: Text(
                                                              coffreCommun
                                                                  .nbExemplaire
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            top: 2.h),
                                                        height: 16.h,
                                                        width: 90.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.w),
                                                          color: Colors.brown,
                                                        ),
                                                        child: Container(
                                                          height: 14.h,
                                                          width: 87.w,
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    20.0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              AnimatedTextKit(
                                                                repeatForever:
                                                                    true,
                                                                pause: const Duration(
                                                                    milliseconds:
                                                                        5),
                                                                animatedTexts: [
                                                                  ColorizeAnimatedText(
                                                                    "Taux de drop"
                                                                        .toUpperCase(),
                                                                    textStyle:
                                                                        colorizeTextStyleDrop,
                                                                    colors:
                                                                        bronzeColors,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "80% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.brown,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item commun",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "15% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item rare          ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "5% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.yellow,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                          text:
                                                                              "de chance d'avoir un item légendaire",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                13,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            if (coffreRare.nbExemplaire > 0)
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.w),
                                                        color: Colors.grey,
                                                      ),
                                                      height: 55,
                                                      child: Container(
                                                        width: 350,
                                                        height: 45,
                                                        decoration:
                                                            const BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xff151692),
                                                              spreadRadius: 0,
                                                              blurRadius: 20.0,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child:
                                                              AnimatedTextKit(
                                                            repeatForever: true,
                                                            pause:
                                                                const Duration(
                                                                    milliseconds:
                                                                        5),
                                                            animatedTexts: [
                                                              ColorizeAnimatedText(
                                                                "Item d'argent"
                                                                    .toUpperCase(),
                                                                textStyle:
                                                                    colorizeTextStyle,
                                                                colors:
                                                                    silverColors,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 8.h,
                                                    ),
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (!isButtonDisabled) {
                                                            _onTap(1);
                                                          }
                                                        },
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            // Image de Zoro qui devient progressivement visible
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        10,
                                                                    blurRadius:
                                                                        10,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ClipOval(
                                                                child:
                                                                    Image.asset(
                                                                  selectedItemProfilSilver!
                                                                      .imageUrl,
                                                                  width: 200,
                                                                  height: 200,
                                                                ),
                                                              ),
                                                            ),
                                                            // Cercle bleu avec effet shimmer qui disparaît progressivement
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _animation1,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _animation1
                                                                          .value,
                                                                  child: Shimmer
                                                                      .fromColors(
                                                                    baseColor:
                                                                        Colors
                                                                            .grey,
                                                                    highlightColor:
                                                                        Colors.grey[
                                                                            300]!,
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          200,
                                                                      height:
                                                                          200,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Colors
                                                                            .blue,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.green,
                                                                          width:
                                                                              50,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Bordure qui disparaît à la même vitesse que l'image logo
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation1,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation1
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    width:
                                                                        204, // Ajusté pour inclure la bordure
                                                                    height:
                                                                        204, // Ajusté pour inclure la bordure
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .grey[700]!,
                                                                        width:
                                                                            3,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Image au centre avec effet d'ombre qui disparaît deux fois plus vite que le cercle bleu
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation1,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation1
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.2),
                                                                          spreadRadius:
                                                                              2,
                                                                          blurRadius:
                                                                              30,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/logo.png',
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2.w),
                                                        color: Colors.grey,
                                                      ),
                                                      height: 50,
                                                      width: 50,
                                                      child: Center(
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    10.0,
                                                              ),
                                                            ],
                                                          ),
                                                          height: 40,
                                                          width: 40,
                                                          child: Center(
                                                            child: Text(
                                                              coffreRare
                                                                  .nbExemplaire
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            top: 2.h),
                                                        height: 16.h,
                                                        width: 90.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.w),
                                                          color: Colors.grey,
                                                        ),
                                                        child: Container(
                                                          height: 14.h,
                                                          width: 87.w,
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    20.0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              AnimatedTextKit(
                                                                repeatForever:
                                                                    true,
                                                                pause: const Duration(
                                                                    milliseconds:
                                                                        5),
                                                                animatedTexts: [
                                                                  ColorizeAnimatedText(
                                                                    "Taux de drop"
                                                                        .toUpperCase(),
                                                                    textStyle:
                                                                        colorizeTextStyleDrop,
                                                                    colors:
                                                                        silverColors,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "40% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.brown,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item commun",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "50% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item rare          ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "10% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.yellow,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                          text:
                                                                              "de chance d'avoir un item légendaire",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                13,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            if (coffreLeg.nbExemplaire > 0)
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.w),
                                                        color: const Color(
                                                            0xffffdc73),
                                                      ),
                                                      height: 55,
                                                      child: Container(
                                                        width: 350,
                                                        height: 45,
                                                        decoration:
                                                            const BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xff151692),
                                                              spreadRadius: 0,
                                                              blurRadius: 20.0,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child:
                                                              AnimatedTextKit(
                                                            repeatForever: true,
                                                            pause:
                                                                const Duration(
                                                                    milliseconds:
                                                                        5),
                                                            animatedTexts: [
                                                              ColorizeAnimatedText(
                                                                "Item d'or"
                                                                    .toUpperCase(),
                                                                textStyle:
                                                                    colorizeTextStyle,
                                                                colors:
                                                                    goldColors,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 8.h,
                                                    ),
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (!isButtonDisabled) {
                                                            _onTap(2);
                                                          }
                                                        },
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            // Image de Zoro qui devient progressivement visible
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        10,
                                                                    blurRadius:
                                                                        10,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ClipOval(
                                                                child:
                                                                    Image.asset(
                                                                  selectedItemProfilGold!
                                                                      .imageUrl,
                                                                  width: 200,
                                                                  height: 200,
                                                                ),
                                                              ),
                                                            ),
                                                            // Cercle bleu avec effet shimmer qui disparaît progressivement
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _animation2,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _animation2
                                                                          .value,
                                                                  child: Shimmer
                                                                      .fromColors(
                                                                    baseColor:
                                                                        const Color(
                                                                            0xffffbf00),
                                                                    highlightColor:
                                                                        const Color(
                                                                            0xffffdc73),
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          200,
                                                                      height:
                                                                          200,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Colors
                                                                            .blue,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.green,
                                                                          width:
                                                                              50,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Bordure qui disparaît à la même vitesse que l'image logo
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation2,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation2
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    width:
                                                                        204, // Ajusté pour inclure la bordure
                                                                    height:
                                                                        204, // Ajusté pour inclure la bordure
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .yellow,
                                                                        width:
                                                                            3,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Image au centre avec effet d'ombre qui disparaît deux fois plus vite que le cercle bleu
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation2,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation2
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.2),
                                                                          spreadRadius:
                                                                              2,
                                                                          blurRadius:
                                                                              30,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/logo.png',
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2.w),
                                                        color: const Color(
                                                            0xffffdc73),
                                                      ),
                                                      height: 50,
                                                      width: 50,
                                                      child: Center(
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    10.0,
                                                              ),
                                                            ],
                                                          ),
                                                          height: 40,
                                                          width: 40,
                                                          child: Center(
                                                            child: Text(
                                                              coffreLeg
                                                                  .nbExemplaire
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            top: 2.h),
                                                        height: 16.h,
                                                        width: 90.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.w),
                                                          color: Colors.yellow,
                                                        ),
                                                        child: Container(
                                                          height: 14.h,
                                                          width: 87.w,
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    20.0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              AnimatedTextKit(
                                                                repeatForever:
                                                                    true,
                                                                pause: const Duration(
                                                                    milliseconds:
                                                                        5),
                                                                animatedTexts: [
                                                                  ColorizeAnimatedText(
                                                                    "Taux de drop"
                                                                        .toUpperCase(),
                                                                    textStyle:
                                                                        colorizeTextStyleDrop,
                                                                    colors:
                                                                        goldColors,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "10% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.brown,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item commun",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "45% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item rare          ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "45% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.yellow,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                          text:
                                                                              "de chance d'avoir un item légendaire",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                13,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            if (enveloppeCommune.nbExemplaire >
                                                0)
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.w),
                                                        color: Colors.brown,
                                                      ),
                                                      height: 55,
                                                      child: Container(
                                                        width: 350,
                                                        height: 45,
                                                        decoration:
                                                            const BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xff151692),
                                                              spreadRadius: 0,
                                                              blurRadius: 20.0,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child:
                                                              AnimatedTextKit(
                                                            repeatForever: true,
                                                            pause:
                                                                const Duration(
                                                                    milliseconds:
                                                                        5),
                                                            animatedTexts: [
                                                              ColorizeAnimatedText(
                                                                "Item de bronze"
                                                                    .toUpperCase(),
                                                                textStyle:
                                                                    colorizeTextStyle,
                                                                colors:
                                                                    bronzeColors,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 8.h,
                                                    ),
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (!isButtonDisabled) {
                                                            _onTap(3);
                                                          }
                                                        },
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            // Image de Zoro qui devient progressivement visible
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .rectangle, // Remplace le cercle par un rectangle
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50), // Coins arrondis
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        8,
                                                                    blurRadius:
                                                                        10,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20), // Coins arrondis pour l'image
                                                                child:
                                                                    Image.asset(
                                                                  selectedItemBanniereBronze!
                                                                      .imageUrl,
                                                                  width: 280,
                                                                  height: 100,
                                                                  fit: BoxFit
                                                                      .fill, // Ajustement de l'image
                                                                ),
                                                              ),
                                                            ),
                                                            // Rectangle avec effet shimmer qui disparaît progressivement
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _animation3,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _animation3
                                                                          .value,
                                                                  child: Shimmer
                                                                      .fromColors(
                                                                    baseColor:
                                                                        Colors
                                                                            .brown,
                                                                    highlightColor:
                                                                        Colors.brown[
                                                                            300]!,
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          280,
                                                                      height:
                                                                          105,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .rectangle, // Rectangle
                                                                        borderRadius:
                                                                            BorderRadius.circular(50), // Coins arrondis
                                                                        color: Colors
                                                                            .blue,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.green,
                                                                          width:
                                                                              50,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Bordure qui disparaît à la même vitesse que l'image logo
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation3,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation3
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    width: 280,
                                                                    height: 105,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .rectangle, // Rectangle
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50), // Coins arrondis
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .brown[700]!,
                                                                        width:
                                                                            3,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Image au centre avec effet d'ombre qui disparaît deux fois plus vite que le rectangle
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation3,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation3
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.2),
                                                                          spreadRadius:
                                                                              2,
                                                                          blurRadius:
                                                                              30,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/logo.png',
                                                                      width: 75,
                                                                      height:
                                                                          75,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2.w),
                                                        color: Colors.brown,
                                                      ),
                                                      height: 50,
                                                      width: 50,
                                                      child: Center(
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    10.0,
                                                              ),
                                                            ],
                                                          ),
                                                          height: 40,
                                                          width: 40,
                                                          child: Center(
                                                            child: Text(
                                                              enveloppeCommune
                                                                  .nbExemplaire
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 30,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            top: 2.h),
                                                        height: 16.h,
                                                        width: 90.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.w),
                                                          color: Colors.brown,
                                                        ),
                                                        child: Container(
                                                          height: 14.h,
                                                          width: 87.w,
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    20.0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              AnimatedTextKit(
                                                                repeatForever:
                                                                    true,
                                                                pause: const Duration(
                                                                    milliseconds:
                                                                        5),
                                                                animatedTexts: [
                                                                  ColorizeAnimatedText(
                                                                    "Taux de drop"
                                                                        .toUpperCase(),
                                                                    textStyle:
                                                                        colorizeTextStyleDrop,
                                                                    colors:
                                                                        bronzeColors,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "80% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.brown,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item commun",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "15% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item rare          ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "5% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.yellow,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                          text:
                                                                              "de chance d'avoir un item légendaire",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                13,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            if (enveloppeRare.nbExemplaire > 0)
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.w),
                                                        color: Colors.grey,
                                                      ),
                                                      height: 55,
                                                      child: Container(
                                                        width: 350,
                                                        height: 45,
                                                        decoration:
                                                            const BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xff151692),
                                                              spreadRadius: 0,
                                                              blurRadius: 20.0,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child:
                                                              AnimatedTextKit(
                                                            repeatForever: true,
                                                            pause:
                                                                const Duration(
                                                                    milliseconds:
                                                                        5),
                                                            animatedTexts: [
                                                              ColorizeAnimatedText(
                                                                "Item d'argent"
                                                                    .toUpperCase(),
                                                                textStyle:
                                                                    colorizeTextStyle,
                                                                colors:
                                                                    silverColors,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 8.h,
                                                    ),
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (!isButtonDisabled) {
                                                            _onTap(4);
                                                          }
                                                        },
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            // Image de Zoro qui devient progressivement visible
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .rectangle, // Remplace le cercle par un rectangle
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50), // Coins arrondis
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        8,
                                                                    blurRadius:
                                                                        10,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20), // Coins arrondis pour l'image
                                                                child:
                                                                    Image.asset(
                                                                  selectedItemBanniereSilver!
                                                                      .imageUrl,
                                                                  width: 280,
                                                                  height: 100,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                            ),
                                                            // Rectangle avec effet shimmer qui disparaît progressivement
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _animation4,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _animation4
                                                                          .value,
                                                                  child: Shimmer
                                                                      .fromColors(
                                                                    baseColor:
                                                                        Colors
                                                                            .grey,
                                                                    highlightColor:
                                                                        Colors.grey[
                                                                            300]!,
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          280,
                                                                      height:
                                                                          105,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .rectangle, // Rectangle
                                                                        borderRadius:
                                                                            BorderRadius.circular(50), // Coins arrondis
                                                                        color: Colors
                                                                            .blue,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.green,
                                                                          width:
                                                                              50,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Bordure qui disparaît à la même vitesse que l'image logo
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation4,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation4
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    width: 280,
                                                                    height: 105,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .rectangle, // Rectangle
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50), // Coins arrondis
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .grey[700]!,
                                                                        width:
                                                                            3,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Image au centre avec effet d'ombre qui disparaît deux fois plus vite que le rectangle
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation4,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation4
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.2),
                                                                          spreadRadius:
                                                                              2,
                                                                          blurRadius:
                                                                              30,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/logo.png',
                                                                      width: 75,
                                                                      height:
                                                                          75,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2.w),
                                                        color: Colors.grey,
                                                      ),
                                                      height: 50,
                                                      width: 50,
                                                      child: Center(
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    10.0,
                                                              ),
                                                            ],
                                                          ),
                                                          height: 40,
                                                          width: 40,
                                                          child: Center(
                                                            child: Text(
                                                              enveloppeRare
                                                                  .nbExemplaire
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 30,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            top: 2.h),
                                                        height: 16.h,
                                                        width: 90.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.w),
                                                          color: Colors.grey,
                                                        ),
                                                        child: Container(
                                                          height: 14.h,
                                                          width: 87.w,
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    20.0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              AnimatedTextKit(
                                                                repeatForever:
                                                                    true,
                                                                pause: const Duration(
                                                                    milliseconds:
                                                                        5),
                                                                animatedTexts: [
                                                                  ColorizeAnimatedText(
                                                                    "Taux de drop"
                                                                        .toUpperCase(),
                                                                    textStyle:
                                                                        colorizeTextStyleDrop,
                                                                    colors:
                                                                        silverColors,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "40% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.brown,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item commun",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "50% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item rare          ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "10% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.yellow,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                          text:
                                                                              "de chance d'avoir un item légendaire",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                13,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            if (enveloppeLeg.nbExemplaire > 0)
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.w),
                                                        color: const Color(
                                                            0xffffdc73),
                                                      ),
                                                      height: 55,
                                                      child: Container(
                                                        width: 350,
                                                        height: 45,
                                                        decoration:
                                                            const BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Color(
                                                                  0xff151692),
                                                              spreadRadius: 0,
                                                              blurRadius: 20.0,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child:
                                                              AnimatedTextKit(
                                                            repeatForever: true,
                                                            pause:
                                                                const Duration(
                                                                    milliseconds:
                                                                        5),
                                                            animatedTexts: [
                                                              ColorizeAnimatedText(
                                                                "Item d'or"
                                                                    .toUpperCase(),
                                                                textStyle:
                                                                    colorizeTextStyle,
                                                                colors:
                                                                    goldColors,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 8.h,
                                                    ),
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (!isButtonDisabled) {
                                                            _onTap(5);
                                                          }
                                                        },
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            // Image de Zoro qui devient progressivement visible
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .rectangle, // Remplace le cercle par un rectangle
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50), // Coins arrondis
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        8,
                                                                    blurRadius:
                                                                        10,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20), // Coins arrondis pour l'image
                                                                child:
                                                                    Image.asset(
                                                                  selectedItemBanniereGold!
                                                                      .imageUrl,
                                                                  width: 280,
                                                                  height: 100,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                            ),
                                                            // Rectangle avec effet shimmer qui disparaît progressivement
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _animation5,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _animation5
                                                                          .value,
                                                                  child: Shimmer
                                                                      .fromColors(
                                                                    baseColor:
                                                                        const Color(
                                                                            0xffffbf00),
                                                                    highlightColor:
                                                                        const Color(
                                                                            0xffffdc73),
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          280,
                                                                      height:
                                                                          105,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .rectangle, // Rectangle
                                                                        borderRadius:
                                                                            BorderRadius.circular(50), // Coins arrondis
                                                                        color: Colors
                                                                            .blue,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.green,
                                                                          width:
                                                                              50,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Bordure qui disparaît à la même vitesse que l'image logo
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation5,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation5
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    width: 280,
                                                                    height: 105,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .rectangle, // Rectangle
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50), // Coins arrondis
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .yellow,
                                                                        width:
                                                                            3,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // Image au centre avec effet d'ombre qui disparaît deux fois plus vite que le rectangle
                                                            AnimatedBuilder(
                                                              animation:
                                                                  _logoAnimation5,
                                                              builder: (context,
                                                                  child) {
                                                                return Opacity(
                                                                  opacity:
                                                                      _logoAnimation5
                                                                          .value,
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.2),
                                                                          spreadRadius:
                                                                              2,
                                                                          blurRadius:
                                                                              30,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/logo.png',
                                                                      width: 75,
                                                                      height:
                                                                          75,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      2.w),
                                                          color: const Color(
                                                              0xffffdc73)),
                                                      height: 50,
                                                      width: 50,
                                                      child: Center(
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    10.0,
                                                              ),
                                                            ],
                                                          ),
                                                          height: 40,
                                                          width: 40,
                                                          child: Center(
                                                            child: Text(
                                                              enveloppeLeg
                                                                  .nbExemplaire
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 30,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            top: 2.h),
                                                        height: 16.h,
                                                        width: 90.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.w),
                                                          color: Colors.yellow,
                                                        ),
                                                        child: Container(
                                                          height: 14.h,
                                                          width: 87.w,
                                                          decoration:
                                                              const BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0xff151692),
                                                                spreadRadius: 0,
                                                                blurRadius:
                                                                    20.0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              AnimatedTextKit(
                                                                repeatForever:
                                                                    true,
                                                                pause: const Duration(
                                                                    milliseconds:
                                                                        5),
                                                                animatedTexts: [
                                                                  ColorizeAnimatedText(
                                                                    "Taux de drop"
                                                                        .toUpperCase(),
                                                                    textStyle:
                                                                        colorizeTextStyleDrop,
                                                                    colors:
                                                                        goldColors,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "10% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.brown,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item commun",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "45% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "de chance d'avoir un item rare          ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 13),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 3
                                                                            .w),
                                                                child: RichText(
                                                                  text:
                                                                      const TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "45% ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.yellow,
                                                                            fontSize: 13),
                                                                      ),
                                                                      TextSpan(
                                                                          text:
                                                                              "de chance d'avoir un item légendaire",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                13,
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    if (coffreCommun.nbExemplaire == 0 &&
                                        coffreRare.nbExemplaire == 0 &&
                                        coffreLeg.nbExemplaire == 0 &&
                                        enveloppeCommune.nbExemplaire == 0 &&
                                        enveloppeRare.nbExemplaire == 0 &&
                                        enveloppeLeg.nbExemplaire == 0)
                                      Container(
                                        height: 35.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: const Color(0xff151692),
                                          border: Border.all(
                                            color: couleurBoutons,
                                            width: 3, // Une bordure fine
                                          ),
                                        ),
                                        margin: EdgeInsets.only(
                                            top: 16.h, right: 5.w, left: 5.w),
                                        alignment: Alignment.center,
                                        child: const Center(
                                          child: Text(
                                            "Pas d'item à ouvrir :(",
                                            style: TextStyle(
                                                fontSize: 30,
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Stack(
                                      children: [
                                        if (_showImages) ...[
                                          Positioned(
                                            top: 200, // Positionnement vertical
                                            left:
                                                100, // Positionnement horizontal
                                            child: AnimatedBuilder(
                                              animation: _controllerAme1,
                                              builder: (context, child) {
                                                return Opacity(
                                                  opacity:
                                                      _controllerAme1.value,
                                                  child: Image.asset(
                                                    'assets/images/ame4.png',
                                                    width: 100,
                                                    height: 100,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 250, // Positionnement vertical
                                            left:
                                                150, // Positionnement horizontal
                                            child: AnimatedBuilder(
                                              animation: _controllerAme2,
                                              builder: (context, child) {
                                                return Opacity(
                                                  opacity:
                                                      _controllerAme2.value,
                                                  child: Image.asset(
                                                    'assets/images/ame4.png',
                                                    width: 150,
                                                    height: 150,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 300, // Positionnement vertical
                                            left:
                                                100, // Positionnement horizontal
                                            child: AnimatedBuilder(
                                              animation: _controllerAme3,
                                              builder: (context, child) {
                                                return Opacity(
                                                  opacity:
                                                      _controllerAme3.value,
                                                  child: Image.asset(
                                                    'assets/images/ame4.png',
                                                    width: 120,
                                                    height: 120,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                        Positioned(
                                            top: 10, // Positionnement vertical
                                            right: 20,
                                            child: nbAmes2()),
                                        Container(
                                          margin: EdgeInsets.only(top: 54.h),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  if (aSelectionnerProfil ||
                                                      aSelectionnerBanniere) {
                                                    setState(
                                                      () {
                                                        aSelectionnerProfil =
                                                            false;
                                                        aSelectionnerBanniere =
                                                            false;
                                                        profilChoisi = false;
                                                        banniereChoisi = false;
                                                        banniereSelectionne =
                                                            null;
                                                        profilSelectionne =
                                                            null;
                                                        valeurVente = 0;
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  width: 30.w,
                                                  height: 7.h,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.w),
                                                    color: couleurBoutons,
                                                  ),
                                                  child: Container(
                                                    width: 28.w,
                                                    height: 7.h,
                                                    decoration:
                                                        const BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              Color(0xff151692),
                                                          spreadRadius: 0,
                                                          blurRadius: 20.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Annuler".toUpperCase(),
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          color:
                                                              Color(0xff17c983),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                child: profilChoisi ||
                                                        banniereChoisi
                                                    ? _buildVente()
                                                    : _buildSpace(),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  if (aSelectionnerProfil ||
                                                      aSelectionnerBanniere) {
                                                    try {
                                                      // Lancer les animations d'apparition puis de disparition
                                                      _controllerAme1.forward();
                                                      Timer(
                                                          const Duration(
                                                              milliseconds:
                                                                  500),
                                                          () => _controllerAme2
                                                              .forward());
                                                      Timer(
                                                          const Duration(
                                                              milliseconds:
                                                                  1000),
                                                          () => _controllerAme3
                                                              .forward());

                                                      // Déclencher la disparition après l'apparition
                                                      Timer(
                                                          const Duration(
                                                              seconds: 2), () {
                                                        _controllerAme1
                                                            .reverse();
                                                        Timer(
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                            () =>
                                                                _controllerAme2
                                                                    .reverse());
                                                        Timer(
                                                            const Duration(
                                                                milliseconds:
                                                                    1000),
                                                            () =>
                                                                _controllerAme3
                                                                    .reverse());
                                                      });

                                                      // Cacher les images après la fin de l'animation
                                                      Timer(
                                                          const Duration(
                                                              seconds: 4), () {
                                                        setState(() {
                                                          _showImages = false;
                                                        });
                                                      });

                                                      // Vendre l'item
                                                      if (profilSelectionne
                                                              ?.type ==
                                                          ItemType.profil) {
                                                        await DatabaseService(
                                                                uid: FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                            .vendreItem(
                                                                profilSelectionne!);
                                                      }
                                                      if (banniereSelectionne
                                                              ?.type ==
                                                          ItemType.banniere) {
                                                        await DatabaseService(
                                                                uid: FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                            .vendreItem(
                                                                banniereSelectionne!);
                                                      }

                                                      // Après la vente, récupérer à nouveau les listes mises à jour
                                                      var listesProfils =
                                                          await getListeProfils();
                                                      var listesBannieres =
                                                          await getListeBannieres();

                                                      if (listesProfils !=
                                                              null &&
                                                          listesBannieres !=
                                                              null) {
                                                        setState(() {
                                                          _showImages = true;

                                                          // Pour réinitialiser liste de profils suite à la vente
                                                          if (aSelectionnerProfil) {
                                                            profilOP =
                                                                listesProfils[
                                                                        'listeProfilOnePiece'] ??
                                                                    [];
                                                            profilNaruto =
                                                                listesProfils[
                                                                        'listeProfilNaruto'] ??
                                                                    [];
                                                            profilMHA =
                                                                listesProfils[
                                                                        'listeProfilMHA'] ??
                                                                    [];
                                                          }
                                                          if (aSelectionnerBanniere) {
                                                            banniereOP =
                                                                listesBannieres[
                                                                        'listeBanniereOnePiece'] ??
                                                                    [];
                                                            banniereSNK =
                                                                listesBannieres[
                                                                        'listeBanniereNaruto'] ??
                                                                    [];
                                                            banniereMHA =
                                                                listesBannieres[
                                                                        'listeBanniereMHA'] ??
                                                                    [];
                                                          }

                                                          // Réinitialisation de l'état après la vente
                                                          aSelectionnerProfil =
                                                              false;
                                                          aSelectionnerBanniere =
                                                              false;
                                                          profilChoisi = false;
                                                          banniereChoisi =
                                                              false;
                                                          banniereSelectionne =
                                                              null;
                                                          profilSelectionne =
                                                              null;
                                                          valeurVente = 0;
                                                        });
                                                      }
                                                    } catch (error) {
                                                      print(
                                                          'Erreur lors de la vente ou du rafraîchissement: $error');
                                                      // Gérer les erreurs ici
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  width: 30.w,
                                                  height: 7.h,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.w),
                                                    color: couleurBoutons,
                                                  ),
                                                  child: Container(
                                                    width: 28.w,
                                                    height: 7.h,
                                                    decoration:
                                                        const BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              Color(0xff151692),
                                                          spreadRadius: 0,
                                                          blurRadius: 20.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Vendre".toUpperCase(),
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          color:
                                                              Color(0xff17c983),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 2.w, right: 2.w, top: 62.h),
                                          height: 120,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.w),
                                            color: couleurBoutons,
                                          ),
                                          child: Container(
                                            height: 120,
                                            decoration: const BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0xff151692),
                                                  spreadRadius: 0,
                                                  blurRadius: 20.0,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 6.w,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    if (!aSelectionnerBanniere) {
                                                      sellBanniereView(context);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 70,
                                                    width: 200,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey[
                                                            800]!, // Couleur gris foncé pour la bordure
                                                        width:
                                                            2, // Épaisseur de la bordure
                                                      ),
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  40)),
                                                    ),
                                                    child: Center(
                                                      child: banniereChoisi
                                                          ? _buildImageBanniere()
                                                          : _buildTextBanniere(),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 5.w),
                                                InkWell(
                                                  onTap: () {
                                                    if (!aSelectionnerProfil) {
                                                      sellProfilView(context);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 105,
                                                    width: 105,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey[
                                                            800]!, // Couleur gris foncé pour la bordure
                                                        width:
                                                            2, // Épaisseur de la bordure
                                                      ),
                                                      color: Colors.transparent,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: profilChoisi
                                                          ? _buildImageProfil()
                                                          : _buildTextProfil(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _buildImageProfil() {
    print("Building Image Widget");
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage(profilSelectionne!.imageUrl),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildTextProfil() {
    print("Building Text Widget");
    return const Text(
      'Appuie ici pour vendre un profil',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Color(0xff777777),
      ),
    );
  }

  Widget _buildTextBanniere() {
    print("Building Text banniere Widget");
    return const Text(
      'Appuie ici pour vendre une banniere',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Color(0xff777777),
      ),
    );
  }

  Widget _buildImageBanniere() {
    print("Building Image banniere Widget");
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(banniereSelectionne!.imageUrl),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildVente() {
    print("Building Vente Widget");
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.w),
        color: couleurBoutons,
      ),
      child: Container(
        width: 90,
        height: 40,
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
          child: Column(
            children: [
              const SizedBox(
                height: 6,
              ),
              const Text(
                'Vendre pour ',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$valeurVente',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      'assets/images/ame5.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpace() {
    print("Building Space Widget");
    return const SizedBox(width: 100);
  }

  Future sellProfilView(BuildContext context) => showDialog(
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
                                    "Sélectionne un profil".toUpperCase(),
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
                          SizedBox(height: 2.h),
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 17,
                                ),
                                width: double.infinity,
                                height: 3,
                                color: couleurBoutons,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    color: const Color(0xff151692),
                                  ),
                                  width: 100,
                                  height: 35,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xff17c983),
                                          spreadRadius: 0,
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    width: 90,
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        'One piece'.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 280,
                              height: 100,
                              child: SizedBox(
                                height: 80,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(left: 5),
                                    itemCount: profilOP.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          String? imgUrlDuProfilActuel =
                                              await getProfilActuelUtilisateurCourant();
                                          if (imgUrlDuProfilActuel !=
                                              profilOP[index].imageUrl) {
                                            valeurVente +=
                                                sellValue(profilOP[index]);
                                            aSelectionnerProfil = true;
                                            profilSelectionne = profilOP[index];
                                            Navigator.pop(context);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Vous ne pouvez pas sélectionner votre profil actuel",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 0,
                                                backgroundColor: Colors.black,
                                                textColor: Colors.blue,
                                                fontSize: 16.0);
                                          }
                                        },
                                        child: Center(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                SizedBox(
                                                  width: 90,
                                                  height: 80,
                                                  child: Image.asset(
                                                    profilOP[index].imageUrl,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (profilOP[index].number > 1)
                                                  Positioned(
                                                    bottom: 5,
                                                    right: 5,
                                                    child: Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff151692), // You can change the color
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xff17c983),
                                                          width:
                                                              1, // Épaisseur de la bordure
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          profilOP[index]
                                                              .number
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .white, // Text color
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                    }),
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 17,
                                ),
                                width: double.infinity,
                                height: 3,
                                color: couleurBoutons,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    color: const Color(0xff151692),
                                  ),
                                  width: 170,
                                  height: 35,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xff17c983),
                                          spreadRadius: 0,
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    width: 160,
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        'Attaque des titans'.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 280,
                              height: 100,
                              child: SizedBox(
                                height: 80,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(left: 5),
                                    itemCount: profilNaruto.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          String? imgUrlDuProfilActuel =
                                              await getProfilActuelUtilisateurCourant();
                                          if (imgUrlDuProfilActuel !=
                                              profilNaruto[index].imageUrl) {
                                            valeurVente += sellValue(
                                              profilNaruto[index],
                                            );
                                            aSelectionnerProfil = true;
                                            profilSelectionne =
                                                profilNaruto[index];
                                            Navigator.pop(context);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Vous ne pouvez pas sélectionner votre profil actuel",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 0,
                                                backgroundColor: Colors.black,
                                                textColor: Colors.blue,
                                                fontSize: 16.0);
                                          }
                                        },
                                        child: Center(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                SizedBox(
                                                  width: 90,
                                                  height: 80,
                                                  child: Image.asset(
                                                    profilNaruto[index]
                                                        .imageUrl,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (profilNaruto[index].number >
                                                    1)
                                                  Positioned(
                                                    bottom: 5,
                                                    right: 5,
                                                    child: Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff151692), // You can change the color
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xff17c983),
                                                          width:
                                                              1, // Épaisseur de la bordure
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          profilNaruto[index]
                                                              .number
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .white, // Text color
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                    }),
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 17,
                                ),
                                width: double.infinity,
                                height: 3,
                                color: couleurBoutons,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    color: const Color(0xff151692),
                                  ),
                                  width: 170,
                                  height: 35,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xff17c983),
                                          spreadRadius: 0,
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    width: 160,
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        'My Hero Academia'.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 280,
                              height: 100,
                              child: SizedBox(
                                height: 80,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(left: 5),
                                    itemCount: profilMHA.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          String? imgUrlDuProfilActuel =
                                              await getProfilActuelUtilisateurCourant();
                                          if (imgUrlDuProfilActuel !=
                                              profilMHA[index].imageUrl) {
                                            valeurVente +=
                                                sellValue(profilMHA[index]);
                                            aSelectionnerProfil = true;
                                            profilSelectionne =
                                                profilMHA[index];
                                            Navigator.pop(context);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Vous ne pouvez pas sélectionner votre profil actuel",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 0,
                                                backgroundColor: Colors.black,
                                                textColor: Colors.blue,
                                                fontSize: 16.0);
                                          }
                                        },
                                        child: Center(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                SizedBox(
                                                  width: 90,
                                                  height: 80,
                                                  child: Image.asset(
                                                    profilMHA[index].imageUrl,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (profilMHA[index].number > 1)
                                                  Positioned(
                                                    bottom: 5,
                                                    right: 5,
                                                    child: Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff151692), // You can change the color
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xff17c983),
                                                          width:
                                                              1, // Épaisseur de la bordure
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          profilMHA[index]
                                                              .number
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .white, // Text color
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            },
          );
        },
      ).then((value) {
        if (aSelectionnerProfil) {
          setState(() {
            valeurVente;
            profilChoisi = true;
            profilSelectionne;
          });
        }
      });

  Future itemsObtenableDialogue(BuildContext context, List<Item> itemsCommun,
          List<Item> itemsRare, List<Item> itemsLegendaire) =>
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
                                    "Items disponibles".toUpperCase(),
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
                          SizedBox(height: 2.h),
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 17,
                                ),
                                width: double.infinity,
                                height: 3,
                                color: couleurBoutons,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    color: const Color(0xff151692),
                                  ),
                                  width: 100,
                                  height: 35,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xff17c983),
                                          spreadRadius: 0,
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    width: 90,
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        'Commun'.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 280,
                              height: 100,
                              child: SizedBox(
                                height: 80,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(left: 5),
                                    itemCount: itemsCommun.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (itemsCommun[index].type ==
                                          ItemType.profil) {
                                        return Container(
                                          margin: EdgeInsets.only(left: 2.w),
                                          width: 90,
                                          height: 80,
                                          child: Image.asset(
                                            itemsCommun[index].imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          margin: EdgeInsets.only(left: 2.w),
                                          width: 130,
                                          height: 120,
                                          child: Image.asset(
                                            itemsCommun[index].imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                      }
                                    }),
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 17,
                                ),
                                width: double.infinity,
                                height: 3,
                                color: couleurBoutons,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    color: const Color(0xff151692),
                                  ),
                                  width: 100,
                                  height: 35,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xff17c983),
                                          spreadRadius: 0,
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    width: 90,
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        'Rare'.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 280,
                              height: 100,
                              child: SizedBox(
                                height: 80,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(left: 5),
                                    itemCount: itemsRare.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (itemsRare[index].type ==
                                          ItemType.profil) {
                                        return Container(
                                          margin: EdgeInsets.only(left: 2.w),
                                          width: 90,
                                          height: 80,
                                          child: Image.asset(
                                            itemsRare[index].imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          margin: EdgeInsets.only(left: 2.w),
                                          width: 130,
                                          height: 120,
                                          child: Image.asset(
                                            itemsRare[index].imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                      }
                                    }),
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 17,
                                ),
                                width: double.infinity,
                                height: 3,
                                color: couleurBoutons,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    color: const Color(0xff151692),
                                  ),
                                  width: 160,
                                  height: 35,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xff17c983),
                                          spreadRadius: 0,
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    width: 135,
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        'Legendaire'.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 280,
                              height: 100,
                              child: SizedBox(
                                height: 80,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(left: 5),
                                    itemCount: itemsLegendaire.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (itemsLegendaire[index].type ==
                                          ItemType.profil) {
                                        return Container(
                                          margin: EdgeInsets.only(left: 2.w),
                                          width: 90,
                                          height: 80,
                                          child: Image.asset(
                                            itemsLegendaire[index].imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          margin: EdgeInsets.only(left: 2.w),
                                          width: 130,
                                          height: 120,
                                          child: Image.asset(
                                            itemsLegendaire[index].imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                      }
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            },
          );
        },
      ).then((value) {
        if (aSelectionnerProfil) {
          setState(() {
            valeurVente;
            profilChoisi = true;
            profilSelectionne;
          });
        }
      });

  Future sellBanniereView(BuildContext context) => showDialog(
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
                              onTap: () {
                                Navigator.pop(context);
                              },
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
                                    "Sélectionne une banniere".toUpperCase(),
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
                          SizedBox(height: 2.h),
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 17,
                                ),
                                width: double.infinity,
                                height: 3,
                                color: couleurBoutons,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    color: const Color(0xff151692),
                                  ),
                                  width: 100,
                                  height: 35,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xff17c983),
                                          spreadRadius: 0,
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    width: 90,
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        'One piece'.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 280,
                              height: 80,
                              child: SizedBox(
                                height: 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: banniereOP.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          String? imgUrlDeLaBanniereActuel =
                                              await getBanniereActuelUtilisateurCourant();
                                          print(imgUrlDeLaBanniereActuel);
                                          if (imgUrlDeLaBanniereActuel !=
                                              banniereOP[index].imageUrl) {
                                            valeurVente +=
                                                sellValue(banniereOP[index]);
                                            aSelectionnerBanniere = true;
                                            banniereSelectionne =
                                                banniereOP[index];
                                            Navigator.pop(context);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Vous ne pouvez pas sélectionner votre bannière actuelle",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 0,
                                                backgroundColor: Colors.black,
                                                textColor: Colors.blue,
                                                fontSize: 16.0);
                                          }
                                        },
                                        child: Center(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  width: 130,
                                                  height: 120,
                                                  child: Image.asset(
                                                    banniereOP[index].imageUrl,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (banniereOP[index].number >
                                                    1)
                                                  Positioned(
                                                    bottom: 10,
                                                    right: 0,
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff151692), // You can change the color
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xff17c983),
                                                          width:
                                                              1, // Épaisseur de la bordure
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          banniereOP[index]
                                                              .number
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .white, // Text color
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                    }),
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 17,
                                ),
                                width: double.infinity,
                                height: 3,
                                color: couleurBoutons,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    color: const Color(0xff151692),
                                  ),
                                  width: 170,
                                  height: 35,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xff17c983),
                                          spreadRadius: 0,
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    width: 160,
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        'Attaque des titans'.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 280,
                              height: 80,
                              child: SizedBox(
                                height: 80,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: banniereSNK.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          String? imgUrlDeLaBanniereActuel =
                                              await getBanniereActuelUtilisateurCourant();
                                          if (imgUrlDeLaBanniereActuel !=
                                              banniereSNK[index].imageUrl) {
                                            valeurVente +=
                                                sellValue(banniereSNK[index]);
                                            aSelectionnerBanniere = true;
                                            banniereSelectionne =
                                                banniereSNK[index];
                                            Navigator.pop(context);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Vous ne pouvez pas sélectionner votre bannière actuelle",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 0,
                                                backgroundColor: Colors.black,
                                                textColor: Colors.blue,
                                                fontSize: 16.0);
                                          }
                                        },
                                        child: Center(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  width: 130,
                                                  height: 120,
                                                  child: Image.asset(
                                                    banniereSNK[index].imageUrl,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (banniereSNK[index].number >
                                                    1)
                                                  Positioned(
                                                    bottom: 10,
                                                    right: 0,
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff151692), // You can change the color
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xff17c983),
                                                          width:
                                                              1, // Épaisseur de la bordure
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          banniereSNK[index]
                                                              .number
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .white, // Text color
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                    }),
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 17,
                                ),
                                width: double.infinity,
                                height: 3,
                                color: couleurBoutons,
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    color: const Color(0xff151692),
                                  ),
                                  width: 170,
                                  height: 35,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xff17c983),
                                          spreadRadius: 0,
                                          blurRadius: 20.0,
                                        ),
                                      ],
                                    ),
                                    width: 160,
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        'My Hero Academia'.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 280,
                              height: 80,
                              child: SizedBox(
                                height: 80,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: banniereMHA.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          String? imgUrlDeLaBanniereActuel =
                                              await getBanniereActuelUtilisateurCourant();
                                          if (imgUrlDeLaBanniereActuel !=
                                              banniereMHA[index].imageUrl) {
                                            valeurVente +=
                                                sellValue(banniereMHA[index]);
                                            aSelectionnerBanniere = true;
                                            banniereSelectionne =
                                                banniereMHA[index];
                                            Navigator.pop(context);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Vous ne pouvez pas sélectionner votre bannière actuelle",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 0,
                                                backgroundColor: Colors.black,
                                                textColor: Colors.blue,
                                                fontSize: 16.0);
                                          }
                                        },
                                        child: Center(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  width: 130,
                                                  height: 120,
                                                  child: Image.asset(
                                                    banniereMHA[index].imageUrl,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (banniereMHA[index].number >
                                                    1)
                                                  Positioned(
                                                    bottom: 10,
                                                    right: 0,
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff151692), // You can change the color
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xff17c983),
                                                          width:
                                                              1, // Épaisseur de la bordure
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          banniereMHA[index]
                                                              .number
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .white, // Text color
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            },
          );
        },
      ).then((value) {
        if (aSelectionnerBanniere) {
          setState(() {
            valeurVente;
            banniereChoisi = true;
            banniereSelectionne;
          });
        }
      });

  Future<void> _showMyDialog(Item? item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Empêche de fermer le dialog en cliquant à l'extérieur
      builder: (BuildContext context) {
        String nomItem = item!.name;
        double hauteurImage;
        double largeurImage;
        double tailleDialog;
        if (item.type == ItemType.banniere) {
          tailleDialog = 220;
          hauteurImage = 100;
          largeurImage = 280;
        } else {
          tailleDialog = 350;
          hauteurImage = 200;
          largeurImage = 200;
        }
        return AlertDialog(
          backgroundColor: const Color(0xff151692).withOpacity(0.7),
          title: Text(
            nomItem.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff17c983),
            ),
          ),
          content: SizedBox(
            height: tailleDialog,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const SizedBox(height: 20),
                  Image.asset(
                    item.imageUrl,
                    width: largeurImage,
                    height: hauteurImage,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Ferme le dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleurBoutons,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Color(0xff151692),
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
    ).then((_) {
      // Rafraîchit la page complète après la fermeture du dialog
      setState(() {
        getDataChestScreen();
      });
    });
  }
}
