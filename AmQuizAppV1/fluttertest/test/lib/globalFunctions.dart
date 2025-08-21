import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/globalFunctionsDataBase.dart';
import 'package:test/globals.dart';
import 'package:test/mainScreens/datas/datasChestScreen.dart';
import 'package:test/mainScreens/datas/datasFriends.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}

int sellValue(Item item) {
  int sellValue = 0;

  if (item.type == ItemType.profil) {
    if (item.rarity == ItemRarity.commun) {
      sellValue = 34;
    } else if (item.rarity == ItemRarity.rare) {
      sellValue = 68;
    } else if (item.rarity == ItemRarity.legendaire) {
      sellValue = 150;
    }
  } else if (item.type == ItemType.banniere) {
    if (item.rarity == ItemRarity.commun) {
      sellValue = 68;
    } else if (item.rarity == ItemRarity.rare) {
      sellValue = 136;
    } else if (item.rarity == ItemRarity.legendaire) {
      sellValue = 300;
    }
  }

  return sellValue;
}

int nbEtoilesAventure(int record) {
  if (record > 99) {
    return 3;
  } else if (record > 89) {
    return 2;
  } else if (record > 79) {
    return 1;
  }
  return 0;
}

// Pour notif amis et succes
getDataListeSucces() async {
  Map<String, dynamic>? missions = await getMissions();
  succesEncours = {};
  succesTermine = [];
  if (missions != null) {
    // Iterate over each mission
    missions.forEach((key, missionData) {
      if (missionData['total'] != missionData['progress']) {
        succesEncours![key] = {
          'name': missionData['name'],
          'progress': missionData['progress'],
          'total': missionData['total'],
          'nbRecompenses': missionData['nbRecompenses']
        };
      } else {
        succesTermine.add({
          'key': key, // Ajout de la clé de la mission
          'name': missionData['name'],
          'nbRecompenses': missionData['nbRecompenses'],
        });
      }
    });
  }
  succesTermineNotifier.value = succesTermine;
}

getDataInvitationsAndFriends() async {
  myUidInvitations = [];
  await usersCollection
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    final dynamic invitationsData =
        (documentSnapshot.data() as Map<String, dynamic>)['invitations'];

    if (invitationsData is List<dynamic>) {
      // Convertir chaque élément de la liste en String
      myInvitations =
          invitationsData.map((dynamic item) => item.toString()).toList();
    } else {
      // Si les données ne sont pas une liste, initialiser myInvitations comme une liste vide
      myInvitations = ["test"];
    }
  });
  await usersCollection
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    final dynamic friendsData =
        (documentSnapshot.data() as Map<String, dynamic>)['amis'];

    if (friendsData is List<dynamic>) {
      // Convertir chaque élément de la liste en String
      myFriends = friendsData.map((dynamic item) => item.toString()).toList();
    } else {
      // Si les données ne sont pas une liste, initialiser myInvitations comme une liste vide
      myFriends = ["test"];
    }
  });
  await usersCollection
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    final dynamic uidInvitationsData =
        (documentSnapshot.data() as Map<String, dynamic>)['uidInvitations'];

    if (uidInvitationsData is List<dynamic>) {
      // Convertir chaque élément de la liste en String
      myUidInvitations =
          uidInvitationsData.map((dynamic item) => item.toString()).toList();
    } else {
      // Si les données ne sont pas une liste, initialiser myInvitations comme une liste vide
      myUidInvitations = [];
    }
  });
  invitationEnCoursNotifier.value = myUidInvitations;
}
