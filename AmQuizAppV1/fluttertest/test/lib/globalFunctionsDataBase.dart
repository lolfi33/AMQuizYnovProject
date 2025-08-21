import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test/datas/datasCoupsSpeciaux.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreens/datas/datasChestEnvelop.dart';
import 'package:test/mainScreens/datas/datasChestScreen.dart';

Color colorAudioButton(bool actif) {
  if (actif) {
    return couleurBoutons;
  } else {
    return const Color(0xffBD2A2E);
  }
}

// On vérifie que le pseudo existe bien avan d'ajouter un ami
Future<bool> userExists(String username) async =>
    (await FirebaseFirestore.instance
            .collection("Users")
            .where("pseudo", isEqualTo: username)
            .get())
        .docs
        .isNotEmpty;

// On vérifie que l'utilisateur ne s'ajoute pas lui même en ami
Future<bool> userIsIsSelf(String username) async {
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("Users")
      .where("uidUser", isEqualTo: currentUserUid)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    // L'utilisateur avec le pseudo spécifié existe dans la collection
    // Vous pouvez comparer d'autres propriétés si nécessaire

    // Exemple de comparaison basique du pseudo
    if (querySnapshot.docs.first["pseudo"] == username) {
      return true;
    } else {
      return false;
    }
  } else {
    // Aucun utilisateur avec le pseudo spécifié n'a été trouvé
    return false;
  }
}

// On vérifie que l'utilisateur n'ajoute pas qlq qu'il a déja en ami
Future<bool> userDejaAmi(String pseudoAmi) async {
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("Users")
      .where("uidUser", isEqualTo: currentUserUid)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    // L'utilisateur avec le pseudo spécifié existe dans la collection
    // Vous pouvez comparer d'autres propriétés si nécessaire

    // Utiliser la méthode contains pour vérifier si pseudoAmi est présent dans la liste "amis"
    List<dynamic> amisList = querySnapshot.docs.first["amis"];
    if (amisList.contains(pseudoAmi)) {
      return true;
    } else {
      return false;
    }
  } else {
    // Aucun utilisateur avec le pseudo spécifié n'a été trouvé
    return false;
  }
}

Future<bool> userDejaInvit(String pseudoAmi) async {
  String? pseudoCourant = await getPseudoUtilisateurCourant();

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("Users")
      .where("pseudo", isEqualTo: pseudoAmi)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    // L'utilisateur avec le pseudo spécifié existe dans la collection
    // Vous pouvez comparer d'autres propriétés si nécessaire

    // Utiliser la méthode contains pour vérifier si pseudoCourant est présent dans la liste "invitations"
    List<dynamic> invitListAmi = querySnapshot.docs.first["invitations"];
    if (invitListAmi.contains(pseudoCourant)) {
      return true;
    } else {
      return false;
    }
  } else {
    // Aucun utilisateur avec le pseudo spécifié n'a été trouvé
    return false;
  }
}

// récuperer l'uid en fonction du pseudo
Future<String> getUidByPseudo(String username) async {
  try {
    // Effectuer une requête pour obtenir le document où "pseudo" est égal au pseudo
    QuerySnapshot querySnapshot =
        await usersCollection.where('pseudo', isEqualTo: username).get();

    // Vérifiez s'il y a des documents correspondants
    if (querySnapshot.docs.isNotEmpty) {
      // Récupérez le premier document trouvé
      DocumentSnapshot document = querySnapshot.docs.first;
      var testFieldValue = document['uidUser'];
      return testFieldValue.toString();
    } else {
      print('Aucun document correspondant trouvé.');
    }
  } catch (e) {
    print('Erreur lors de la récupération du uid par le pseudo: $e');
  }
  return "erreur lors de la récupération du uid par le pseudo";
}

// récuperer la présence en fonction du pseudo
Future<bool> getPresenceByPseudo(String username) async {
  try {
    // Effectuer une requête pour obtenir le document où "pseudo" est égal au pseudo
    QuerySnapshot querySnapshot =
        await usersCollection.where('pseudo', isEqualTo: username).get();

    // Vérifiez s'il y a des documents correspondants
    if (querySnapshot.docs.isNotEmpty) {
      // Récupérez le premier document trouvé
      DocumentSnapshot document = querySnapshot.docs.first;
      bool presence = document['presence'];
      return presence;
    } else {
      print('Aucun document correspondant trouvé.');
    }
  } catch (e) {
    print('Erreur lors de la lecture du champ "test": $e');
  }
  return false;
}

Future<String> getPseudoByUid(String uid) async {
  try {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['pseudo']; // Assurez-vous que le champ est bien "pseudo"
    }
    return "Inconnu";
  } catch (e) {
    print("Erreur lors de la récupération du pseudo pour l'UID $uid : $e");
    return "Erreur";
  }
}

//Récupérer le pseudo de l'utilistateur courant
Future<String?> getPseudoUtilisateurCourant() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "pseudo"
        String? pseudo = userSnapshot['pseudo'];
        return pseudo;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération du pseudo : $e');
    return null;
  }
}

Future<int?> getNbViesUtilisateurCourant() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "pseudo"
        int? nbVie = userSnapshot['nbVie'];
        return nbVie;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération du pseudo : $e');
    return null;
  }
}

Future<int?> getRecordOnePieceAIndex(int index) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la liste "recordsOnePiece"
        List<dynamic>? records =
            userSnapshot['recordsOnePiece'] as List<dynamic>?;

        // Vérifier que la liste existe et que l'index est valide
        if (records != null && index >= 0 && index < records.length) {
          // Récupérer la valeur à l'index spécifié
          return records[index] as int?;
        } else {
          print('Index invalide ou liste inexistante');
          return null;
        }
      } else {
        print('Document utilisateur introuvable');
        return null; // Le document "Users" n'existe pas
      }
    } else {
      print('Utilisateur non connecté');
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération du record : $e');
    return null;
  }
}

Future<int?> getRecordSNKAIndex(int index) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la liste "recordsOnePiece"
        List<dynamic>? records = userSnapshot['recordsSNK'] as List<dynamic>?;

        // Vérifier que la liste existe et que l'index est valide
        if (records != null && index >= 0 && index < records.length) {
          // Récupérer la valeur à l'index spécifié
          return records[index] as int?;
        } else {
          print('Index invalide ou liste inexistante');
          return null;
        }
      } else {
        print('Document utilisateur introuvable');
        return null; // Le document "Users" n'existe pas
      }
    } else {
      print('Utilisateur non connecté');
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération du record : $e');
    return null;
  }
}

Future<int?> getRecordMHAAIndex(int index) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la liste "recordsOnePiece"
        List<dynamic>? records = userSnapshot['recordsMHA'] as List<dynamic>?;

        // Vérifier que la liste existe et que l'index est valide
        if (records != null && index >= 0 && index < records.length) {
          // Récupérer la valeur à l'index spécifié
          return records[index] as int?;
        } else {
          print('Index invalide ou liste inexistante');
          return null;
        }
      } else {
        print('Document utilisateur introuvable');
        return null; // Le document "Users" n'existe pas
      }
    } else {
      print('Utilisateur non connecté');
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération du record : $e');
    return null;
  }
}

// pour savoir si le joueur courant a deja fait le tuto
getTutoJoueurCourant() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "pseudo"
        bool? hasDoneTuto = userSnapshot['hasDoneTuto'];
        return hasDoneTuto;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération du tuto : $e');
    return null;
  }
}

// pour avoir le titre du joueur courant
getTitreJoueurCourant() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "pseudo"
        String? titre = userSnapshot['titre'];
        return titre;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération du titre : $e');
    return null;
  }
}

getListeTitresJoueurCourant() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "listeTitres"
        List<dynamic>? listeTitresDynamic = userSnapshot['listeTitres'];
        if (listeTitresDynamic != null) {
          // Convertir chaque élément de la liste en chaîne de caractères
          List<String> listeTitres =
              listeTitresDynamic.map((title) => title.toString()).toList();
          return listeTitres;
        } else {
          return null; // La liste de titres est nulle
        }
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération du titre : $e');
    return null;
  }
}

Future<Map<String, dynamic>?> getMissions() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? missions = userSnapshot.get('missions');
        return missions ?? {}; // Return the missions or an empty map
      } else {
        return null; // No document found
      }
    } else {
      return null; // User is not authenticated
    }
  } catch (e) {
    print('Error fetching missions: $e');
    return null;
  }
}

Future<Map<String, List<Item>>?> getListeProfils() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        Map<String, List<Item>> listesProfils = {};

        // Fonction pour convertir dynamique en List<Item>
        List<Item> convertToListItem(List<dynamic>? list) {
          return list
                  ?.map((itemMap) =>
                      Item.fromMap(itemMap as Map<String, dynamic>))
                  .toList() ??
              [];
        }

        final listeItems = userSnapshot.get('listeItems') as List<dynamic>?;

        // Filtrer les éléments dont le champ "oeuvre" est "onePiece"
        final listeProfilOnePiece = listeItems?.where((item) {
          return item['oeuvre'] == 'onePiece' && item['type'] == 'profil';
        }).toList();

        // Filtrer les éléments dont le champ "oeuvre" est "onePiece"
        final listeProfilSNK = listeItems?.where((item) {
          return item['oeuvre'] == 'SNK' && item['type'] == 'profil';
        }).toList();

        // Filtrer les éléments dont le champ "oeuvre" est "onePiece"
        final listeProfilMHA = listeItems?.where((item) {
          return item['oeuvre'] == 'MHA' && item['type'] == 'profil';
        }).toList();

        // Convertir et ajouter à listesProfils
        listesProfils['listeProfilOnePiece'] =
            convertToListItem(listeProfilOnePiece);
        listesProfils['listeProfilNaruto'] = convertToListItem(listeProfilSNK);
        listesProfils['listeProfilMHA'] = convertToListItem(listeProfilMHA);

        return listesProfils.isNotEmpty ? listesProfils : null;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération des profils : $e');
    return null;
  }
}

Future<Map<String, List<Item>>?> getListeBannieres() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        Map<String, List<Item>> listesBannieres = {};

        // Fonction pour convertir dynamique en List<Item>
        List<Item> convertToListItem(List<dynamic>? list) {
          return list
                  ?.map((itemMap) =>
                      Item.fromMap(itemMap as Map<String, dynamic>))
                  .toList() ??
              [];
        }

        final listeItems = userSnapshot.get('listeItems') as List<dynamic>?;

        // Filtrer les éléments dont le champ "oeuvre" est "onePiece"
        final listeBanniereOnePiece = listeItems?.where((item) {
          return item['oeuvre'] == 'onePiece' && item['type'] == 'banniere';
        }).toList();

        // Filtrer les éléments dont le champ "oeuvre" est "onePiece"
        final listeBanniereSNK = listeItems?.where((item) {
          return item['oeuvre'] == 'SNK' && item['type'] == 'banniere';
        }).toList();

        // Filtrer les éléments dont le champ "oeuvre" est "onePiece"
        final listeBanniereMHA = listeItems?.where((item) {
          return item['oeuvre'] == 'MHA' && item['type'] == 'banniere';
        }).toList();

        // Convertir et ajouter à listesBannieres
        listesBannieres['listeBanniereOnePiece'] =
            convertToListItem(listeBanniereOnePiece);
        listesBannieres['listeBanniereNaruto'] =
            convertToListItem(listeBanniereSNK);
        listesBannieres['listeBanniereMHA'] =
            convertToListItem(listeBanniereMHA);

        return listesBannieres.isNotEmpty ? listesBannieres : null;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération des bannières : $e');
    return null;
  }
}

Future<List<CoupSpeciaux>?> getListeCoupsSpeciauxO() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la liste des coups spéciaux depuis le document utilisateur
        List<dynamic> listeCoupsSpeciaux =
            userSnapshot.get('listeCoupSpeciaux') as List<dynamic>;

        // Fonction pour convertir un map en objet CoupSpeciaux
        List<CoupSpeciaux> convertToListCoupSpeciaux(List<dynamic>? list) {
          return list
                  ?.map((coupMap) =>
                      CoupSpeciaux.fromMap(coupMap as Map<String, dynamic>))
                  .toList() ??
              [];
        }

        // Filtrer les coups spéciaux pour ne garder que ceux de type "offensif"
        List<CoupSpeciaux> coupsSpeciauxOffensifs = convertToListCoupSpeciaux(
          listeCoupsSpeciaux.where((coup) {
            return (coup['type'] == 'offensif');
          }).toList(),
        );

        return coupsSpeciauxOffensifs.isNotEmpty
            ? coupsSpeciauxOffensifs
            : null;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération des coups spéciaux offensifs : $e');
    return null;
  }
}

Future<List<CoupSpeciaux>?> getListeCoupsSpeciauxD() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la liste des coups spéciaux depuis le document utilisateur
        List<dynamic> listeCoupsSpeciaux =
            userSnapshot.get('listeCoupSpeciaux') as List<dynamic>;

        // Fonction pour convertir un map en objet CoupSpeciaux
        List<CoupSpeciaux> convertToListCoupSpeciaux(List<dynamic>? list) {
          return list
                  ?.map((coupMap) =>
                      CoupSpeciaux.fromMap(coupMap as Map<String, dynamic>))
                  .toList() ??
              [];
        }

        // Filtrer les coups spéciaux pour ne garder que ceux de type "offensif"
        List<CoupSpeciaux> coupsSpeciauxOffensifs = convertToListCoupSpeciaux(
          listeCoupsSpeciaux.where((coup) {
            return (coup['type'] == 'defensif');
          }).toList(),
        );

        return coupsSpeciauxOffensifs.isNotEmpty
            ? coupsSpeciauxOffensifs
            : null;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération des coups spéciaux defensif : $e');
    return null;
  }
}

//Récupérer le profil actuel de l'utilistateur courant
Future<String?> getProfilActuelUtilisateurCourant() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "pseudo"
        String? profilActuel = userSnapshot['urlImgProfil'];
        return profilActuel;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération du profil actuel : $e');
    return null;
  }
}

//Récupérer le profil actuel de l'utilistateur courant
Future<String?> getProfilActuelAdversaire(String uidAdversaire) async {
  try {
    // Référence au document "Users" correspondant dans Firestore
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('Users').doc(uidAdversaire);

    // Obtenir le document "Users" depuis Firestore
    DocumentSnapshot userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      // Récupérer la valeur du champ "pseudo"
      String? profilActuel = userSnapshot['urlImgProfil'];
      return profilActuel;
    } else {
      return null; // Le document "Users" n'existe pas
    }
  } catch (e) {
    print(
        'Erreur lors de la récupération du profil actuel de ladversaire : $e');
    return null;
  }
}

//Récupérer la banniere actuel de l'utilistateur courant
Future<String?> getBanniereActuelUtilisateurCourant() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "pseudo"
        String? banniereActuel = userSnapshot['banniereProfil']['imageUrl'];
        return banniereActuel;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération de la bannière actuel : $e');
    return null;
  }
}

// Retourne un tableau de 5 uid existant aléatoire
Future<List<String>> getRandomUid() async {
  List<String> uids = [];
  Set<int> randomIndices;
  try {
    // Accès à la collection Firestore
    var collection = FirebaseFirestore.instance.collection(
        'Users'); // Remplacez 'users' par le nom de votre collection
    var querySnapshot = await collection.get();

    // Vérifiez s'il y a suffisamment de documents
    if (querySnapshot.docs.length < 2) {
      print('Pas assez de documents pour sélectionner des UID aléatoires.');
      return [];
    } else if (querySnapshot.docs.length < 5) {
      // Génération de x indices uniques pour sélectionner des documents aléatoires
      randomIndices = _generateRandomIndices(
          querySnapshot.docs.length, querySnapshot.docs.length);
    } else {
      // Génération de 5 indices uniques pour sélectionner des documents aléatoires
      randomIndices = _generateRandomIndices(querySnapshot.docs.length, 5);
    }

    // Extraction des UID en utilisant les indices aléatoires
    for (var index in randomIndices) {
      if (querySnapshot.docs[index].id !=
          FirebaseAuth.instance.currentUser?.uid) {
        uids.add(querySnapshot.docs[index].id);
      }
    }
    return uids;
  } catch (e) {
    print('Erreur lors de la récupération de 5 UID aléatoires: $e');
    return []; // Retourner une liste vide en cas d'erreur
  }
}

// Fonction pour générer un ensemble de indices uniques
Set<int> _generateRandomIndices(int max, int count) {
  var rnd = Random();
  Set<int> indices = {};
  while (indices.length < count) {
    indices.add(rnd.nextInt(max));
  }
  return indices;
}

//Récupérer la date du dernier like envoyé par l'utilistateur courant
Future<DateTime?> getDateDernierLikeUtilisateurCourant() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "pseudo"
        DateTime? dateDernierLike = userSnapshot['dateDernierLike'].toDate();
        return dateDernierLike;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération de la dateDernierLike : $e');
    return null;
  }
}

// récuperer les infos de l'ami en fonction du pseudo
Future<List<String>> getFriendsInfosByPseudo(String username) async {
  try {
    // Effectuer une requête pour obtenir le document où "pseudo" est égal au pseudo
    QuerySnapshot querySnapshot =
        await usersCollection.where('pseudo', isEqualTo: username).get();

    // Vérifiez s'il y a des documents correspondants
    if (querySnapshot.docs.isNotEmpty) {
      // Récupérez le premier document trouvé
      DocumentSnapshot document = querySnapshot.docs.first;
      String urlImgProfil = document['urlImgProfil'];
      String urlImgBanniere = document['banniereProfil']['imageUrl'];
      List<String> listeInfosAmi = [urlImgProfil, urlImgBanniere];
      return listeInfosAmi;
    } else {
      print('Aucun document correspondant trouvé.');
    }
  } catch (e) {
    print('Erreur lors de la récupération des infos de l\'ami $e');
  }
  return [];
}

void getDataChestScreen() async {
  await usersCollection
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    coffreCommun.nbExemplaire =
        (documentSnapshot.data() as Map<String, dynamic>)['nbCoffreCommun'] ??
            0;
    coffreRare.nbExemplaire =
        (documentSnapshot.data() as Map<String, dynamic>)['nbCoffreRare'] ?? 0;
    coffreLeg.nbExemplaire = (documentSnapshot.data()
            as Map<String, dynamic>)['nbCoffreLegendaire'] ??
        0;
    enveloppeCommune.nbExemplaire =
        (documentSnapshot.data() as Map<String, dynamic>)['nbLettreCommun'] ??
            0;
    enveloppeRare.nbExemplaire =
        (documentSnapshot.data() as Map<String, dynamic>)['nbLettreRare'] ?? 0;
    enveloppeLeg.nbExemplaire = (documentSnapshot.data()
            as Map<String, dynamic>)['nbLettreLegendaire'] ??
        0;
  });
}

//Récupérer le nb d'ame de l'utilistateur courant
Future<int?> getnbAmeUtilisateurCourant() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "nbAme"
        int? nbAme = userSnapshot['nbAmes'];
        return nbAme;
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération du nombre dames : $e');
    return null;
  }
}

//Récupérer records
Future<List<int>?> getRecordsOnePiece() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "recordsOnePiece" et convertir en List<int>
        List<dynamic>? recordsDynamic = userSnapshot['recordsOnePiece'];
        if (recordsDynamic != null) {
          return recordsDynamic.map((record) => record as int).toList();
        } else {
          return null;
        }
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération recordsOnePiece : $e');
    return null;
  }
}

//Récupérer records
Future<List<int>?> getRecordsMHA() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "recordsOnePiece" et convertir en List<int>
        List<dynamic>? recordsDynamic = userSnapshot['recordsMHA'];
        if (recordsDynamic != null) {
          return recordsDynamic.map((record) => record as int).toList();
        } else {
          return null;
        }
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération recordsMHA : $e');
    return null;
  }
}

//Récupérer records
Future<List<int>?> getRecordsSNK() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtenir l'ID de l'utilisateur
      String userId = user.uid;

      // Référence au document "Users" correspondant dans Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Obtenir le document "Users" depuis Firestore
      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // Récupérer la valeur du champ "recordsOnePiece" et convertir en List<int>
        List<dynamic>? recordsDynamic = userSnapshot['recordsSNK'];
        if (recordsDynamic != null) {
          return recordsDynamic.map((record) => record as int).toList();
        } else {
          return null;
        }
      } else {
        return null; // Le document "Users" n'existe pas
      }
    } else {
      return null; // L'utilisateur n'est pas connecté
    }
  } catch (e) {
    print('Erreur lors de la récupération recordsOnePiece : $e');
    return null;
  }
}

Future<List<Item>> getItemsCommun() async {
  try {
    // Référence à la collection "Items"
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Items')
        .where('rarity', isEqualTo: 'commun')
        .get();

    List<Item> items = [];

    for (var doc in querySnapshot.docs) {
      try {
        // Tente de convertir chaque document en un objet Item
        Item item = Item.fromMap(doc.data() as Map<String, dynamic>);
        items.add(item);
      } catch (e) {
        // Affiche les données du document qui posent problème
        print(
            '❌ Erreur lors de la conversion du document ${doc.id} : ${doc.data()}');
        print('⚠️ Détail de l\'erreur : $e');
      }
    }

    return items;
  } catch (e) {
    print('❌ Erreur générale lors de la récupération des items communs : $e');
    return [];
  }
}

Future<List<Item>> getItemsRare() async {
  try {
    // Référence à la collection "Items"
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Items')
        .where('rarity', isEqualTo: 'rare')
        .get();

    // Convertir les documents en une liste d'objets Item
    List<Item> items = querySnapshot.docs
        .map((doc) => Item.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return items;
  } catch (e) {
    print('Erreur lors de la récupération des items rares : $e');
    return [];
  }
}

Future<List<Item>> getItemsLegendaire() async {
  try {
    // Référence à la collection "Items"
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Items')
        .where('rarity', isEqualTo: 'legendaire')
        .get();

    // Convertir les documents en une liste d'objets Item
    List<Item> items = querySnapshot.docs
        .map((doc) => Item.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return items;
  } catch (e) {
    print('Erreur lors de la récupération des items légendaires : $e');
    return [];
  }
}
