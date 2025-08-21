import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreen.dart';
import 'package:test/miniGamesScreens/quizOnline.dart';
import 'package:test/aventureScreens/datas/question.dart';
import 'package:test/widgets/widget.dart';

class VsScreen extends StatefulWidget {
  final String quizName;
  final List<Question> questions;
  final String nomOeuvre;
  final String roomId;
  final String uidEnnemi;

  VsScreen({
    required this.quizName,
    required this.questions,
    required this.nomOeuvre,
    required this.roomId,
    required this.uidEnnemi,
  });

  @override
  _VsScreenState createState() => _VsScreenState();
}

class _VsScreenState extends State<VsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? roomId;
  List<Question> questions = [];

  // Empecher le retour en arriere
  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  void initState() {
    super.initState();

    socket.on('playerLeft2', (_) {
      Fluttertoast.showToast(
        msg: "Votre adversaire a quitté la partie.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 0,
        backgroundColor: Colors.black,
        textColor: Colors.blue,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(2),
        ),
      );
    });

    socket.on('startQuiz', (data) {
      print("top pote");

      questions =
          (data['questions'] as List).map((q) => Question.fromJson(q)).toList();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => QuizOnline(
            questions: questions,
            nomOeuvre: widget.nomOeuvre,
            roomId: widget.roomId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
      print("fefzegrgr");
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    socket.off('startQuiz');
    socket.off('playerLeft2');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Parent de QuizOnline reconstruit");
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        width: double.infinity, // Prend toute la largeur
        height: double.infinity, // Prend toute la hauteur
        color: Color(0xff151692),

        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Stack(alignment: Alignment.center, children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0,
                            _animation.value), // Applique l'animation de rebond
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: 90.w,
                      child: banniereSectionVSScreen(
                          FirebaseAuth.instance.currentUser!.uid),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0,
                            _animation.value), // Applique l'animation de rebond
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: 90.w,
                      child: banniereSectionVSScreen(widget.uidEnnemi),
                    ),
                  )
                ],
              ),
              Image.asset(
                'assets/images/VS-gif-2.gif',
                width: 100.w,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
