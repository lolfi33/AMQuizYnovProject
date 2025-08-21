import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:test/authentification/forgotPasswordScreen.dart';
import 'package:http/http.dart' as http;
import 'package:test/authentification/pseudoScreen.dart';
import 'package:test/globalFunctions.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreen.dart';
import 'package:test/mainScreens/mainPage.dart';

class ConnexionScreen extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const ConnexionScreen({
    super.key,
    required this.onClickedSignUp,
  });

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final mdpController = TextEditingController();
  Stream<QuerySnapshot<Map<String, dynamic>>> usersDatas =
      FirebaseFirestore.instance.collection('Users').snapshots();

  final textFieldFocusNode = FocusNode();
  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) {
        return;
      }
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  void showLoading() {
    _scaffoldKey.currentState?.showBottomSheet(
      (context) => Center(
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void hideLoading() {
    Navigator.of(_scaffoldKey.currentContext!).pop();
  }

  @override
  void dispose() {
    emailController.dispose();
    mdpController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xff151692),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              semanticLabel: 'Logo',
              width: 30.w,
            ),
            SizedBox(height: 2.h),
            Container(
              child: Text(
                'Quiz animés/mangas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: couleurBoutons,
                  fontSize: 5.w,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: emailController,
                      hintText: 'Email',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Le mail n'est pas renseigné";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    _buildTextField(
                      controller: mdpController,
                      hintText: 'Mot de passe',
                      obscureText: _obscured,
                      suffixIcon: GestureDetector(
                        onTap: _toggleObscured,
                        child: Icon(
                          _obscured
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: couleurBoutons,
                          semanticLabel: 'Visibility',
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Le mot de passe n'est pas renseigné";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),
                    _buildButton(
                        label: 'Connexion',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            connexion(emailController.text.trim(),
                                mdpController.text.trim());
                          }
                        },
                        backgroundColor: couleurBoutons,
                        textColor: Colors.white),
                    SizedBox(height: 1.5.h),
                    GestureDetector(
                      child: const SizedBox(
                        height: 50,
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: couleurBoutons,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        text: 'Pas de compte ?  ',
                        children: [
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = widget.onClickedSignUp,
                            text: 'S\'inscrire',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isKeyboardVisible) ...[
                      SizedBox(height: 1.5.h),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            text: "J'accepte les ",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    final Uri toLaunch = Uri(
                                      scheme: 'https',
                                      host: 'drive.google.com',
                                      path:
                                          'file/d/1XR9DRlxMCGvWvSfm_smGFnQzksW4N8Zf/view',
                                    );
                                    launchInBrowser(toLaunch);
                                  },
                                text: "Conditions d'utilisation ",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: couleurBoutons,
                                ),
                              ),
                              const TextSpan(
                                text: "de AMQuiz et sa ",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    final Uri toLaunch = Uri(
                                      scheme: 'https',
                                      host: 'drive.google.com',
                                      path:
                                          'file/d/1PsAWqfg4g0vDsa_m7mxsujbS0XhWBhfe/view',
                                    );
                                    launchInBrowser(toLaunch);
                                  },
                                text: "Politique de confidentialité",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: couleurBoutons,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 3.h),
                    if (!isKeyboardVisible) ...[
                      _buildButton(
                          label: 'Continuer avec Google',
                          icon: Image.asset('assets/images/google.webp',
                              semanticLabel: 'Logo google', height: 24),
                          onPressed: () async {
                            try {
                              UserCredential userCredential =
                                  await signInWithGoogle();
                              print("userCredential: $userCredential");
                              print(
                                  "userCredential.user: ${userCredential.user}");

                              if (userCredential.user == null) {
                                throw Exception(
                                    "L'utilisateur n'a pas pu être authentifié.");
                              }

                              print(
                                  "UID utilisateur : ${userCredential.user!.uid}");
                              // Vérifier si l'utilisateur a déjà un compte
                              bool hasAccount = await checkIfUserHasAccount(
                                  userCredential.user!.uid);

                              print("hasAccount: $hasAccount");
                              if (hasAccount) {
                                print("Redirection vers MainScreen(2)");
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => MainScreen(2)),
                                  (route) =>
                                      false, // Supprime toutes les routes précédentes
                                );
                              } else {
                                print("Redirection vers PSeudoScreen");
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PSeudoScreen()),
                                );
                              }
                            } catch (e) {
                              print(
                                  "Erreur lors de la connexion avec Google : $e");
                            }
                          },
                          backgroundColor: Colors.white,
                          textColor: Colors.black),
                    ],
                    SizedBox(height: 1.5.h),
                    if (!isKeyboardVisible) ...[
                      _buildButton(
                        label: 'Continuer avec Apple',
                        icon: Image.asset(
                          'assets/images/apple.webp',
                          height: 24,
                          semanticLabel: 'Logo apple',
                        ),
                        onPressed: () async {
                          try {
                            UserCredential userCredential =
                                await signInWithApple();

                            if (userCredential.user == null) {
                              throw Exception(
                                  "L'utilisateur n'a pas pu être authentifié.");
                            }

                            // Vérifiez si l'utilisateur a déjà un compte
                            bool hasAccount = await checkIfUserHasAccount(
                                userCredential.user!.uid);

                            if (hasAccount) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => MainScreen(2)),
                                (route) => false,
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const PSeudoScreen()),
                              );
                            }
                          } catch (e) {
                            print(
                                "Erreur lors de la connexion avec Apple : $e");
                          }
                        },
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                      )
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> connexion(String email, String password) async {
    showLoading();
    FocusScope.of(context).unfocus();

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final token = await userCredential.user!.getIdToken();
      final response = await http
          .post(
            Uri.parse('$urlServeur/api/auth/verify-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 10));

      hideLoading();

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen(2)),
        );
      } else {
        print("Erreur serveur : ${response.body}");
        Fluttertoast.showToast(
            msg: "Erreur serveur",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 0,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } on FirebaseAuthException catch (e) {
      hideLoading();
      Fluttertoast.showToast(
          msg: "Mail ou mot de passe incorrect",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 0,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      hideLoading();
      Fluttertoast.showToast(
          msg: "Erreur : $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 0,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      // Obtenir les identifiants Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId:
              'com.example.amquiz.web', // Remplacez par votre ID de service Apple
          redirectUri: Uri.parse(
            'https://amquizapp.firebaseapp.com/__/auth/handler', // Remplacez par votre URL de redirection
          ),
        ),
        state: 'example-state',
      );

      // Créer les credentials OAuth pour Firebase
      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Authentification avec Firebase
      return await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
    } catch (e) {
      throw Exception("Erreur lors de la connexion avec Apple : $e");
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      print("GoogleUser: $googleUser");
      if (googleUser == null) {
        throw Exception("L'utilisateur a annulé la connexion.");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          "GoogleAuth - AccessToken: ${googleAuth.accessToken}, IdToken: ${googleAuth.idToken}");

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception(
            "Les informations d'authentification Google sont incomplètes.");
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      throw Exception("Erreur lors de la connexion avec Google : $e");
    }
  }

  Future<bool> checkIfUserHasAccount(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (!userDoc.exists) {
        isNewUser = true; // Indiquez que l'utilisateur est nouveau.
      } else {
        isNewUser = false;
      }
      return userDoc.exists;
    } catch (e) {
      print("Erreur dans checkIfUserHasAccount: $e");
      return false; // Valeur par défaut en cas d'erreur
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white60),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0.2.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: couleurBoutons, width: 0.2.w),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  Widget _buildButton(
      {required String label,
      required VoidCallback onPressed,
      Widget? icon,
      required Color backgroundColor,
      required Color textColor}) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: backgroundColor),
        icon: icon ?? const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 4.5.w,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
