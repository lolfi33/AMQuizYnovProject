import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/DataBase/database.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/datas/datasCoupsSpeciaux.dart';
import 'package:test/mainScreens/datas/datasChestScreen.dart';
import 'package:test/widgets/widget.dart';

class ProfilScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfilScreen({required this.userData, super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;
  final List<String> _tabsTitres = ['Profils', 'Bannières'];

  // Pour afficher différents blocs (avec les lianes) dans la même listView
  int numBlocAAffichier = 1;
  String imgBlocAFficher = "";

  // Pour affichier listes coups spéciaux
  List<CoupSpeciaux> coupsOffensif = [];
  List<CoupSpeciaux> coupsDefensif = [];

  // Pour changer le titre
  final TextEditingController _titreController = TextEditingController();
  String titreReal = '';
  List<String> listeTitresReal = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => currentTabIndex = 0);
    _chargerProfils();
    _chargerBannieres();
    _loadUserData();
    // _chargerCoupsSpeciaux();
  }

  void _loadUserData() async {
    String? titre = await getTitreJoueurCourant();
    List<String>? listeTitres = await getListeTitresJoueurCourant();

    setState(() {
      _titreController.text = titre ?? '';
      titreReal = titre ?? '';
      listeTitresReal = listeTitres ?? [''];
    });
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

  // void _chargerCoupsSpeciaux() async {
  //   // Récupérer les coups spéciaux en parallèle
  //   var futures = await Future.wait([
  //     getListeCoupsSpeciauxO(),
  //     getListeCoupsSpeciauxD(),
  //   ]);

  //   // Vérifier et mettre à jour l'état avec les résultats obtenus
  //   setState(() {
  //     if (futures[0] != null) {
  //       coupsOffensif = futures[0] as List<CoupSpeciaux>;
  //     }
  //     if (futures[1] != null) {
  //       coupsDefensif = futures[1] as List<CoupSpeciaux>;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(fondPrincipal),
            fit: BoxFit.fill,
          ),
        ),
        child: DefaultTabController(
          length: _tabsTitres.length,
          initialIndex: currentTabIndex,
          child: Column(
            children: [
              SizedBox(height: 5.h),
              Container(
                margin: EdgeInsets.only(right: 4.5.w, left: 4.5.w),
                child: Builder(
                  builder: (BuildContext context) {
                    return banniereSection(widget.userData);
                  },
                ),
              ),
              SizedBox(height: 1.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Titre',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.w),
                          color: const Color(0xff151692).withOpacity(0.5),
                        ),
                        height: 5.h,
                        width: 55.w,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.w),
                            color: const Color(0xff151692).withOpacity(0.5),
                            border: Border.all(
                              color: couleurBoutons, // Couleur de la bordure
                            ),
                          ),
                          height: 5.h,
                          width: 55.w,
                          child: DropdownMenu<String>(
                            controller: _titreController,
                            trailingIcon: const Icon(
                              Icons.arrow_drop_down,
                              semanticLabel: 'fleche du bas',
                              color: Colors.white,
                            ),
                            initialSelection: titreReal,
                            textStyle: TextStyle(
                              fontSize: 3.5.w,
                              color: Colors.white,
                            ),
                            menuHeight: 18.h,
                            menuStyle: MenuStyle(
                              backgroundColor: WidgetStatePropertyAll<Color>(
                                const Color(0xff151692).withOpacity(0.5),
                              ),
                            ),
                            expandedInsets: EdgeInsets.zero,
                            dropdownMenuEntries: listeTitresReal
                                .map<DropdownMenuEntry<String>>((String value) {
                              return DropdownMenuEntry<String>(
                                value: value,
                                label: value,
                                style: MenuItemButton.styleFrom(
                                  textStyle: TextStyle(
                                    fontSize: 3.5.w,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  backgroundColor:
                                      const Color(0xff151692).withOpacity(0.5),
                                  foregroundColor: Colors.white,
                                ),
                              );
                            }).toList(),
                            onSelected: (String? nouveauTitre) async {
                              if (nouveauTitre != null) {
                                await DatabaseService(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .updateTitre(nouveauTitre);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),
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
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(5.w)),
                    ),
                    height: 6.h,
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorColor: couleurBoutons,
                      indicatorWeight: 1.w,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: _tabsTitres.asMap().entries.map((MapEntry map) {
                        String tab = map.value;
                        return Tab(
                          child: Text(
                            tab.toUpperCase(),
                            style: TextStyle(
                                fontSize: 3.5.w, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }).toList(),
                      labelColor: couleurBoutons,
                      unselectedLabelColor: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                          spreadRadius: -7,
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
                          SizedBox(
                            height: 1.h,
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff151692).withOpacity(0.5),
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 340,
                              height: 125,
                              child: SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(left: 5),
                                  itemCount: profilOP.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        final String nouvellePhotoDeProfil =
                                            profilOP[index].imageUrl;
                                        await DatabaseService(
                                                uid: FirebaseAuth
                                                    .instance.currentUser!.uid)
                                            .updatePhotoDeProfil(
                                                nouvellePhotoDeProfil);
                                      },
                                      child: Center(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Stack(
                                            children: [
                                              SizedBox(
                                                width: 110,
                                                height: 100,
                                                child: Image.asset(
                                                  profilOP[index].imageUrl,
                                                  semanticLabel:
                                                      'profilOnePiece',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              if (profilOP[index].number > 1)
                                                Positioned(
                                                  bottom: 5,
                                                  right: 5,
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
                                                        profilOP[index]
                                                            .number
                                                            .toString(),
                                                        style: const TextStyle(
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
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
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
                                          spreadRadius: -7,
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
                          SizedBox(
                            height: 1.h,
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff151692).withOpacity(0.5),
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 340,
                              height: 125,
                              child: SizedBox(
                                height: 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(left: 5),
                                    itemCount: profilNaruto.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          final String nouvellePhotoDeProfil =
                                              profilNaruto[index].imageUrl;
                                          await DatabaseService(
                                                  uid: FirebaseAuth.instance
                                                      .currentUser!.uid)
                                              .updatePhotoDeProfil(
                                                  nouvellePhotoDeProfil);
                                        },
                                        child: Center(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                SizedBox(
                                                  width: 110,
                                                  height: 100,
                                                  child: Image.asset(
                                                    profilNaruto[index]
                                                        .imageUrl,
                                                    semanticLabel:
                                                        'profilNaruto',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (profilNaruto[index].number >
                                                    1)
                                                  Positioned(
                                                    bottom: 5,
                                                    right: 5,
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
                          SizedBox(
                            height: 2.h,
                          ),
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
                                          spreadRadius: -7,
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
                          SizedBox(
                            height: 1.h,
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff151692).withOpacity(0.5),
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 340,
                              height: 125,
                              child: SizedBox(
                                height: 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(left: 5),
                                    itemCount: profilMHA.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          final String nouvellePhotoDeProfil =
                                              profilMHA[index].imageUrl;
                                          await DatabaseService(
                                                  uid: FirebaseAuth.instance
                                                      .currentUser!.uid)
                                              .updatePhotoDeProfil(
                                                  nouvellePhotoDeProfil);
                                        },
                                        child: Center(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Stack(
                                              children: [
                                                SizedBox(
                                                  width: 110,
                                                  height: 100,
                                                  child: Image.asset(
                                                    profilMHA[index].imageUrl,
                                                    semanticLabel: 'profilMHA',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (profilMHA[index].number > 1)
                                                  Positioned(
                                                    bottom: 5,
                                                    right: 5,
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
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                          spreadRadius: -7,
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
                          SizedBox(
                            height: 1.h,
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff151692).withOpacity(0.5),
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 340,
                              height: 100,
                              child: SizedBox(
                                height: 120,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: banniereOP.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          final Item nouvelleBanniere =
                                              banniereOP[index];
                                          await DatabaseService(
                                                  uid: FirebaseAuth.instance
                                                      .currentUser!.uid)
                                              .updateBanniere(nouvelleBanniere);
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
                                                  width: 175,
                                                  child: Image.asset(
                                                    banniereOP[index].imageUrl,
                                                    semanticLabel:
                                                        'banniere one piece',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (banniereOP[index].number >
                                                    1)
                                                  Positioned(
                                                    bottom: 0,
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
                          SizedBox(
                            height: 2.h,
                          ),
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
                                          spreadRadius: -7,
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
                          SizedBox(
                            height: 1.h,
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff151692).withOpacity(0.5),
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 340,
                              height: 100,
                              child: SizedBox(
                                height: 120,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: banniereSNK.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          final Item nouvelleBanniere =
                                              banniereSNK[index];
                                          await DatabaseService(
                                                  uid: FirebaseAuth.instance
                                                      .currentUser!.uid)
                                              .updateBanniere(nouvelleBanniere);
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
                                                  width: 175,
                                                  child: Image.asset(
                                                    banniereSNK[index].imageUrl,
                                                    semanticLabel:
                                                        'banniere naruto',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (banniereSNK[index].number >
                                                    1)
                                                  Positioned(
                                                    bottom: 0,
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
                          SizedBox(
                            height: 2.h,
                          ),
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
                                          spreadRadius: -7,
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
                          SizedBox(
                            height: 1.h,
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff151692).withOpacity(0.5),
                                border: Border.all(
                                  color: couleurBoutons,
                                  width: 2, // Épaisseur de la bordure
                                ),
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                              width: 340,
                              height: 100,
                              child: SizedBox(
                                height: 120,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: banniereMHA.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          final Item nouvelleBanniere =
                                              banniereMHA[index];
                                          await DatabaseService(
                                                  uid: FirebaseAuth.instance
                                                      .currentUser!.uid)
                                              .updateBanniere(nouvelleBanniere);
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
                                                  width: 175,
                                                  child: Image.asset(
                                                    banniereMHA[index].imageUrl,
                                                    semanticLabel:
                                                        'banniere MHA',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                if (banniereMHA[index].number >
                                                    1)
                                                  Positioned(
                                                    bottom: 0,
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
                          SizedBox(
                            height: 2.h,
                          ),
                        ],
                      ),
                    ),
                    // Column(
                    //   children: [
                    //     StreamBuilder<DocumentSnapshot>(
                    //       stream: FirebaseFirestore.instance
                    //           .collection('Users')
                    //           .doc(FirebaseAuth.instance.currentUser!.uid)
                    //           .snapshots(),
                    //       builder: (context, snapshot) {
                    //         if (snapshot.hasError) {
                    //           return const Text('Une erreur est survenue');
                    //         }

                    //         if (snapshot.connectionState ==
                    //             ConnectionState.waiting) {
                    //           return const CircularProgressIndicator();
                    //         }

                    //         // Extraction de l'index de coupSpecial depuis Firebase
                    //         var userData =
                    //             snapshot.data!.data() as Map<String, dynamic>;
                    //         var coupSpecialMap = userData['coupSpecial'];
                    //         CoupSpeciaux coupSpecialActuel =
                    //             CoupSpeciaux.fromMap(coupSpecialMap);

                    //         return Container(
                    //           decoration: BoxDecoration(
                    //             border: Border.all(
                    //               color: Colors.black,
                    //               width: 1, // Épaisseur de la bordure
                    //             ),
                    //             borderRadius: BorderRadius.circular(5.w),
                    //             image: const DecorationImage(
                    //               image: AssetImage('assets/images/Item6.gif'),
                    //               fit: BoxFit.fill,
                    //             ),
                    //           ),
                    //           width: 90.w,
                    //           height: 16.5.h,
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: [
                    //               Container(
                    //                 decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(5.w),
                    //                   color: Colors.black.withOpacity(0.2),
                    //                 ),
                    //                 margin: EdgeInsets.only(top: 0.5.h),
                    //                 padding:
                    //                     EdgeInsets.symmetric(horizontal: 3.w),
                    //                 child: Text(
                    //                   coupSpecialActuel.nom.toUpperCase(),
                    //                   textAlign: TextAlign.center,
                    //                   style: const TextStyle(
                    //                       fontSize: 16, color: Colors.white),
                    //                 ),
                    //               ),
                    //               Row(
                    //                 children: [
                    //                   Container(
                    //                     margin: EdgeInsets.only(
                    //                         top: 0.5.h, left: 4.w),
                    //                     child: InkWell(
                    //                       onTap: () => Navigator.pop(context),
                    //                       child: coupSpecial(coupSpecialActuel),
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     decoration: BoxDecoration(
                    //                       borderRadius:
                    //                           BorderRadius.circular(5.w),
                    //                       color: Colors.black.withOpacity(0.4),
                    //                     ),
                    //                     margin: EdgeInsets.only(
                    //                         top: 0.5.h, left: 5.w),
                    //                     width: 210,
                    //                     height: 65,
                    //                     child: Center(
                    //                       child: Container(
                    //                         margin: EdgeInsets.symmetric(
                    //                             horizontal: 2.w),
                    //                         child: Text(
                    //                           coupSpecialActuel.description,
                    //                           textAlign: TextAlign.center,
                    //                           style: const TextStyle(
                    //                               fontSize: 12,
                    //                               color: Colors.white),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //               SizedBox(
                    //                 height: 0.5.h,
                    //               ),
                    //               Container(
                    //                 decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(5.w),
                    //                   color: Colors.black.withOpacity(0.2),
                    //                 ),
                    //                 margin: EdgeInsets.only(top: 0.5.h),
                    //                 width: 190,
                    //                 height: 17,
                    //                 child: Center(
                    //                   child: Text(
                    //                     'Utilisation max par partie : ${coupSpecialActuel.utilisationMax}'
                    //                         .toUpperCase(),
                    //                     style: const TextStyle(
                    //                         fontSize: 10, color: Colors.white),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         );
                    //       },
                    //     ),
                    //     Expanded(
                    //       child: SingleChildScrollView(
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             SizedBox(
                    //               height: 1.h,
                    //             ),
                    //             Stack(
                    //               children: [
                    //                 Container(
                    //                   margin: const EdgeInsets.only(
                    //                     top: 17,
                    //                   ),
                    //                   width: double.infinity,
                    //                   height: 3,
                    //                   color: Colors.black,
                    //                 ),
                    //                 Center(
                    //                   child: Container(
                    //                     decoration: BoxDecoration(
                    //                       borderRadius:
                    //                           BorderRadius.circular(5.w),
                    //                       color: const Color(0xff151692),
                    //                     ),
                    //                     width: 100,
                    //                     height: 35,
                    //                     child: Container(
                    //                       alignment: Alignment.center,
                    //                       decoration: BoxDecoration(
                    //                         borderRadius:
                    //                             BorderRadius.circular(5.w),
                    //                         boxShadow: const [
                    //                           BoxShadow(
                    //                             color: Color(0xffa23034),
                    //                             spreadRadius: -7,
                    //                             blurRadius: 20.0,
                    //                           ),
                    //                         ],
                    //                       ),
                    //                       width: 90,
                    //                       height: 30,
                    //                       child: Center(
                    //                         child: Text(
                    //                           'Offensif'.toUpperCase(),
                    //                           style: const TextStyle(
                    //                               color: Colors.white),
                    //                           textAlign: TextAlign.center,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //             SizedBox(
                    //               height: 1.h,
                    //             ),
                    //             Center(
                    //               child: Container(
                    //                 decoration: BoxDecoration(
                    //                   color: Colors.grey.withOpacity(0.5),
                    //                   border: Border.all(
                    //                     color: Colors.black,
                    //                     width: 2, // Épaisseur de la bordure
                    //                   ),
                    //                   borderRadius: BorderRadius.circular(5.w),
                    //                 ),
                    //                 width: 340,
                    //                 height: 125,
                    //                 child: SizedBox(
                    //                   height: 100,
                    //                   child: ListView.builder(
                    //                       scrollDirection: Axis.horizontal,
                    //                       padding:
                    //                           const EdgeInsets.only(left: 5),
                    //                       itemCount: coupsOffensif.length,
                    //                       itemBuilder: (BuildContext context,
                    //                           int index) {
                    //                         return GestureDetector(
                    //                           onTap: () async {
                    //                             final CoupSpeciaux
                    //                                 nouveauCoupSpecial =
                    //                                 coupsOffensif[index];
                    //                             await DatabaseService(
                    //                                     uid: FirebaseAuth
                    //                                         .instance
                    //                                         .currentUser!
                    //                                         .uid)
                    //                                 .updateCoupSpecial(
                    //                                     nouveauCoupSpecial);
                    //                           },
                    //                           child: Center(
                    //                             child: Align(
                    //                               alignment: Alignment.center,
                    //                               child: SizedBox(
                    //                                 width: 110,
                    //                                 height: 100,
                    //                                 child: Image.asset(
                    //                                   coupsOffensif[index]
                    //                                       .imageUrl,
                    //                                   fit: BoxFit.contain,
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         );
                    //                       }),
                    //                 ),
                    //               ),
                    //             ),
                    //             SizedBox(
                    //               height: 1.h,
                    //             ),
                    //             Stack(
                    //               children: [
                    //                 Container(
                    //                   margin: const EdgeInsets.only(
                    //                     top: 17,
                    //                   ),
                    //                   width: double.infinity,
                    //                   height: 3,
                    //                   color: Colors.black,
                    //                 ),
                    //                 Center(
                    //                   child: Container(
                    //                     decoration: BoxDecoration(
                    //                       borderRadius:
                    //                           BorderRadius.circular(5.w),
                    //                       color: const Color(0xff151692),
                    //                     ),
                    //                     width: 100,
                    //                     height: 35,
                    //                     child: Container(
                    //                       alignment: Alignment.center,
                    //                       decoration: BoxDecoration(
                    //                         borderRadius:
                    //                             BorderRadius.circular(5.w),
                    //                         boxShadow: const [
                    //                           BoxShadow(
                    //                             color: Color(0xffffed00),
                    //                             spreadRadius: -7,
                    //                             blurRadius: 20.0,
                    //                           ),
                    //                         ],
                    //                       ),
                    //                       width: 90,
                    //                       height: 30,
                    //                       child: Center(
                    //                         child: Text(
                    //                           'Défensif'.toUpperCase(),
                    //                           style: const TextStyle(
                    //                               color: Colors.white),
                    //                           textAlign: TextAlign.center,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //             SizedBox(
                    //               height: 1.h,
                    //             ),
                    //             Center(
                    //               child: Container(
                    //                 decoration: BoxDecoration(
                    //                   color: Colors.grey.withOpacity(0.5),
                    //                   border: Border.all(
                    //                     color: Colors.black,
                    //                     width: 2, // Épaisseur de la bordure
                    //                   ),
                    //                   borderRadius: BorderRadius.circular(5.w),
                    //                 ),
                    //                 width: 340,
                    //                 height: 125,
                    //                 child: SizedBox(
                    //                   height: 100,
                    //                   child: ListView.builder(
                    //                       scrollDirection: Axis.horizontal,
                    //                       padding:
                    //                           const EdgeInsets.only(left: 5),
                    //                       itemCount: coupsDefensif.length,
                    //                       itemBuilder: (BuildContext context,
                    //                           int index) {
                    //                         return GestureDetector(
                    //                           onTap: () async {
                    //                             final CoupSpeciaux
                    //                                 nouveauCoupSpecial =
                    //                                 coupsDefensif[index];
                    //                             await DatabaseService(
                    //                                     uid: FirebaseAuth
                    //                                         .instance
                    //                                         .currentUser!
                    //                                         .uid)
                    //                                 .updateCoupSpecial(
                    //                                     nouveauCoupSpecial);
                    //                           },
                    //                           child: Center(
                    //                             child: Align(
                    //                               alignment: Alignment.center,
                    //                               child: SizedBox(
                    //                                 width: 110,
                    //                                 height: 100,
                    //                                 child: Image.asset(
                    //                                   coupsDefensif[index]
                    //                                       .imageUrl,
                    //                                   fit: BoxFit.contain,
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         );
                    //                       }),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
