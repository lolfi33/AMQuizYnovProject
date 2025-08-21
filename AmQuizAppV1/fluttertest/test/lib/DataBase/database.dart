import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test/DataBase/lifecycleEventHandler.dart';
import 'package:test/aventureScreens/datas/question.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreens/datas/datasChestScreen.dart';
import 'package:test/mainScreens/datas/datasFriends.dart';
import 'package:http/http.dart' as http;
import 'package:test/miniGamesScreens/datas/datasMainTrainingScreen.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid = "nimporte"});

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');

  // ==================== MÉTHODES QUIZ ====================
  Future<List<Question>> getQuestions(String category, String fileName) async {
    try {
      // Effectuer une requête HTTP pour récupérer le fichier JSON
      final response = await http.get(
        Uri.parse('$urlServeur/quiz/$category/$fileName'),
      );

      if (response.statusCode == 200) {
        // Décoder le JSON reçu depuis le serveur
        final body = json.decode(response.body);

        // Convertir la liste de Map en une liste de Question
        List<Question> questions =
            body.map<Question>(Question.fromJson).toList();

        // Mélanger les questions pour les obtenir dans un ordre aléatoire
        questions.shuffle();

        // Si vous souhaitez limiter à un certain nombre de questions (par exemple, 20)
        int nombreDeQuestions = min(20, questions.length);
        return questions.sublist(0, nombreDeQuestions);
      } else {
        // Gérer les erreurs de la requête HTTP
        throw Exception(
            'Erreur lors du chargement du quiz : ${response.statusCode}');
      }
    } catch (error) {
      // Gérer les erreurs de connexion
      throw Exception('Erreur lors de la requête : $error');
    }
  }

  Future<List<Question>> getQuestionsAventure(
      String category, String fileName) async {
    try {
      // Effectuer une requête HTTP pour récupérer le fichier JSON
      final response = await http.get(
        Uri.parse('$urlServeur/quiz/$category/$fileName'),
      );

      if (response.statusCode == 200) {
        // Décoder le JSON reçu depuis le serveur
        final body = json.decode(response.body);

        // Convertir la liste de Map en une liste de Question
        List<Question> questions =
            body.map<Question>(Question.fromJson).toList();

        // Si vous souhaitez limiter à un certain nombre de questions (par exemple, 20)
        int nombreDeQuestions = min(20, questions.length);
        return questions.sublist(0, nombreDeQuestions);
      } else {
        // Gérer les erreurs de la requête HTTP
        throw Exception(
            'Erreur lors du chargement du quiz : ${response.statusCode}');
      }
    } catch (error) {
      // Gérer les erreurs de connexion
      throw Exception('Erreur lors de la requête : $error');
    }
  }

  Future<List<Indice>> getIndices(String category, String fileName) async {
    try {
      // Effectuer une requête HTTP pour récupérer le fichier JSON
      final response = await http.get(
        Uri.parse('$urlServeur/quiz/$category/$fileName'),
      );

      if (response.statusCode == 200) {
        // Décoder le JSON reçu depuis le serveur
        final body = json.decode(response.body);

        // Convertir la liste de Map en une liste d'Indice
        List<Indice> indices =
            body.map<Indice>((json) => Indice.fromJson(json)).toList();

        // Mélanger les indices pour les obtenir dans un ordre aléatoire
        indices.shuffle();

        // Si vous souhaitez limiter à un certain nombre d'indices (par exemple, 6)
        int nombreDIndices = min(6, indices.length);
        return indices.sublist(0, nombreDIndices);
      } else {
        // Gérer les erreurs de la requête HTTP
        throw Exception(
            'Erreur lors du chargement des indices : ${response.statusCode}');
      }
    } catch (error) {
      // Gérer les erreurs de connexion
      throw Exception('Erreur lors de la requête : $error');
    }
  }

  // ==================== MÉTHODES USERS ====================
  Future<void> envoyerSignalement(String raison, String uidJoueurQuiAEteSignale,
      BuildContext context) async {
    try {
      // Récupérer le token d'authentification
      final String? idToken =
          await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/api/users/signaler-utilisateur'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uidJoueur': FirebaseAuth.instance.currentUser!.uid,
          'uidJoueurQuiAEteSignale': uidJoueurQuiAEteSignale,
          'raison': raison,
        }),
      );

      if (response.statusCode == 200) {
        print('Signalement envoyé avec succès');
        Fluttertoast.showToast(
            msg: "Signalement envoyé",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 0,
            backgroundColor: Colors.black,
            textColor: Colors.blue,
            fontSize: 16.0);
      } else {
        print('Erreur lors de l\'envoi du signalement : ${response.body}');
      }
    } catch (e) {
      print('Erreur : $e');
    }
  }

  Future<void> updateTuto() async {
    try {
      // Obtenir le token d'authentification Firebase
      final String? idToken =
          await FirebaseAuth.instance.currentUser?.getIdToken();

      // Construire la requête
      final response = await http.post(
        Uri.parse('$urlServeur/api/users/update-tuto'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        print('tuto maj');
      } else {
        print('Erreur lors de la mise à jour du tuto : ${response.body}');
      }
    } catch (error) {
      print('Erreur de connexion au serveur : $error');
    }
  }

  Future<void> updateRecordsOnePiece(int indexRecord, int nouveauRecord) async {
    try {
      // Obtenir le token d'authentification Firebase
      final String? idToken =
          await FirebaseAuth.instance.currentUser?.getIdToken();

      // Construire la requête
      final response = await http.post(
        Uri.parse('$urlServeur/api/users/update-records-onepiece'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'indexRecord': indexRecord,
          'nouveauRecord': nouveauRecord,
        }),
      );

      if (response.statusCode == 200) {
        print('Records mis à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour des records : ${response.body}');
      }
    } catch (error) {
      print('Erreur de connexion au serveur : $error');
    }
  }

  Future<void> updateRecordsSNK(int indexRecord, int nouveauRecord) async {
    try {
      // Obtenir le token d'authentification Firebase
      final String? idToken =
          await FirebaseAuth.instance.currentUser?.getIdToken();

      // Construire la requête
      final response = await http.post(
        Uri.parse('$urlServeur/api/users/update-records-snk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'indexRecord': indexRecord,
          'nouveauRecord': nouveauRecord,
        }),
      );

      if (response.statusCode == 200) {
        print('Records mis à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour des records : ${response.body}');
      }
    } catch (error) {
      print('Erreur de connexion au serveur : $error');
    }
  }

  Future<void> updateRecordsMHA(int indexRecord, int nouveauRecord) async {
    try {
      // Obtenir le token d'authentification Firebase
      final String? idToken =
          await FirebaseAuth.instance.currentUser?.getIdToken();

      // Construire la requête
      final response = await http.post(
        Uri.parse('$urlServeur/api/users/update-records-mha'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'indexRecord': indexRecord,
          'nouveauRecord': nouveauRecord,
        }),
      );

      if (response.statusCode == 200) {
        print('Records mis à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour des records : ${response.body}');
      }
    } catch (error) {
      print('Erreur de connexion au serveur : $error');
    }
  }

  Future<void> debloqueProchaineIleOnePiece(
      int indexRecord, int realScore) async {
    // Obtenir le token d'authentification Firebase
    final String? idToken =
        await FirebaseAuth.instance.currentUser?.getIdToken();
    int? recordIleSuivante = await getRecordOnePieceAIndex(indexRecord + 1);
    if (realScore > 49 && recordIleSuivante == 0) {
      try {
        // Construire la requête
        final response = await http.post(
          Uri.parse('$urlServeur/api/users/debloque-prochaine-ile-onepiece'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'uid': FirebaseAuth.instance.currentUser!.uid,
            'indexRecord': indexRecord,
          }),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String? nouvelleBanniere = data['nouvelleBanniere'];
          if (nouvelleBanniere != null) {
            Fluttertoast.showToast(
              msg: "Vous avez obtenu la bannière : $nouvelleBanniere",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.blue,
              fontSize: 16.0,
            );
          }
          print('Île débloquée avec succès');
        } else {
          print('Erreur lors du déblocage de l\'île : ${response.body}');
        }
      } catch (error) {
        print('Erreur de connexion au serveur : $error');
      }
    }
    if (realScore < 50) {
      try {
        final response = await http.post(
          Uri.parse('$urlServeur/api/users/perdre-vies'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'uid': FirebaseAuth.instance.currentUser!.uid,
          }),
        );

        if (response.statusCode == 200) {
          print('Vie perdue avec succès');
        } else {
          print('Erreur lors de la perte de vie : ${response.body}');
        }
      } catch (error) {
        print('Erreur de connexion au serveur : $error');
      }
    }
  }

  Future<void> debloqueProchaineIleSNK(int indexRecord, int realScore) async {
    // Obtenir le token d'authentification Firebase
    final String? idToken =
        await FirebaseAuth.instance.currentUser?.getIdToken();
    int? recordIleSuivante = await getRecordSNKAIndex(indexRecord + 1);
    if (realScore > 49 && recordIleSuivante == 0) {
      try {
        // Construire la requête
        final response = await http.post(
          Uri.parse('$urlServeur/api/users/debloque-prochaine-ile-snk'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'uid': FirebaseAuth.instance.currentUser!.uid,
            'indexRecord': indexRecord,
          }),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String? nouvelleBanniere = data['nouvelleBanniere'];
          if (nouvelleBanniere != null) {
            Fluttertoast.showToast(
              msg: "Vous avez obtenu la bannière : $nouvelleBanniere",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.blue,
              fontSize: 16.0,
            );
          }
          print('Île débloquée avec succès');
        } else {
          print('Erreur lors du déblocage de l\'île : ${response.body}');
        }
      } catch (error) {
        print('Erreur de connexion au serveur : $error');
      }
    }
    if (realScore < 50) {
      try {
        final response = await http.post(
          Uri.parse('$urlServeur/api/users/perdre-vies'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'uid': FirebaseAuth.instance.currentUser!.uid,
          }),
        );

        if (response.statusCode == 200) {
          print('Vie perdue avec succès');
        } else {
          print('Erreur lors de la perte de vie : ${response.body}');
        }
      } catch (error) {
        print('Erreur de connexion au serveur : $error');
      }
    }
  }

  Future<void> debloqueProchaineIleMHA(int indexRecord, int realScore) async {
    final String? idToken =
        await FirebaseAuth.instance.currentUser?.getIdToken();
    int? recordIleSuivante = await getRecordMHAAIndex(indexRecord + 1);

    if (realScore > 49 && recordIleSuivante == 0) {
      try {
        final response = await http.post(
          Uri.parse('$urlServeur/api/users/debloque-prochaine-ile-mha'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'uid': FirebaseAuth.instance.currentUser!.uid,
            'indexRecord': indexRecord,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String? gainedTitle = data['gainedTitle'];

          if (gainedTitle != null) {
            print('Titre gagné : $gainedTitle');
            // Afficher une notification ou un message pour informer l'utilisateur
            Fluttertoast.showToast(
                msg: 'Titre obtenu : $gainedTitle',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 0,
                backgroundColor: Colors.black,
                textColor: Colors.blue,
                fontSize: 16.0);
          }
          print('Prochaine île débloquée avec succès');
        } else {
          print('Erreur lors du déblocage de l\'île : ${response.body}');
        }
      } catch (error) {
        print('Erreur de connexion au serveur : $error');
      }
    }

    if (realScore < 50) {
      try {
        final response = await http.post(
          Uri.parse('$urlServeur/api/users/perdre-vies'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'uid': FirebaseAuth.instance.currentUser!.uid,
          }),
        );

        if (response.statusCode == 200) {
          print('Vie perdue avec succès');
        } else {
          print('Erreur lors de la perte de vie : ${response.body}');
        }
      } catch (error) {
        print('Erreur de connexion au serveur : $error');
      }
    }
  }

  Future<void> updateTitre(String nouveauTitre) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? idToken = await user?.getIdToken();

      // Envoyer une requête POST à l'API du serveur
      final response = await http.post(
        Uri.parse('$urlServeur/api/users/update-titre'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // Ajouter le token à l'en-tête
        },
        body: jsonEncode({
          'titre': nouveauTitre,
        }),
      );

      if (response.statusCode == 200) {
        print('Titre mis à jour avec succès');
      } else {
        print('Erreur: ${response.body}');
      }
    } catch (e) {
      print('Titre lors de la mise à jour : $e');
    }
  }

  Future<void> updatePhotoDeProfil(String nouvellePdp) async {
    try {
      // Obtenir le token d'authentification Firebase de l'utilisateur
      User? user = FirebaseAuth.instance.currentUser;
      String? idToken = await user?.getIdToken();

      // Envoyer une requête POST à l'API du serveur
      final response = await http.post(
        Uri.parse('$urlServeur/api/users/update-pdp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // Ajouter le token à l'en-tête
        },
        body: jsonEncode({
          'urlImgProfil': nouvellePdp,
        }),
      );

      if (response.statusCode == 200) {
        print('Pdp mis à jour avec succès');
      } else {
        print('Erreur: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la pdp : $e');
    }
  }

  Future<void> updateBanniere(Item nouvelleBaniere) async {
    try {
      Map<String, dynamic> nouvelleBaniereMapper = nouvelleBaniere.toMap();
      // Obtenir le token d'authentification Firebase de l'utilisateur
      User? user = FirebaseAuth.instance.currentUser;
      String? idToken = await user?.getIdToken();

      // Envoyer une requête POST à l'API du serveur
      final response = await http.post(
        Uri.parse('$urlServeur/api/users/update-banniere'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // Ajouter le token à l'en-tête
        },
        body: jsonEncode({
          'banniereProfil': nouvelleBaniereMapper,
        }),
      );

      if (response.statusCode == 200) {
        print('Bannière mise à jour avec succès');
      } else {
        print('Erreur: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la bannière : $e');
    }
  }

  Future<void> updateLike(String uidUserQuiARecuLeLike) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? idToken = await user.getIdToken();

        // Envoyer la requête POST au serveur
        final response = await http.post(
          Uri.parse('$urlServeur/api/users/update-like'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'uidUserQuiARecuLeLike': uidUserQuiARecuLeLike,
          }),
        );

        if (response.statusCode == 200) {
          print('Like mis à jour avec succès');
        } else {
          print('Erreur: ${response.body}');
        }
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du like: $e');
    }
  }

  void setupPresence(String userId) {
    // Écoute les changements d'état de l'application.
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachedCallback: () async {
          await updateUserPresence(false);
        },
        resumeCallback: () async {
          await updateUserPresence(true);
        },
      ),
    );
  }

  Future<void> updateUserPresence(bool isOnline) async {
    try {
      // Récupère le token d'authentification Firebase
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      // Envoie la requête au serveur pour mettre à jour la présence
      final response = await http.post(
        Uri.parse('$urlServeur/api/users/update-presence'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'isOnline': isOnline,
        }),
      );

      if (response.statusCode == 200) {
        print('Présence mise à jour avec succès');
      } else {
        print(
            'Erreur lors de la mise à jour de la présence : ${response.body}');
      }
    } catch (e) {
      print('Exception lors de la mise à jour de la présence : $e');
    }
  }

  // ==================== MÉTHODES SHOP ====================
  Future<void> acheterItem(String nomItem) async {
    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/api/shop/acheter-item'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'nomItem': nomItem,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Achat réussi : ${data['message']}");
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Erreur lors de l\'achat');
      }
    } catch (error) {
      print('Exception lors de l\'achat: $error');
      rethrow; // Rethrow pour que l'UI puisse gérer l'erreur
    }
  }

  Future<Map<String, dynamic>> recupererPrix() async {
    try {
      final response =
          await http.get(Uri.parse('$urlServeur/api/shop/get-prices'));
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la récupération des prix');
      }
    } catch (e) {
      throw Exception('Exception lors de la récupération des prix : $e');
    }
  }

  Future<Item?> ouvrirCoffre(String chestType) async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/api/shop/open-coffre'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'chestType': chestType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final item = data['item'];
        // Convertir la réponse en un objet Item
        return Item.fromJson(item);
      } else {
        print('Erreur lors de l\'ouverture: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Exception lors de l\'ouverture: $error');
      return null;
    }
  }

  Future<Item?> ouvrirEnveloppe(String chestType) async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/api/shop/open-enveloppe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'chestType': chestType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final item = data['item'];
        // Convertir la réponse en un objet Item
        return Item.fromJson(item);
      } else {
        print('Erreur lors de l\'ouverture: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Exception lors de l\'ouverture: $error');
      return null;
    }
  }

  Future<void> vendreItem(Item item) async {
    try {
      // Récupère le token d'authentification Firebase
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      // Convertir l'objet `ItemOeuvre` en chaîne (si nécessaire)
      String oeuvre = item.oeuvre.toString(); // S'assurer que c'est une chaîne

      // Envoie la requête au serveur pour vendre l'item
      final response = await http.post(
        Uri.parse('$urlServeur/api/shop/sell-item'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid, // ID utilisateur
          'itemId': item.name, // Identifiant de l'item
          'itemType': item.type == ItemType.profil
              ? 'profil'
              : 'banniere', // Type de l'item
          'oeuvre': oeuvre, // Convertir `ItemOeuvre` en chaîne
        }),
      );

      if (response.statusCode == 200) {
        // Le serveur renvoie le montant de la vente
        final data = jsonDecode(response.body);
        final int sellValue = data['sellValue'];

        // Afficher le montant de la vente ou mettre à jour l'UI
        print("Item vendu pour $sellValue âmes");

        // Mettre à jour l'état de l'interface ici si nécessaire
      } else {
        // Gérer les erreurs
        print('Erreur lors de la vente: ${response.body}');
      }
    } catch (error) {
      print('Exception lors de la vente: $error');
    }
  }

  // ==================== MÉTHODES FRIENDS ====================
  Future<void> addUserListeFriends(String? uidAmi, String pseudoAmi) async {
    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/api/friends/add-friend'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uidAmi': uidAmi,
          'pseudoAmi': pseudoAmi,
        }),
      );

      if (response.statusCode == 200) {
        print('Ami ajouté avec succès');
        myFriends.add(pseudoAmi);
      } else {
        print('Erreur lors de l\'ajout de l\'ami : ${response.body}');
      }
    } catch (e) {
      print('Exception lors de l\'ajout de l\'ami : $e');
    }
  }

  Future<void> supprimerAmi(String uidAmi, int indexPseudoFriend) async {
    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/api/friends/delete-friend'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uidAmi': uidAmi, // UID de l'ami à supprimer
        }),
      );

      if (response.statusCode == 200) {
        // Supprimer l'ami de la liste côté client après succès du serveur
        myFriends.removeAt(indexPseudoFriend);
      } else {
        print('Erreur lors de la suppression de l\'ami : ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'appel à la suppression d\'ami : $e');
    }
  }

  Future<void> envoyerInvitation(String uidAmi) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? idToken = await user.getIdToken();

        // Envoyer la requête POST au serveur
        final response = await http.post(
          Uri.parse('$urlServeur/api/friends/envoyer-invitation'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'uidAmi': uidAmi,
          }),
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: response.body,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.blue,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: response.body,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.blue,
            fontSize: 16.0,
          );
        }
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de l\'invitation: $e');
    }
  }

  Future<void> deleteUserListeInvitations(int indexPseudoInvite) async {
    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/api/friends/delete-invitation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'indexInvitation': indexPseudoInvite,
        }),
      );

      if (response.statusCode == 200) {
        print('Invitation supprimée avec succès');
        myInvitations.removeAt(indexPseudoInvite);
      } else {
        print(
            'Erreur lors de la suppression de l\'invitation : ${response.body}');
      }
    } catch (e) {
      print('Exception lors de la suppression de l\'invitation : $e');
    }
  }

  // ==================== MÉTHODES MISSIONS ====================
  Future<void> gagnerQuizEnLigne() async {
    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/gagnerQuizEnLigne'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid,
        }),
      );

      if (response.statusCode == 200) {
        print('Mission mise à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour : ${response.body}');
      }
    } catch (e) {
      print('Exception lors de l\'appel de la route /gagnerQuizEnLigne : $e');
    }
  }

  Future<void> gagnerPtsQuiSuiJe(int nbPoints) async {
    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (nbPoints > 9) {
        final response = await http.post(
          Uri.parse('$urlServeur/gagner10ptsQuiSuisJe'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'uid': FirebaseAuth.instance.currentUser!.uid,
          }),
        );
        if (response.statusCode == 200) {
          print('Mission mise à jour avec succès');
        } else {
          print('Erreur lors de la mise à jour : ${response.body}');
        }
      }
      if (nbPoints > 14) {
        final response = await http.post(
          Uri.parse('$urlServeur/gagner15ptsQuiSuisJe'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'uid': FirebaseAuth.instance.currentUser!.uid,
          }),
        );
        if (response.statusCode == 200) {
          print('Mission mise à jour avec succès');
        } else {
          print('Erreur lors de la mise à jour : ${response.body}');
        }
      }
    } catch (e) {
      print('Exception lors de l\'appel de la route /gagnerQuizEnLigne : $e');
    }
  }

  Future<void> faireQuizAvecAmi() async {
    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/faireQuizAvecAmi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid,
        }),
      );

      if (response.statusCode == 200) {
        print('Mission mise à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour : ${response.body}');
      }
    } catch (e) {
      print('Exception lors de l\'appel de la route /gagnerQuizEnLigne : $e');
    }
  }

  Future<void> faireQuizMultiAvecAmi() async {
    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/faireQuizMultiAvecAmi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid,
        }),
      );

      if (response.statusCode == 200) {
        print('Mission mise à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour : ${response.body}');
      }
    } catch (e) {
      print('Exception lors de l\'appel de la route /gagnerQuizEnLigne : $e');
    }
  }

  Future<void> faireQuizMulti(String themeQuiz) async {
    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/faireQuizMulti'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'themeQuiz': themeQuiz,
        }),
      );

      if (response.statusCode == 200) {
        print('Mission mise à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour : ${response.body}');
      }
    } catch (e) {
      print('Exception lors de l\'appel de la route /gagnerQuizEnLigne : $e');
    }
  }

  Future<void> jouerQuiSuiJe() async {
    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$urlServeur/jouerQuiSuiJe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': FirebaseAuth.instance.currentUser!.uid,
        }),
      );

      if (response.statusCode == 200) {
        print('Mission mise à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour : ${response.body}');
      }
    } catch (e) {
      print('Exception lors de l\'appel de la route /gagnerQuizEnLigne : $e');
    }
  }

  Future<void> obtenirRecompense(
      String userId, String missionKey, int nbRecompenses) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? idToken = await user.getIdToken();

        // Envoyer la requête POST au serveur
        final response = await http.post(
          Uri.parse('$urlServeur/obtenirRecompense'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'userId': userId,
            'missionKey': missionKey,
            'nbRecompenses': nbRecompenses,
          }),
        );

        if (response.statusCode == 200) {
          print('Récompenses obtenues avec succès');
        } else {
          print('Erreur: ${response.body}');
        }
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}
