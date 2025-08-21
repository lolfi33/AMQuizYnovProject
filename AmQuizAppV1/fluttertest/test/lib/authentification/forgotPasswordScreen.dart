import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/auth.dart';
import 'package:test/globals.dart';
import 'package:test/main.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Entrez votre email pour changer votre mot de passe',
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
                      controller: emailController,
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
                          recevoirMail();
                        },
                        child: Text(
                          'Reçevoir le mail',
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
                      child: Text(
                        'Retour',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(),
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

  Future recevoirMail() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      Fluttertoast.showToast(
          msg: "Email envoyé",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 0,
          backgroundColor: Colors.black,
          textColor: Colors.blue,
          fontSize: 16.0);

      navigatorKey.currentState!.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print(e);

      Fluttertoast.showToast(
          msg: "Ce compte n'existe pas. Il a peut-être était suprrimé.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 0,
          backgroundColor: Colors.black,
          textColor: Colors.blue,
          fontSize: 16.0);

      Navigator.of(context).pop();
    }
  }
}
