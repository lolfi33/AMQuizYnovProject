import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:test/DataBase/database.dart';
import 'package:test/globalFunctions.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreens/chestScreen.dart';
import 'package:test/mainScreens/discoverScreen.dart';
import 'package:test/mainScreens/mainPage.dart';
import 'package:test/mainScreens/profilScreen.dart';
import 'package:test/mainScreens/shopScreen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  int indexSelected;
  MainScreen(this.indexSelected, {super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController? _pageController;
  int? _currentIndex;
  late bool hasDoneTuto = false;

  final GlobalKey keyHome = GlobalKey();
  final GlobalKey keyShop = GlobalKey();
  final GlobalKey keyChecklist = GlobalKey();
  final GlobalKey keyDiscover = GlobalKey();
  final GlobalKey keyProfile = GlobalKey();

// Clés pour MainPage (créées dans MainScreen pour le tutoriel)
  late final GlobalKey keyParam;
  late final GlobalKey keyTuto;
  late final GlobalKey keyAmes;
  late final GlobalKey keyBanniere;
  late final GlobalKey keyFriends;
  late final GlobalKey keySucess;
  late final GlobalKey keyMiniGames;
  late final GlobalKey keyAventures;
  late final GlobalKey keyFinTuto;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.indexSelected);
    _currentIndex = widget.indexSelected;
    getDataTuto();
    keyParam = GlobalKey();
    keyTuto = GlobalKey();
    keyAmes = GlobalKey();
    keyBanniere = GlobalKey();
    keyFriends = GlobalKey();
    keySucess = GlobalKey();
    keyMiniGames = GlobalKey();
    keyAventures = GlobalKey();
    keyFinTuto = GlobalKey();
  }

  getDataTuto() async {
    hasDoneTuto = await getTutoJoueurCourant();
    if (!hasDoneTuto) {
      // Lancer le tutoriel après que le widget soit construit
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.indexSelected == 2) {
          ShowCaseWidget.of(context).startShowCase([
            keyHome,
            keyShop,
            keyChecklist,
            keyDiscover,
            keyProfile,
          ]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Empêcher l'utilisateur de retourner avec le geste
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xff151692),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            return PageView(
              onPageChanged: (index) {
                if (index == 2) {
                  getDataListeSucces();
                  getDataInvitationsAndFriends();
                }
                setState(() {
                  _currentIndex = index;
                });
              },
              controller: _pageController,
              children: [
                const ShopScreen(),
                const ChestScreen(),
                MainPage(
                  userData: data,
                  keyHome: keyHome,
                  keyShop: keyShop,
                  keyChecklist: keyChecklist,
                  keyDiscover: keyDiscover,
                  keyProfile: keyProfile,
                  keyParam: keyParam,
                  keyTuto: keyTuto,
                  keyAmes: keyAmes,
                  keyBanniere: keyBanniere,
                  keyFriends: keyFriends,
                  keySucess: keySucess,
                  keyMiniGames: keyMiniGames,
                  keyAventures: keyAventures,
                  keyFinTuto: keyFinTuto,
                ),
                const DiscoverScreen(),
                ProfilScreen(
                  userData: data,
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: MediaQuery.removePadding(
          context: context,
          removeBottom:
              true, // Supprime le padding de la Safe Area pour personnaliser
          child: Container(
            padding: const EdgeInsets.only(bottom: 10.0),
            decoration: const BoxDecoration(
              color: Color(0xff151692),
            ),
            child: BottomNavigationBar(
              selectedItemColor: couleurBoutons,
              unselectedItemColor: Colors.white,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _currentIndex!,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _pageController?.jumpToPage(_currentIndex!);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xff151692).withOpacity(0.9),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Showcase(
                    key: keyShop,
                    description: 'Achetez des items, des vies et des âmes ici',
                    child: Icon(
                      Icons.shopping_basket,
                      size: 7.w,
                    ),
                  ),
                  label: 'magasin',
                ),
                BottomNavigationBarItem(
                  icon: Showcase(
                    key: keyChecklist,
                    description:
                        'Ici, ouvrez vos items et vendez-les contre des âmes',
                    child: Icon(
                      Icons.card_giftcard,
                      size: 7.w,
                    ),
                  ),
                  label: 'ouvrir',
                ),
                BottomNavigationBarItem(
                  icon: Showcase(
                    key: keyHome,
                    description:
                        'Bienvenue sur AMQuiz, une présentation d\'une minute va commencer',
                    child: Icon(
                      Icons.home,
                      size: 7.w,
                    ),
                  ),
                  label: 'acceuil',
                ),
                BottomNavigationBarItem(
                  icon: Showcase(
                    key: keyDiscover,
                    description:
                        'Ici, decouvrez de nouveaux joueurs, ajoutez les en ami et envoyez leurs des likes si vous aimez leurs profils',
                    child: Icon(
                      Icons.recent_actors,
                      size: 7.w,
                    ),
                  ),
                  label: 'decouvrir',
                ),
                BottomNavigationBarItem(
                  icon: Showcase(
                    key: keyProfile,
                    description: 'Changez votre profil, banniere et titre ici',
                    onTargetClick: () async {
                      if (!hasDoneTuto) {
                        // Démarrer le tutoriel de MainPage une fois que celui de MainScreen est terminé
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ShowCaseWidget.of(context).startShowCase([
                            keyParam,
                            keyTuto,
                            keyAmes,
                            keyBanniere,
                            keyFriends,
                            keySucess,
                            keyMiniGames,
                            keyAventures,
                            keyFinTuto
                          ]);
                        });
                        await DatabaseService(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .updateTuto();
                      }
                    },
                    onBarrierClick: () async {
                      if (!hasDoneTuto) {
                        // Démarrer le tutoriel de MainPage une fois que celui de MainScreen est terminé
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ShowCaseWidget.of(context).startShowCase([
                            keyParam,
                            keyTuto,
                            keyAmes,
                            keyBanniere,
                            keyFriends,
                            keySucess,
                            keyMiniGames,
                            keyAventures,
                            keyFinTuto
                          ]);
                        });
                        await DatabaseService(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .updateTuto();
                      }
                    },
                    disposeOnTap: true,
                    child: Icon(
                      Icons.face,
                      size: 7.w,
                    ),
                  ),
                  label: 'profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
