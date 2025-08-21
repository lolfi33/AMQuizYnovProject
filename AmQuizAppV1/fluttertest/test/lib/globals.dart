import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test/aventureScreens/onePiece/onePieceAventureScreen.dart';
import 'package:test/mainScreens/datas/datasChestScreen.dart';
import 'package:test/multijoueur/socketService.dart';

String urlServeur = "https://amquizbackend.onrender.com";

bool isNewUser = false;

// Pour notif succes et amis
late Map<String, Map<String, dynamic>>? succesEncours;
late List<Map<String, dynamic>> succesTermine;
ValueNotifier<List<Map<String, dynamic>>> succesTermineNotifier =
    ValueNotifier<List<Map<String, dynamic>>>([]);
ValueNotifier<List<String>> invitationEnCoursNotifier =
    ValueNotifier<List<String>>([]);

// Pour Socket io amis
final socket = SocketService().socket;

ValueNotifier<bool> isDisconnectedNotifier = ValueNotifier(false);

final CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('Users');

// Pour empecher un utilisateur de spam l'openning pour ne pas créer de bug
bool coffreOuLettrePasOuverte = true;

// Image fond écran principal
const String fondPrincipal = 'assets/images/fondEcran/fondEcran3.png';
const String fondPrincipal2 = 'assets/images/fondEcran/fondEcran5.png';
const String fondPrincipal3 = 'assets/images/fondEcran/fondEcran4.png';
const String fondPrincipal4 = 'assets/images/fondEcran/fondEcran2.png';
const String fondPrincipal5 = 'assets/images/fondEcran/fondEcran5.png';

//Couleur bleu alternatif
Color couleurBleuAlternatif = const Color(0xff1616f6);

Color couleurBoutons = const Color(0xff17c983);

// Image étoile vide
String imageEtoile = 'assets/images/emptyStar.png';

// Oeuvre à la une
Widget oeuvreALaUne = const OnePieceAventureScreen();

bool afficherSectionProfil = true;

// Section de la page de profil à afficher (true si on affiche la section profil, false si on affiche la section coups spéciaux)
int currentTabIndex = 0; // onglet actif par défaut

// Booléan audio actif
bool audioActif = true;

// Pour affichier listes bannieres, profils et coups spéciaux
List<Item> profilOP = [];
List<Item> profilNaruto = [];
List<Item> profilMHA = [];

List<Item> banniereOP = [];
List<Item> banniereSNK = [];
List<Item> banniereMHA = [];

// Pour griser les images en ne prenant pas en compte les parties transparentes
const ColorFilter greyscale = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

//Couleur pour animation de texte
// Pour texte type item
var bronzeColors = [
  Colors.brown,
  Colors.brown[300]!,
  Colors.brown[500]!,
  Colors.brown[700]!,
];

var silverColors = [
  Colors.grey,
  Colors.grey[300]!,
  Colors.grey[500]!,
  Colors.grey[700]!,
];

var goldColors = [
  Colors.yellow,
  Colors.yellow[300]!,
  Colors.yellow[500]!,
  Colors.yellow[700]!,
];

void playSound(String filePath) {
  final AudioPlayer player = AudioPlayer();
  player.play(AssetSource(filePath));
}
