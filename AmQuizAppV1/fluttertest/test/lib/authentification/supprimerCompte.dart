import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:test/auth.dart';
import 'package:test/globals.dart';

class SupprimerCompte extends StatefulWidget {
  const SupprimerCompte({super.key});

  @override
  State<SupprimerCompte> createState() => _SupprimerCompteState();
}

class _SupprimerCompteState extends State<SupprimerCompte> {
  final _formKey = GlobalKey<FormState>();
  final mdpController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  bool _obscured = true;

  @override
  void dispose() {
    super.dispose();
    mdpController.dispose();
    textFieldFocusNode.dispose();
  }

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) {
        return;
      }
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xff151692),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 2.w,
                right: 2.w,
              ),
              child: Center(
                child: Text(
                  "Veuillez confirmer votre identité pour pouvoir supprimer votre compte",
                  style: TextStyle(
                    fontSize: 4.5.w,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (requiresPassword()) // Afficher uniquement si un mot de passe est requis
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
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
                          }
                          return null;
                        },
                        controller: mdpController,
                        obscureText: _obscured,
                        focusNode: textFieldFocusNode,
                      ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(35.w, 7.h),
                            backgroundColor: couleurBoutons,
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: const Text(
                            'Annuler',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(35.w, 7.h),
                            backgroundColor: couleurBoutons,
                          ),
                          onPressed: () {
                            if (requiresPassword()) {
                              if (_formKey.currentState!.validate()) {
                                reConnexionEtSuprCompte();
                              }
                            } else {
                              reConnexionEtSuprCompte();
                            }
                          },
                          child: const Text(
                            'Supprimer mon compte',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool requiresPassword() {
    final user = FirebaseAuth.instance.currentUser!;
    return user.providerData.any((info) => info.providerId == 'password');
  }

  Future<void> reConnexionEtSuprCompte() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final providerId = user.providerData.first.providerId;

      // Réauthentification selon le fournisseur
      if (providerId == 'password') {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: mdpController.text.trim(),
        );
        await user.reauthenticateWithCredential(credential);
      } else if (providerId == 'google.com') {
        final googleUser = await GoogleSignIn().signIn();
        final googleAuth = await googleUser!.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Supprimer l'utilisateur
      String uid = user.uid;
      String? idToken = await user.getIdToken();

      // Suppression des données dans Firestore
      final response = await http.delete(
        Uri.parse('$urlServeur/api/users/supprimer-compte/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        await user.delete();
        await FirebaseAuth.instance.signOut();
        Fluttertoast.showToast(
          msg: "Compte supprimé",
          backgroundColor: Colors.black,
          textColor: Colors.blue,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Erreur lors de la suppression du compte",
          backgroundColor: Colors.black,
          textColor: Colors.red,
        );
        print('Erreur lors de la suppression des données utilisateur.');
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: "Erreur : $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
