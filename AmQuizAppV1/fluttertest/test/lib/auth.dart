import 'package:flutter/material.dart';
import 'package:test/authentification/connexionScreen.dart';
import 'package:test/authentification/sinscrireScreen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
      ? ConnexionScreen(onClickedSignUp: toggle)
      : SinscrireScreen(onClickedSignIn: toggle);

  void toggle() => setState(() => isLogin = !isLogin);
}
