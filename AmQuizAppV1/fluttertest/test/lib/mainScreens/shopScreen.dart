import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:http/http.dart' as http;
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/widgets/widget.dart';
import 'package:test/DataBase/database.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic> prixItems = {};

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  final Set<String> _productIds = {'ames1', 'ames2', 'ames3'};
  bool _isLoading = false;
  String _error = '';
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _recupererPrix();
    _loadProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Map<String, dynamic>> _recupererPrix() async {
    return await _databaseService.recupererPrix();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);
      print('Products found: ${response.productDetails}');
      print('Not found IDs: ${response.notFoundIDs}');
      if (response.error != null) {
        setState(() {
          _error = 'Erreur : ${response.error!.message}';
        });
      } else if (response.productDetails.isEmpty) {
        setState(() {
          _error = 'Aucun produit trouvé.';
        });
      } else {
        setState(() {
          // Trier les produits par leur ID pour un affichage dans l'ordre souhaité
          _products = response.productDetails
            ..sort((a, b) => a.id.compareTo(b.id));
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur inattendue : $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _buyProductAndroid(ProductDetails product) async {
    // Déclenche simplement l'achat
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    StreamSubscription<List<PurchaseDetails>>? subscription;
    subscription = _inAppPurchase.purchaseStream.listen(
      (purchases) async {
        for (var purchase in purchases) {
          if (purchase.status == PurchaseStatus.purchased) {
            final receiptData =
                purchase.verificationData.serverVerificationData;
            final String? idToken =
                await FirebaseAuth.instance.currentUser?.getIdToken();
            // Appel au serveur pour valider l'achat
            final response = await http.post(
              Uri.parse('$urlServeur/validate-receipt'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $idToken',
              },
              body: jsonEncode({
                'receiptData': receiptData,
                'uid': FirebaseAuth.instance.currentUser!.uid,
                'productId': product.id,
              }),
            );
            if (response.statusCode == 200) {
              await _inAppPurchase.completePurchase(purchase);
              final data = jsonDecode(response.body);
              Fluttertoast.showToast(
                  msg: data['message'] ?? 'Achat validé',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black,
                  textColor: Colors.blue,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: 'Erreur lors de la validation de l\'achat',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black,
                  textColor: Colors.blue,
                  fontSize: 16.0);
            }
          }
        }
        subscription?.cancel(); // Supprimez l'écouteur après utilisation
      },
    );
  }

  void _buyProduct(ProductDetails product) async {
    // Déclenche simplement l'achat
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  String _getTempsRestant(String? dateFinString) {
    if (dateFinString == null) {
      return "Date non définie";
    }

    try {
      DateTime dateFin = DateTime.parse(dateFinString);
      DateTime now = DateTime.now();

      Duration difference = dateFin.difference(now);

      if (difference.isNegative) {
        return "Offre expirée";
      }

      int jours = difference.inDays;
      int heures = difference.inHours % 24;
      int minutes = difference.inMinutes % 60;

      return "$jours J $heures h $minutes min";
    } catch (e) {
      return "Erreur de format";
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Nécessaire pour AutomaticKeepAliveClientMixin
    return FutureBuilder<Map<String, dynamic>>(
      future: _recupererPrix(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erreur de chargement des prix'));
        } else {
          // Affichage de l'interface après chargement des prix
          Map<String, dynamic> prixItems = snapshot.data!;
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(fondPrincipal5),
                fit: BoxFit.fill,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 2,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 92),
                          color: couleurBoutons,
                          width: 100.w,
                          height: 45,
                          child: Container(
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
                              child: Center(
                                child: Text(
                                  "Boutique".toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          height: 220,
                          width: 500,
                          margin: const EdgeInsets.only(
                            top: 20,
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  'Banniere du moment'.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Temps restant : ${_getTempsRestant(prixItems['banniere du mois dateFin'])}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        prixItems['banniere du mois image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 115,
                                width: 320,
                                margin: const EdgeInsets.only(top: 5),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Container(
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2.w),
                                    color: couleurBoutons.withOpacity(0.8),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        prixItems['banniere du mois']
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 6.w,
                                        height: 3.h,
                                        child: Image.asset(
                                          'assets/images/ame5.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: const Color(0xffFFF181),
                          margin: const EdgeInsets.only(
                            top: 20,
                          ),
                          width: 100.w,
                          height: 42,
                          child: Container(
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
                              child: Text(
                                "PROFILS".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/shop/etagereRouge.webp'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          margin: const EdgeInsets.only(
                            top: 8,
                          ),
                          height: 188,
                          width: 390,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  int nbAmesDuJoueur =
                                      await getnbAmeUtilisateurCourant() ?? 0;

                                  if (nbAmesDuJoueur >=
                                      prixItems['profil bronze']!) {
                                    checkIfWantToBuy(context, "profil bronze");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Pas assez d'âmes",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 0,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.blue,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 22,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: const Color(0xffb3b3b3),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child:
                                              Center(child: bronzeTextAnimer()),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 10,
                                        ),
                                        width: 100,
                                        height: 70,
                                        child: SimpleShadow(
                                          opacity: 0.7, // Default: 0.5
                                          color: Colors.black, // Default: Black
                                          offset: const Offset(
                                              0, 13), // Default: Offset(2, 2)
                                          sigma: 7,
                                          child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Shimmer.fromColors(
                                                  baseColor: Colors.brown,
                                                  highlightColor:
                                                      Colors.brown[300]!,
                                                  child: Container(
                                                    width: 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blue,
                                                      border: Border.all(
                                                        width: 2,
                                                        color:
                                                            Colors.brown[700]!,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width:
                                                      102, // Ajusté pour inclure la bordure
                                                  height:
                                                      102, // Ajusté pour inclure la bordure
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.brown[700]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        spreadRadius: 2,
                                                        blurRadius: 30,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/logo.png',
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: const Color(0xffb3b3b3),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        margin: const EdgeInsets.only(
                                          top: 13,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              prixItems['profil bronze']
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                              height: 3.h,
                                              child: Image.asset(
                                                'assets/images/ame5.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  int nbAmesDuJoueur =
                                      await getnbAmeUtilisateurCourant() ?? 0;

                                  if (nbAmesDuJoueur >=
                                      prixItems['profil argent']!) {
                                    checkIfWantToBuy(context, "profil argent");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Pas assez d'âmes",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 0,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.blue,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 22,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: const Color(0xffb3b3b3),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child:
                                              Center(child: argentTextAnimer()),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 10,
                                        ),
                                        width: 100,
                                        height: 70,
                                        child: SimpleShadow(
                                          opacity: 0.7, // Default: 0.5
                                          color: Colors.black, // Default: Black
                                          offset: const Offset(
                                              0, 13), // Default: Offset(2, 2)
                                          sigma: 7,
                                          child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Shimmer.fromColors(
                                                  baseColor: Colors.grey,
                                                  highlightColor:
                                                      Colors.grey[300]!,
                                                  child: Container(
                                                    width: 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blue,
                                                      border: Border.all(
                                                        width: 2,
                                                        color:
                                                            Colors.brown[700]!,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width:
                                                      102, // Ajusté pour inclure la bordure
                                                  height:
                                                      102, // Ajusté pour inclure la bordure
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.grey[700]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        spreadRadius: 2,
                                                        blurRadius: 30,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/logo.png',
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2.w),
                                          color: const Color(0xffb3b3b3),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        margin: const EdgeInsets.only(
                                          top: 13,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              prixItems['profil argent']
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                              height: 3.h,
                                              child: Image.asset(
                                                'assets/images/ame5.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  int nbAmesDuJoueur =
                                      await getnbAmeUtilisateurCourant() ?? 0;

                                  if (nbAmesDuJoueur >=
                                      prixItems['profil or']!) {
                                    checkIfWantToBuy(context, "profil or");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Pas assez d'âmes",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 0,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.blue,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 22,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: const Color(0xffb3b3b3),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Center(child: orTextAnimer()),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 10,
                                        ),
                                        width: 100,
                                        height: 70,
                                        child: SimpleShadow(
                                          opacity: 0.7, // Default: 0.5
                                          color: Colors.black, // Default: Black
                                          offset: const Offset(
                                              0, 13), // Default: Offset(2, 2)
                                          sigma: 7,
                                          child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Shimmer.fromColors(
                                                  baseColor:
                                                      const Color(0xffffbf00),
                                                  highlightColor:
                                                      const Color(0xffffdc73),
                                                  child: Container(
                                                    width: 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blue,
                                                      border: Border.all(
                                                        width: 2,
                                                        color:
                                                            Colors.brown[700]!,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width:
                                                      102, // Ajusté pour inclure la bordure
                                                  height:
                                                      102, // Ajusté pour inclure la bordure
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.yellow,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        spreadRadius: 2,
                                                        blurRadius: 30,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/logo.png',
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2.w),
                                          color: const Color(0xffb3b3b3),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        margin: const EdgeInsets.only(
                                          top: 13,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              prixItems['profil or'].toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                              height: 3.h,
                                              child: Image.asset(
                                                'assets/images/ame5.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: const Color(0xffFFFFFF),
                          width: 100.w,
                          height: 42,
                          child: Container(
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
                              child: Text(
                                "Bannieres".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/shop/etagereViolet.webp'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          margin: const EdgeInsets.only(
                            top: 8,
                          ),
                          height: 188,
                          width: 390,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  int nbAmesDuJoueur =
                                      await getnbAmeUtilisateurCourant() ?? 0;

                                  if (nbAmesDuJoueur >=
                                      prixItems['banniere bronze']!) {
                                    checkIfWantToBuy(
                                        context, "banniere bronze");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Pas assez d'âmes",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 0,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.blue,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 22,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: const Color(0xffb3b3b3),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child:
                                              Center(child: bronzeTextAnimer()),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 23,
                                        ),
                                        width: 100,
                                        height: 70,
                                        child: SimpleShadow(
                                          opacity: 0.7, // Default: 0.5
                                          color: Colors.black, // Default: Black
                                          offset: const Offset(
                                              0, 13), // Default: Offset(2, 2)
                                          sigma: 7,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Shimmer.fromColors(
                                                baseColor: Colors.brown,
                                                highlightColor:
                                                    Colors.brown[300]!,
                                                child: Container(
                                                  width: 100,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape
                                                        .rectangle, // Rectangle
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50), // Coins arrondis
                                                    color: Colors.blue,
                                                    border: Border.all(
                                                      color: Colors.green,
                                                      width: 50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 100,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape
                                                      .rectangle, // Rectangle
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50), // Coins arrondis
                                                  border: Border.all(
                                                    color: Colors.brown,
                                                    width: 3,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 30,
                                                    ),
                                                  ],
                                                ),
                                                child: Image.asset(
                                                  'assets/images/logo.png',
                                                  width: 25,
                                                  height: 25,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: const Color(0xffb3b3b3),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              prixItems['banniere bronze']
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                              height: 3.h,
                                              child: Image.asset(
                                                'assets/images/ame5.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  int nbAmesDuJoueur =
                                      await getnbAmeUtilisateurCourant() ?? 0;

                                  if (nbAmesDuJoueur >=
                                      prixItems['banniere argent']!) {
                                    checkIfWantToBuy(
                                        context, "banniere argent");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Pas assez d'âmes",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 0,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.blue,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 22,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: const Color(0xffb3b3b3),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child:
                                              Center(child: argentTextAnimer()),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 23,
                                        ),
                                        width: 100,
                                        height: 70,
                                        child: SimpleShadow(
                                          opacity: 0.7, // Default: 0.5
                                          color: Colors.black, // Default: Black
                                          offset: const Offset(
                                              0, 13), // Default: Offset(2, 2)
                                          sigma: 7,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey,
                                                highlightColor:
                                                    Colors.grey[300]!,
                                                child: Container(
                                                  width: 100,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape
                                                        .rectangle, // Rectangle
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50), // Coins arrondis
                                                    color: Colors.blue,
                                                    border: Border.all(
                                                      color: Colors.green,
                                                      width: 50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 100,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape
                                                      .rectangle, // Rectangle
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50), // Coins arrondis
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                    width: 3,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 30,
                                                    ),
                                                  ],
                                                ),
                                                child: Image.asset(
                                                  'assets/images/logo.png',
                                                  width: 25,
                                                  height: 25,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2.w),
                                          color: const Color(0xffb3b3b3),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              prixItems['banniere argent']
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                              height: 3.h,
                                              child: Image.asset(
                                                'assets/images/ame5.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  int nbAmesDuJoueur =
                                      await getnbAmeUtilisateurCourant() ?? 0;

                                  if (nbAmesDuJoueur >=
                                      prixItems['banniere or']!) {
                                    checkIfWantToBuy(context, "banniere or");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Pas assez d'âmes",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 0,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.blue,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 22,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: const Color(0xffb3b3b3),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Center(child: orTextAnimer()),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 23,
                                        ),
                                        width: 100,
                                        height: 70,
                                        child: SimpleShadow(
                                          opacity: 0.7, // Default: 0.5
                                          color: Colors.black, // Default: Black
                                          offset: const Offset(
                                              0, 13), // Default: Offset(2, 2)
                                          sigma: 7,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Shimmer.fromColors(
                                                baseColor:
                                                    const Color(0xffffbf00),
                                                highlightColor:
                                                    const Color(0xffffdc73),
                                                child: Container(
                                                  width: 100,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape
                                                        .rectangle, // Rectangle
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50), // Coins arrondis
                                                    color: Colors.blue,
                                                    border: Border.all(
                                                      color: Colors.green,
                                                      width: 50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 100,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape
                                                      .rectangle, // Rectangle
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50), // Coins arrondis
                                                  border: Border.all(
                                                    color: Colors.yellow,
                                                    width: 3,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 30,
                                                    ),
                                                  ],
                                                ),
                                                child: Image.asset(
                                                  'assets/images/logo.png',
                                                  width: 25,
                                                  height: 25,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2.w),
                                          color: const Color(0xffb3b3b3),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              prixItems['banniere or']
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                              height: 3.h,
                                              child: Image.asset(
                                                'assets/images/ame5.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: const Color(0xffFA2820),
                          width: 100.w,
                          height: 42,
                          child: Container(
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
                              child: Text(
                                "Vies".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            top: 6,
                          ),
                          child: Center(
                            child: Stack(
                              children: [
                                // Texte avec la bordure noire
                                Text(
                                  "Si vous avez 0 vie vous gagnez 5 vies à minuit",
                                  style: TextStyle(
                                    fontSize: 15,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth =
                                          4 // Épaisseur de la bordure
                                      ..color =
                                          Colors.black, // Couleur de la bordure
                                  ),
                                ),
                                // Texte principal en blanc
                                const Text(
                                  "Si vous avez 0 vie vous gagnez 5 vies à minuit",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/shop/etagereRouge.webp'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          margin: const EdgeInsets.only(
                            top: 4,
                          ),
                          height: 188,
                          width: 390,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  int nbAmesDuJoueur =
                                      await getnbAmeUtilisateurCourant() ?? 0;

                                  if (nbAmesDuJoueur >= prixItems['5 vies']!) {
                                    checkIfWantToBuy(context, "5 vies");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Pas assez d'âmes",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 0,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.blue,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 22,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 90,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: const Color(0xffb3b3b3),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '5 vies'.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 10,
                                        ),
                                        width: 90,
                                        height: 70,
                                        child: SimpleShadow(
                                          opacity: 0.7, // Default: 0.5
                                          color: Colors.black, // Default: Black
                                          offset: const Offset(
                                              0, 13), // Default: Offset(2, 2)
                                          sigma: 7,
                                          child: Container(
                                            width: 100,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 3),
                                            child: Image.asset(
                                              'assets/images/coeur.png',
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: const Color(0xffb3b3b3),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        margin: const EdgeInsets.only(
                                          top: 13,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              prixItems['5 vies'].toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                              height: 3.h,
                                              child: Image.asset(
                                                'assets/images/ame5.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  int nbAmesDuJoueur =
                                      await getnbAmeUtilisateurCourant() ?? 0;

                                  if (nbAmesDuJoueur >= prixItems['20 vies']!) {
                                    checkIfWantToBuy(context, "20 vies");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Pas assez d'âmes",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 0,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.blue,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 22,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 90,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: const Color(0xffb3b3b3),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '20 vies'.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 10,
                                        ),
                                        width: 90,
                                        height: 70,
                                        child: SimpleShadow(
                                          opacity: 0.7, // Default: 0.5
                                          color: Colors.black, // Default: Black
                                          offset: const Offset(
                                              0, 13), // Default: Offset(2, 2)
                                          sigma: 7,
                                          child: Container(
                                            width: 100,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6),
                                            child: Image.asset(
                                              'assets/images/2coeurs.webp',
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2.w),
                                          color: const Color(0xffb3b3b3),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        margin: const EdgeInsets.only(
                                          top: 13,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              prixItems['20 vies'].toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                              height: 3.h,
                                              child: Image.asset(
                                                'assets/images/ame5.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  int nbAmesDuJoueur =
                                      await getnbAmeUtilisateurCourant() ?? 0;

                                  if (nbAmesDuJoueur >= prixItems['50 vies']!) {
                                    checkIfWantToBuy(context, "50 vies");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Pas assez d'âmes",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 0,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.blue,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 22,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 90,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: const Color(0xffb3b3b3),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '50 vies'.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 10,
                                        ),
                                        width: 90,
                                        height: 70,
                                        child: SimpleShadow(
                                          opacity: 0.7, // Default: 0.5
                                          color: Colors.black, // Default: Black
                                          offset: const Offset(
                                              0, 13), // Default: Offset(2, 2)
                                          sigma: 7,
                                          child: Container(
                                            width: 100,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Image.asset(
                                              'assets/images/3coeurs.webp',
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2.w),
                                          color: const Color(0xffb3b3b3),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        margin: const EdgeInsets.only(
                                          top: 13,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              prixItems['50 vies'].toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                              height: 3.h,
                                              child: Image.asset(
                                                'assets/images/ame5.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: const Color(0xff6BFAF1),
                          width: 100.w,
                          height: 42,
                          child: Container(
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
                              child: Text(
                                "Ames".toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/shop/etagereViolet.webp'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          margin: const EdgeInsets.only(
                            top: 8,
                          ),
                          height: 188,
                          width: 390,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _isLoading
                                ? [
                                    const Center(
                                        child: CircularProgressIndicator())
                                  ] // Ajout d'un `Center` pour aligner
                                : _error.isNotEmpty
                                    ? [
                                        Center(child: Text(_error))
                                      ] // Affichage de l'erreur correctement centré
                                    : _products
                                        .map((product) =>
                                            _buildProductTile(product))
                                        .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      top: 5.h, // Positionnement vertical
                      right: 10,
                      child: nbAmes2()),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildProductTile(ProductDetails product) {
    String titre = _getProductTitle(product.id);
    return GestureDetector(
      onTap: () {
        checkIfWantToBuyRealMoney(context, titre, product);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xffb3b3b3),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.only(top: 2),
                child: Center(
                  child: Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 90,
              height: 70,
              child: SimpleShadow(
                opacity: 0.7, // Default: 0.5
                color: Colors.black, // Default: Black
                offset: const Offset(0, 13), // Default: Offset(2, 2)
                sigma: 7,
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Image.asset(
                    _getProductImage(
                        product.id), // Change image based on product
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Container(
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xffb3b3b3),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              margin: const EdgeInsets.only(top: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProductImage(String productId) {
    switch (productId) {
      case 'ames1':
        return 'assets/images/ame5.png';
      case 'ames2':
        return 'assets/images/2ames.webp';
      case 'ames3':
        return 'assets/images/3ames.webp';
      default:
        return 'assets/images/ame5.png';
    }
  }

  String _getProductTitle(String productId) {
    switch (productId) {
      case 'ames1':
        return '100 AMES';
      case 'ames2':
        return '500 AMES';
      case 'ames3':
        return '1200 AMES';
      default:
        return 'X AMES';
    }
  }

  Future<void> checkIfWantToBuy(BuildContext context, String nomItem) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff151692).withOpacity(0.7),
          title: Text(
            "Acheter $nomItem ?",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xff17c983),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff151692).withOpacity(0.9),
                  ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme le dialogue
                  },
                ),
                const SizedBox(width: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff151692).withOpacity(0.9),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Color(0xff17c983)),
                  ),
                  onPressed: () async {
                    Navigator.of(context)
                        .pop(); // Ferme le dialogue avant toute autre action

                    try {
                      await _databaseService.acheterItem(nomItem);
                      Fluttertoast.showToast(
                        msg: "Achat de $nomItem réussi !",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 0,
                        backgroundColor: Colors.black,
                        textColor: Colors.blue,
                        fontSize: 16.0,
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: "Erreur lors de l'achat: $e",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.red,
                        fontSize: 16.0,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> checkIfWantToBuyRealMoney(
      BuildContext context, String nomItem, ProductDetails product) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff151692).withOpacity(0.7),
          title: Text(
            "Acheter $nomItem ?",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xff17c983),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff151692).withOpacity(0.9),
                  ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme le dialogue
                  },
                ),
                const SizedBox(width: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff151692).withOpacity(0.9),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Color(0xff17c983)),
                  ),
                  onPressed: () async {
                    Navigator.of(context)
                        .pop(); // Ferme le dialogue avant toute autre action

                    try {
                      if (Theme.of(context).platform == TargetPlatform.iOS) {
                        _buyProduct(product);
                      } else {
                        _buyProductAndroid(product);
                      }
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: "Erreur de connexion au serveur.",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.red,
                        fontSize: 16.0,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
