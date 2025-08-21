import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/aventureScreens/menuAventure.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/widgets/widget.dart';

class OnePieceAventureScreen extends StatefulWidget {
  const OnePieceAventureScreen({super.key});

  @override
  State<OnePieceAventureScreen> createState() => _OnePieceAventureScreenState();
}

class _OnePieceAventureScreenState extends State<OnePieceAventureScreen> {
  double tailleEtoiles = 25;
  List<int> recordsOnePiece = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  ];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    List<int>? records = await getRecordsOnePiece();

    setState(() {
      recordsOnePiece = records ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151692),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: couleurBoutons, // Couleur personnalisée (optionnel)
              ),
            )
          : Stack(
              children: [
                ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.zero,
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 10.h,
                              width: 100.w,
                              color: Colors.black,
                              child: Center(child: Text("A suivre..")),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/fondOnePiece6.jpg'),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                SizedBox(height: 25.h),
                                ileAventureOnePiece(
                                    context,
                                    5.w,
                                    4,
                                    'questionsOnePiece-Alabasta5',
                                    "Alabasta 5",
                                    recordsOnePiece[20],
                                    4),
                                Row(
                                  children: [
                                    SizedBox(width: 55.w),
                                    SizedBox(
                                      width: 20.w,
                                      height: 10.h,
                                      child: Image.asset(
                                        'assets/images/bateauImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: 0, // Fixe le container en haut de l'écran
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 20.h,
                                width: 100.w,
                                color: Colors.grey,
                                child: const Center(
                                  child: Text(
                                    "A suivre..",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/fondOnePiece5.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(height: 3.h),
                                ileAventureOnePiece(
                                    context,
                                    50.w,
                                    7,
                                    'questionsOnePiece-Alabasta4',
                                    "Alabasta 4",
                                    recordsOnePiece[19],
                                    7),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    SizedBox(width: 20.w),
                                    SizedBox(
                                      width: 15.w,
                                      height: 8.h,
                                      child: Image.asset(
                                        'assets/images/ileImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                                ileAventureOnePiece(
                                    context,
                                    73.w,
                                    6,
                                    'questionsOnePiece-Alabasta3',
                                    "Alabasta 3",
                                    recordsOnePiece[18],
                                    6),
                                SizedBox(height: 6.h),
                                ileAventureOnePiece(
                                    context,
                                    70.w,
                                    5,
                                    'questionsOnePiece-Alabasta2',
                                    "Alabasta 2",
                                    recordsOnePiece[17],
                                    5),
                                SizedBox(height: 6.h),
                                ileAventureOnePiece(
                                    context,
                                    5.w,
                                    4,
                                    'questionsOnePiece-Alabasta1',
                                    "Alabasta 1",
                                    recordsOnePiece[16],
                                    4),
                                Row(
                                  children: [
                                    SizedBox(width: 55.w),
                                    SizedBox(
                                      width: 20.w,
                                      height: 10.h,
                                      child: Image.asset(
                                        'assets/images/bateauImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/fondOnePiece4.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(height: 3.h),
                                ileAventureOnePiece(
                                    context,
                                    50.w,
                                    7,
                                    'questionsOnePiece-Drum2',
                                    "Drum 2",
                                    recordsOnePiece[15],
                                    7),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    SizedBox(width: 20.w),
                                    SizedBox(
                                      width: 15.w,
                                      height: 8.h,
                                      child: Image.asset(
                                        'assets/images/ileImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                                ileAventureOnePiece(
                                    context,
                                    73.w,
                                    6,
                                    'questionsOnePiece-Drum1',
                                    "Drum 1",
                                    recordsOnePiece[14],
                                    6),
                                SizedBox(height: 6.h),
                                ileAventureOnePiece(
                                    context,
                                    70.w,
                                    5,
                                    'questionsOnePiece-littleGarden',
                                    "Little Garden",
                                    recordsOnePiece[13],
                                    5),
                                SizedBox(height: 6.h),
                                ileAventureOnePiece(
                                    context,
                                    5.w,
                                    4,
                                    'questionsOnePiece-WhiskeyPeak',
                                    "Whisky Peak",
                                    recordsOnePiece[12],
                                    4),
                                Row(
                                  children: [
                                    SizedBox(width: 55.w),
                                    SizedBox(
                                      width: 20.w,
                                      height: 10.h,
                                      child: Image.asset(
                                        'assets/images/bateauImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/fondOnePiece3.jpeg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(height: 3.h),
                                ileAventureOnePiece(
                                    context,
                                    50.w,
                                    7,
                                    'questionsOnePiece-MountainIsland',
                                    "Mountain Island",
                                    recordsOnePiece[11],
                                    7),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    SizedBox(width: 20.w),
                                    SizedBox(
                                      width: 15.w,
                                      height: 8.h,
                                      child: Image.asset(
                                        'assets/images/ileImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                                ileAventureOnePiece(
                                    context,
                                    73.w,
                                    6,
                                    'questionsOnePiece-LogueTown2',
                                    "Logue Town 2",
                                    recordsOnePiece[10],
                                    6),
                                SizedBox(height: 6.h),
                                ileAventureOnePiece(
                                    context,
                                    70.w,
                                    5,
                                    'questionsOnePiece-LogueTown1',
                                    "Logue Town 1",
                                    recordsOnePiece[9],
                                    5),
                                SizedBox(height: 6.h),
                                ileAventureOnePiece(
                                    context,
                                    5.w,
                                    4,
                                    'questionsOnePiece-ArlongVsLuffy',
                                    "Arlong VS Luffy",
                                    recordsOnePiece[8],
                                    4),
                                Row(
                                  children: [
                                    SizedBox(width: 55.w),
                                    SizedBox(
                                      width: 20.w,
                                      height: 10.h,
                                      child: Image.asset(
                                        'assets/images/bateauImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/fondOnePiece2.jpeg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(height: 3.h),
                                ileAventureOnePiece(
                                    context,
                                    55.w,
                                    7,
                                    'questionsOnePiece-ArlongPark',
                                    "Arlong Park",
                                    recordsOnePiece[7],
                                    7),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    SizedBox(width: 40.w),
                                    SizedBox(
                                      width: 15.w,
                                      height: 8.h,
                                      child: Image.asset(
                                        'assets/images/ileImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                                ileAventureOnePiece(
                                    context,
                                    55.w,
                                    6,
                                    'questionsOnePiece-Baratie2',
                                    "Baratie 2",
                                    recordsOnePiece[6],
                                    6),
                                SizedBox(height: 6.h),
                                ileAventureOnePiece(
                                    context,
                                    5.w,
                                    5,
                                    'questionsOnePiece-Baratie1',
                                    "Baratie 1",
                                    recordsOnePiece[5],
                                    5),
                                SizedBox(height: 6.h),
                                ileAventureOnePiece(
                                    context,
                                    65.w,
                                    4,
                                    'questionsOnePiece-villageSirop2',
                                    "Village Sirop 2",
                                    recordsOnePiece[4],
                                    4),
                                Row(
                                  children: [
                                    SizedBox(width: 55.w),
                                    SizedBox(
                                      width: 20.w,
                                      height: 10.h,
                                      child: Image.asset(
                                        'assets/images/coffreImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/fondOnePiece1.jpeg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(height: 4.h),
                                ileAventureOnePiece(
                                    context,
                                    25.w,
                                    3,
                                    'questionsOnePiece-villageSirop1',
                                    "Village Sirop 1",
                                    recordsOnePiece[3],
                                    3),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    SizedBox(width: 5.w),
                                    SizedBox(
                                      width: 20.w,
                                      height: 10.h,
                                      child: Image.asset(
                                        'assets/images/bateauImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                ileAventureOnePiece(
                                    context,
                                    45.w,
                                    2,
                                    'questionsOnePiece-villageOrange',
                                    "Village Orange",
                                    recordsOnePiece[2],
                                    2),
                                SizedBox(height: 7.h),
                                ileAventureOnePiece(
                                    context,
                                    65.w,
                                    1,
                                    'questionsOnePiece-ShellsTown',
                                    "Shells Town",
                                    recordsOnePiece[1],
                                    1),
                                SizedBox(height: 5.h),
                                ileAventureOnePiece(
                                    context,
                                    30.w,
                                    0,
                                    'questionsOnePiece-Fuchsia',
                                    "Fuchsia",
                                    recordsOnePiece[0],
                                    0),
                                SizedBox(height: 2.h),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  top: 6.h,
                  left: 3.w,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MenuAventure(),
                      ),
                    ),
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
                ),
                nbVies(context),
                // Positioned(
                //   top: 85.h,
                //   right: 2.w,
                //   child: InkWell(
                //     onTap: () {
                //       currentTabIndex = 2;
                //       Navigator.push(context,
                //           MaterialPageRoute(builder: (context) => MainScreen(4)));
                //     },
                //     child: Container(
                //       width: 80,
                //       decoration: BoxDecoration(
                //         border: Border.all(
                //           color: couleurBoutons,
                //           width: 2, // Épaisseur de la bordure
                //         ),
                //         color: const Color(0xff16318F).withOpacity(0.9),
                //         borderRadius: BorderRadius.circular(2.w),
                //       ),
                //       child: Column(
                //         children: [
                //           Container(
                //             height: 30,
                //             decoration: const BoxDecoration(
                //               border: Border(
                //                 bottom: BorderSide(
                //                   color: Color(0xff17c983), // Couleur de la bordure
                //                   width: 2.0, // Épaisseur de la bordure
                //                 ),
                //               ),
                //             ),
                //             child: const Center(
                //                 child: Text(
                //               "Coup Spécial",
                //               style:
                //                   TextStyle(fontSize: 10, color: Color(0xff17c983)),
                //             )),
                //           ),
                //           const SizedBox(
                //             height: 3,
                //           ),
                //           SizedBox(
                //             width: 70,
                //             child: StreamBuilder<DocumentSnapshot>(
                //                 stream: FirebaseFirestore.instance
                //                     .collection('Users')
                //                     .doc(FirebaseAuth.instance.currentUser!.uid)
                //                     .snapshots(),
                //                 builder: (context, snapshot) {
                //                   if (snapshot.hasError) {
                //                     return const Text('Une erreur est survenue');
                //                   }

                //                   if (snapshot.connectionState ==
                //                       ConnectionState.waiting) {
                //                     return const CircularProgressIndicator();
                //                   }

                //                   // Extraction de l'index de coupSpecial depuis Firebase
                //                   var userData =
                //                       snapshot.data!.data() as Map<String, dynamic>;
                //                   var coupSpecialMap = userData['coupSpecial'];
                //                   CoupSpeciaux coupSpecialActuel =
                //                       CoupSpeciaux.fromMap(coupSpecialMap);

                //                   return coupSpecial(coupSpecialActuel);
                //                 }),
                //           ),
                //           const SizedBox(
                //             height: 3,
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
    );
  }
}
