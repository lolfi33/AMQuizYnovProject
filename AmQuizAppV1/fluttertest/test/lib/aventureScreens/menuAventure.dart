import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/aventureScreens/mha/mhaAventureScreen.dart';
import 'package:test/aventureScreens/onePiece/onePieceAventureScreen.dart';
import 'package:test/aventureScreens/snk/snkAventureScreen.dart';
import 'package:test/globals.dart';
import 'package:test/miniGamesScreens/datas/datasMainTrainingScreen.dart';
import 'package:test/mainScreen.dart';

class MenuAventure extends StatefulWidget {
  const MenuAventure({super.key});

  @override
  State<MenuAventure> createState() => _MenuAventure();
}

class _MenuAventure extends State<MenuAventure> {
  TextEditingController controller = TextEditingController();
  // ignore: non_constant_identifier_names
  List<Oeuvre> titreOeuvres = [
    Oeuvre(
      title: 'One piece',
    ),
    Oeuvre(
      title: 'Attaque des titans',
    ),
    Oeuvre(
      title: 'My Hero Academia',
    ),
  ];
  late List<Oeuvre> filteredOeuvres;

  @override
  void initState() {
    super.initState();
    filteredOeuvres = List.from(titreOeuvres);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(fondPrincipal4),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SizedBox(
              height: 6.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 4.w),
                InkWell(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MainScreen(2))),
                  child: Container(
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
                SizedBox(width: 10.w),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: couleurBoutons,
                  ),
                  width: 50.w,
                  height: 6.h,
                  child: Container(
                    width: 47.w,
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
                          "Aventure".toUpperCase(),
                          style: TextStyle(
                            fontSize: 5.w,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/item3.gif'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  margin: EdgeInsets.only(left: 5.w, top: 2.5.h),
                  width: 90.w,
                  height: 82.h,
                ),
                Column(
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.w),
                          color: Colors.grey,
                          border: Border.all(
                            color: Colors.black, // Couleur de la bordure
                            width: 0.5.w, // Épaisseur de la bordure
                          ),
                        ),
                        height: 5.h,
                        width: 41.w,
                        margin: EdgeInsets.only(top: 4.h),
                        child: Center(
                          child: Text(
                            "A la une".toUpperCase(),
                            style:
                                TextStyle(fontSize: 5.w, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.w),
                          border: Border.all(
                            color: Colors.white, // Couleur de la bordure
                            width: 0.5.w, // Épaisseur de la bordure
                          ),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/onePieceMenu.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        height: 10.h,
                        width: 82.w,
                        child: Center(
                          child: Stack(
                            children: [
                              // Texte avec la bordure noire
                              Text(
                                "One Piece".toUpperCase(),
                                style: TextStyle(
                                  fontSize: 5.w,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 4 // Épaisseur de la bordure
                                    ..color =
                                        Colors.black, // Couleur de la bordure
                                ),
                              ),
                              // Texte principal en blanc
                              Text(
                                "One Piece".toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 5.w,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnePieceAventureScreen(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    SizedBox(
                      width: 82.w,
                      height: 6.h,
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          fillColor: Colors.grey,
                          filled: true,
                          hintText: "Rechercher une oeuvre",
                          hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 210, 205, 205),
                              fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xff17c983),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                          ),
                          // Pour appliquer le même style lorsque le TextField est sélectionné :
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                            borderSide: BorderSide(
                              color: Colors
                                  .black, // Choisissez la couleur de la bordure ici
                              width: 0.5
                                  .w, // Choisissez l'épaisseur de la bordure ici
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                            borderSide: BorderSide(
                              color: Colors
                                  .white, // Ou une autre couleur pour le focus
                              width: 0.5
                                  .w, // Ajustez l'épaisseur si nécessaire pour le focus
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredOeuvres = titreOeuvres.where((oeuvre) {
                              return oeuvre.title
                                  .toLowerCase()
                                  .contains(value.toLowerCase());
                            }).toList();
                          });
                        },
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 90.w,
                        color: Colors.grey,
                        height: 0.5.h,
                        margin: EdgeInsets.only(top: 1.h),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 31.5.h,
                    ),
                    Center(
                      child: SizedBox(
                        height: 46.h,
                        width: 90.w,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: filteredOeuvres.length,
                            itemBuilder: (BuildContext context, int index) {
                              String cheminImageDeFond =
                                  'assets/images/onePieceMenu.png';
                              if (filteredOeuvres[index].title ==
                                  "Attaque des titans") {
                                cheminImageDeFond = 'assets/images/SNKMenu.png';
                              } else if (filteredOeuvres[index].title ==
                                  "My Hero Academia") {
                                cheminImageDeFond = 'assets/images/MHAMenu.png';
                              }
                              return GestureDetector(
                                onTap: () {
                                  if (filteredOeuvres[index].title ==
                                      "One piece") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const OnePieceAventureScreen(),
                                      ),
                                    );
                                  } else if (filteredOeuvres[index].title ==
                                      "Attaque des titans") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SNKAventureScreen(),
                                      ),
                                    );
                                  } else if (filteredOeuvres[index].title ==
                                      "My Hero Academia") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MHAAventureScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.w),
                                      border: Border.all(
                                        color: Colors
                                            .black, // Couleur de la bordure
                                        width: 0.5.w, // Épaisseur de la bordure
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(cheminImageDeFond),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    height: 10.h,
                                    width: 82.w,
                                    margin: EdgeInsets.only(bottom: 3.h),
                                    child: Center(
                                      child: Stack(
                                        children: [
                                          // Texte avec la bordure noire
                                          Text(
                                            filteredOeuvres[index]
                                                .title
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 5.w,
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth =
                                                    4 // Épaisseur de la bordure
                                                ..color = Colors
                                                    .black, // Couleur de la bordure
                                            ),
                                          ),
                                          // Texte principal en blanc
                                          Text(
                                            filteredOeuvres[index]
                                                .title
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 5.w,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
