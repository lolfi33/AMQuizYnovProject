import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/auth.dart';
import 'package:test/globals.dart';
import 'package:test/main.dart';
import 'package:test/mainScreen.dart';
import 'package:http/http.dart' as http;

class PSeudoScreen extends StatefulWidget {
  const PSeudoScreen({super.key});

  @override
  State<PSeudoScreen> createState() => _PSeudoScreenState();
}

class _PSeudoScreenState extends State<PSeudoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  final pseudoController = TextEditingController();

  @override
  void dispose() {
    pseudoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xff151692),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 30.w,
            ),
            SizedBox(
              height: 2.h,
            ),
            Container(
              child: Text(
                'Choisissez un pseudo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: couleurBoutons,
                  fontSize: 4.w,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
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
                      controller: pseudoController,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: couleurBoutons,
                        ),
                        onPressed: () {
                          inscriptionPseudo();
                        },
                        child: Text(
                          'Créer mon compte',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 4.5.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 1.5.h,
                    ),
                    GestureDetector(
                        child: const Text(
                          'Retour',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () async {
                          await FirebaseAuth.instance
                              .signOut(); // Déconnecte l'utilisateur de Firebase
                          await GoogleSignIn()
                              .signOut(); // Déconnecte l'utilisateur de Google
                          navigatorKey.currentState!.pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const AuthScreen(),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future inscriptionPseudo() async {
    if (_formKey.currentState!.validate()) {
      showLoading();
      FocusScope.of(context).unfocus();

      try {
        // Récupérer l'utilisateur actuellement connecté avec Google
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception("L'utilisateur n'est pas authentifié.");
        }

        final String? idToken = await user.getIdToken();
        if (idToken == null) {
          throw Exception("Impossible d'obtenir le token d'authentification.");
        }

        // Envoyer une requête HTTP au backend pour ajouter l'utilisateur
        final response = await http.post(
          Uri.parse('$urlServeur/api/auth/register-google'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken'
          },
          body: jsonEncode({
            'uid': user.uid,
            'email': user.email,
            'pseudo': pseudoController.text.trim(),
          }),
        );

        hideLoading();

        if (response.statusCode == 201) {
          // Utilisateur ajouté avec succès, redirection vers MainScreen
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen(2)),
          );
        } else {
          // Gestion des erreurs renvoyées par le backend
          final responseData = jsonDecode(response.body);
          String errorMessage =
              responseData['error'] ?? 'Erreur lors de la création du compte';

          Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        hideLoading();
        print('Erreur globale lors de la création du compte : $e');
        Fluttertoast.showToast(
          msg: "Erreur lors de la création du compte : ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  void hideLoading() {
    Navigator.of(_scaffoldKey.currentContext!).pop();
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
}
