import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:test/DataBase/database.dart';
import 'package:test/auth.dart';
import 'package:test/authentification/pseudoScreen.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test/multijoueur/socketService.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  await Firebase.initializeApp(
      name: 'AMQuiz', options: DefaultFirebaseOptions.currentPlatform);
  SocketService();
  runApp(
    ShowCaseWidget(
      builder: (context) => const MyApp(),
    ),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late StreamSubscription<User?> _authStateSubscription;
  bool isDialogVisible = false;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  void _initializePurchaseStream() {
    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      (purchases) async {
        for (var purchase in purchases) {
          await _handlePurchase(purchase);
        }
      },
      onError: (error) {
        Fluttertoast.showToast(
          msg: 'Erreur lors de l\'achat : $error',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.red,
          fontSize: 16.0,
        );
      },
    );
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased) {
      String? transactionId;
      final String? idToken =
          await FirebaseAuth.instance.currentUser?.getIdToken();
      final platform =
          Theme.of(context).platform == TargetPlatform.iOS ? 'apple' : 'google';

      transactionId = platform == 'apple'
          ? purchase.purchaseID
          : purchase.verificationData.serverVerificationData;

      if (transactionId == null) {
        Fluttertoast.showToast(
          msg: "Erreur : transactionId non disponible.",
        );
        return;
      }

      if (platform == 'apple') {
        try {
          final response = await http.post(
            Uri.parse('$urlServeur/validate-transaction'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode({
              'transactionId': transactionId,
              'uid': FirebaseAuth.instance.currentUser!.uid,
              'productId': purchase.productID,
              'platform': platform,
            }),
          );

          if (response.statusCode == 200) {
            await InAppPurchase.instance.completePurchase(purchase);
            Fluttertoast.showToast(
              msg: "Achat validé",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.blue,
              fontSize: 16.0,
            );
          } else {
            Fluttertoast.showToast(
              msg: "Erreur lors de la validation: ${response.body}",
            );
          }
        } catch (e) {
          Fluttertoast.showToast(
            msg: "Erreur réseau : $e",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.red,
            fontSize: 16.0,
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.signOut();
    _initializePurchaseStream();
    WidgetsBinding.instance.addObserver(this);
    // Initialisez la surveillance de la connectivité
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        // Aucune connexion Internet
        _showConnectionLostDialog();
      }
      // Vérifiez si l'utilisateur est connecté
      bool isConnected = result != ConnectivityResult.none;
      // Mettez à jour Firestore en conséquence
      if (!isConnected) {
        DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .updateUserPresence(false);
        print("utilisateur déconnecté internet");
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    _authStateSubscription.cancel();
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          theme: ThemeData(
            textTheme: GoogleFonts.carterOneTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          builder: (context, child) {
            return AccessibilityTools(
              // Configuration pour AMQuiz
              checkSemanticLabels: true, // Vérifie les labels
              checkFontOverflows: true, // Vérifie les débordements de texte
              checkImageLabels: true, // Vérifie les labels d'images
              minimumTapAreas:
                  MinimumTapAreas.material, // Tailles tactiles Material
              buttonsAlignment:
                  ButtonsAlignment.bottomLeft, // Position des outils
              enableButtonsDrag: true, // Permet de déplacer les boutons

              // Configuration des outils de test
              testingToolsConfiguration: const TestingToolsConfiguration(
                enabled: true,
                minTextScale: 0.8,
                maxTextScale: 3.0,
              ),

              // Configuration de l'environnement de test
              testEnvironment: const TestEnvironment(
                visualDensity: VisualDensity.standard,
                textScaleFactor: 1.0,
                boldText: false,
              ),

              child: child!,
            );
          },
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('La connexion a échoué');
              } else if (snapshot.hasData) {
                if (isNewUser) {
                  return const PSeudoScreen(); // Redirigez vers l'écran PseudoScreen pour les nouveaux utilisateurs.
                }
                // Initialisation de la présence de l'utilisateur avec Firestore
                DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                    .setupPresence(FirebaseAuth.instance.currentUser!.uid);

                return MainScreen(2);
              } else {
                return const AuthScreen();
              }
            },
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (state == AppLifecycleState.resumed && currentUser != null) {
      // L'application revient de l'arrière-plan
      print(
          '${currentUser.uid} est reconnecté après être revenu de l’arrière-plan');

      // Mettre à jour la présence de l'utilisateur dans Firestore
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .updateUserPresence(true);

      // Reconnecter le socket si nécessaire
      if (!socket.connected) {
        socket.connect();
      }
      if (!isDialogVisible) {
        // Vérifiez si l'utilisateur est déjà sur MainScreen(2)
        final currentRoute =
            ModalRoute.of(navigatorKey.currentContext!)?.settings.name;

        if (currentRoute != '/mainScreen') {
          // Si ce n'est pas le bon écran, redirigez vers MainScreen(2)
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MainScreen(2, key: UniqueKey()),
              settings: const RouteSettings(name: '/mainScreen'),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } else if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached) &&
        currentUser != null) {
      // L'utilisateur quitte l'application ou la met en arrière-plan
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .updateUserPresence(false);
      socket.disconnect();
      print('${currentUser.uid} utilisateur déconnecté');
    }
  }

  void _showConnectionLostDialog() {
    if (isDialogVisible ||
        navigatorKey.currentState?.overlay?.context == null) {
      return; // Ne rien faire si le dialogue est déjà affiché
    }

    isDialogVisible = true;

    showDialog(
      context: navigatorKey.currentState!.overlay!.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Connexion perdue'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Vous semblez avoir perdu votre connexion Internet.'),
                ],
              ),
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  child: const Text(
                    'Se reconnecter',
                    style: TextStyle(
                      color: Color(0xff151692),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer le dialogue
                    _reconnect();
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      isDialogVisible =
          false; // Réinitialiser l'état lorsque le dialogue est fermé
    });
  }

  void _reconnect() async {
    // Vérifiez l'état de la connectivité immédiatement
    var connectivityResult = await Connectivity().checkConnectivity();

    // Planifiez les actions suivantes sans fermer immédiatement le dialogue
    if (connectivityResult == ConnectivityResult.none) {
      _showConnectionLostDialog();
    } else {
      Navigator.of(context).pop();
    }
  }
}
