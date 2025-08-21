import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/aventureScreens/menuAventure.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/widgets/widget.dart';

class SNKAventureScreen extends StatefulWidget {
  const SNKAventureScreen({super.key});

  @override
  State<SNKAventureScreen> createState() => _SNKAventureScreenState();
}

class _SNKAventureScreenState extends State<SNKAventureScreen> {
  double tailleEtoiles = 25;
  List<int> recordsSNK = [0, 0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    List<int>? records = await getRecordsOnePiece();

    setState(() {
      recordsSNK = records ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                          ileAventureSNK(
                              context,
                              55.w,
                              7,
                              'assets/questionsOnePiece2.json',
                              "ile7",
                              recordsSNK[7],
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
                          ileAventureSNK(
                              context,
                              55.w,
                              6,
                              'assets/questionsOnePiece2.json',
                              "ile6",
                              recordsSNK[6],
                              6),
                          SizedBox(height: 6.h),
                          ileAventureSNK(
                              context,
                              5.w,
                              5,
                              'assets/questionsOnePiece2.json',
                              "ile5",
                              recordsSNK[5],
                              5),
                          SizedBox(height: 6.h),
                          ileAventureSNK(
                              context,
                              65.w,
                              4,
                              'assets/questionsOnePiece2.json',
                              "ile4",
                              recordsSNK[4],
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
                          ileAventureSNK(
                              context,
                              25.w,
                              3,
                              'assets/questionsOnePiece2.json',
                              "ile3",
                              recordsSNK[3],
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
                          ileAventureSNK(
                              context,
                              45.w,
                              2,
                              'questionsOnePiece2.json',
                              "ile2",
                              recordsSNK[2],
                              2),
                          SizedBox(height: 7.h),
                          ileAventureSNK(
                            context,
                            65.w,
                            1,
                            'questionsOnePiece2',
                            "ile1",
                            recordsSNK[1],
                            1,
                          ),
                          SizedBox(height: 5.h),
                          ileAventureSNK(
                            context,
                            30.w,
                            0,
                            'questionsMHA-libre',
                            "SNK1",
                            recordsSNK[0],
                            0,
                          ),
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
