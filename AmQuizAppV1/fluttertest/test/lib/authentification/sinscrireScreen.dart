import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'package:test/globalFunctions.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreen.dart';

class SinscrireScreen extends StatefulWidget {
  final VoidCallback onClickedSignIn;

  const SinscrireScreen({
    super.key,
    required this.onClickedSignIn,
  });

  @override
  State<SinscrireScreen> createState() => _SinscrireScreenState();
}

class _SinscrireScreenState extends State<SinscrireScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKeySignUp = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final mdpController = TextEditingController();
  final pseudoController = TextEditingController();

  final textFieldFocusNode = FocusNode();
  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) {
        return; // If focus is on text field, dont unfocus
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
    pseudoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xff151692),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 25.w,
            ),
            SizedBox(
              height: 1.h,
            ),
            Container(
              child: Text(
                'Créer votre compte',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: couleurBoutons,
                  fontSize: 5.w,
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              child: Form(
                key: _formKeySignUp,
                child: Column(
                  children: [
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Le mail n'est pas renseigné";
                        } else if (!EmailValidator.validate(value)) {
                          return "Cet email n'est pas valide";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: pseudoController,
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
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: mdpController,
                      obscureText: _obscured,
                      focusNode: textFieldFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Mot de passe',
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
                        suffixIcon: GestureDetector(
                          onTap: _toggleObscured,
                          child: Icon(
                            _obscured
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: couleurBoutons,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Le mot de passe n'est pas renseigné";
                        } else if (value.length < 6) {
                          return "Minimum 6 caractères";
                        }
                        return null;
                      },
                    ),
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
                              text: "Conditions d'utilisation",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: couleurBoutons,
                              ),
                            ),
                            const TextSpan(
                              text: " de AMQuiz et sa ",
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
                          FocusScope.of(context).unfocus();
                          if (_formKeySignUp.currentState!.validate()) {
                            inscription();
                          }
                        },
                        child: Text(
                          'S\'inscrire',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 4.5.w,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (!isKeyboardVisible) ...[
                      SizedBox(
                        height: 1.5.h,
                      ),
                      RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color: couleurBoutons,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            text: 'Déjà un compte ?  ',
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = widget.onClickedSignIn,
                                text: 'Se connecter',
                                style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                      ),
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

  Future inscription() async {
    final isValid = _formKeySignUp.currentState!.validate();
    if (!isValid) return;
    showLoading();
    FocusScope.of(context).unfocus();

    try {
      // Envoyer une requête HTTP au backend pour créer l'utilisateur
      final response = await http.post(
        Uri.parse('$urlServeur/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': mdpController.text.trim(),
          'pseudo': pseudoController.text.trim(),
        }),
      );
      hideLoading();
      if (response.statusCode == 201) {
        // Connecter l'utilisateur sur le client
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: mdpController.text.trim(),
          );

          // Rediriger vers la page principale
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScreen(2),
            ),
          );
        } catch (e) {
          print('Erreur lors de la connexion avec Firebase : $e');
          Fluttertoast.showToast(
            msg: "Erreur lors de la connexion : ${e.toString()}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        // Décoder le message d'erreur renvoyé par le serveur
        final responseData = jsonDecode(response.body);
        String errorMessage =
            responseData['error'] ?? 'Erreur lors de la création du compte';
        print(errorMessage);
        // Afficher le message d'erreur avec Fluttertoast
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
