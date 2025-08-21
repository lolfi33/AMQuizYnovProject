// Exemple de récupération des données avant d'ajouter l'utilisateur

const admin = require('firebase-admin');

// Fonction pour récupérer un document spécifique dans Firestore
async function getItemDocument(collectionName, documentId) {
  const documentRef = admin.firestore().collection(collectionName).doc(documentId);
  const documentSnapshot = await documentRef.get();
  
  if (documentSnapshot.exists) {
    return documentSnapshot.data();
  } else {
    throw new Error(`Le document avec l'id ${documentId} n'existe pas dans la collection ${collectionName}`);
  }
}

async function getFilteredItems(collectionName, oeuvreValue, typeValue) {
    const collectionRef = admin.firestore().collection(collectionName);
    
    // Appliquer des filtres avec .where()
    const querySnapshot = await collectionRef
      .where('oeuvre', '==', oeuvreValue)
      .where('type', '==', typeValue)
      .get();
  
    if (querySnapshot.empty) {
      console.log(`Aucun document trouvé dans la collection ${collectionName} pour oeuvre=${oeuvreValue} et type=${typeValue}`);
      return [];
    }
  
    return querySnapshot.docs.map(doc => doc.data());
  }


async function createUser(uid, pseudo) {
  try {
    // Récupérer les données pour banniereProfil et autres champs
    const banniereProfil = await getItemDocument('Items', 'zoroBanner'); // Récupère le document "zoro"

    // Récupérer l'item 'zoro'
    const zoro = await getItemDocument('Items', 'zoro');
    // Initialiser la liste d'items en tant que tableau
    const listeItems = [zoro]; // Convertir en tableau
    // Récupérer l'item 'luffy' et l'ajouter au tableau
    const luffyItem = await getItemDocument('Items', 'luffy');
    listeItems.push(luffyItem); // Ajouter l'item à la liste
    const namiItem = await getItemDocument('Items', 'nami');
    listeItems.push(namiItem); //
    const ussopItem = await getItemDocument('Items', 'ussop');
    listeItems.push(ussopItem); // 
    // const coupSpecial = await getItemDocument('CoupSpeciaux', 'arlong'); // Récupérer un coup spécial

    // Créer le document utilisateur avec les données récupérées
    await admin.firestore().collection('Users').doc(uid).set({
      'uidUser': uid,
      'pseudo': pseudo,
      'biographie': 'Je suis nouveau !',
      'titre': 'Baka novice',
      'urlImgProfil': 'assets/images/rond.png',
      'nbLike': 0,
      'nbVie': 5,
      'dateDernierLike': new Date(Date.now() - 24 * 60 * 60 * 1000), // Date d'hier
      'banniereProfil': banniereProfil, 
      'nbAmes': 0,
      'nbCoffreCommun': 0,
      'nbCoffreRare': 0,
      'nbCoffreLegendaire': 0,
      'nbLettreCommun': 0,
      'nbLettreRare': 0,
      'nbLettreLegendaire': 0,
      'amis': [],
      'invitations': [],
      'uidInvitations': [],
      'listeTitres': ['pirate', 'Baka novice', 'apagnan', 'test'],
      'missions': {
          'mission1': {
            'name': 'Finir 10 niveaux dans l\'aventure one piece',
            'total': 10,
            'progress': 0,
            'nbRecompenses': 50,
          },
          'mission2': {
            'name': 'Finir 10 niveaux dans l\'aventure attaque des titans',
            'total': 10,
            'progress': 0,
            'nbRecompenses': 50,
          },
          'mission3': {
            'name': 'Finir 10 niveaux dans l\'aventure my hero academia',
            'total': 10,
            'progress': 0,
            'nbRecompenses': 50,
          },
          'mission4': {
            'name': 'Avoir 3 amis',
            'total': 3,
            'progress': 0,
            'nbRecompenses': 25,
          },
          'mission5': {
            'name': 'Défier un ami sur n\'importe quelle oeuvre',
            'total': 1,
            'progress': 0,
            'nbRecompenses': 10,
          },
          'mission6': {
            'name': 'Gagner 10 quizs en ligne',
            'total': 10,
            'progress': 0,
            'nbRecompenses': 100,
          },
          'mission7': {
            'name': 'Obtenir au moins 10 points au mini-jeu "Qui suis-je ?"',
            'total': 1,
            'progress': 0,
            'nbRecompenses': 30,
          },
          'mission8': {
            'name': 'Obtenir le maximum de points (15) au mini-jeu "Qui suis-je ?"',
            'total': 1,
            'progress': 0,
            'nbRecompenses': 100,
          },
          'mission9': {
            'name': 'Vendre un item',
            'total': 1,
            'progress': 0,
            'nbRecompenses': 25,
          },
          'mission10': {
            'name': 'Changer de biographie',
            'total': 1,
            'progress': 0,
            'nbRecompenses': 10,
          },
          'mission11': {
            'name': 'Changer de titre',
            'total': 1,
            'progress': 0,
            'nbRecompenses': 15,
          },
          'mission12': {
            'name': 'Envoyer un like à un joueur',
            'total': 1,
            'progress': 0,
            'nbRecompenses': 15,
          },
          'mission13': {
            'name': 'Envoyer 3 likes à des joueurs',
            'total': 3,
            'progress': 0,
            'nbRecompenses': 50,
          },
          'mission14': {
            'name': 'Changer de profil',
            'total': 1,
            'progress': 0,
            'nbRecompenses': 15,
          },
          'mission15': {
            'name': 'Changer de banniere',
            'total': 1,
            'progress': 0,
            'nbRecompenses': 15,
          },
          'mission16': {
            'name': 'Acheter un item dans la boutique',
            'total': 1,
            'progress': 0,
            'nbRecompenses': 25,
          },
          'mission17': {
            'name': 'Obtenir 30 étoiles dans l\'aventure one piece',
            'total': 30,
            'progress': 0,
            'nbRecompenses': 100,
          },
          'mission18': {
            'name': 'Obtenir 30 étoiles dans l\'aventure attaque des titans',
            'total': 30,
            'progress': 0,
            'nbRecompenses': 100,
          },
          'mission19': {
            'name': 'Obtenir 30 étoiles dans l\'aventure my hero academia',
            'total': 30,
            'progress': 0,
            'nbRecompenses': 100,
          },
      },
      'presence': true,
      'listeItems': listeItems,
      // 'coupSpecial': coupSpecial,
      // 'listeCoupSpeciaux': [coupSpecial], 
      'recordsOnePiece': [1, 0, 0, 0, 0, 0, 0, 0],
      'recordsMHA': [1, 0, 0, 0, 0, 0, 0, 0],
      'recordsSNK': [1, 0, 0, 0, 0, 0, 0, 0],
    });
    
    console.log('Utilisateur créé avec succès');
  } catch (error) {
    console.error('Erreur lors de la création de l\'utilisateur :', error);
  }
}

// Middleware pour vérifier le token Firebase
const verifyToken = async (req, res, next) => {
  const idToken = req.headers.authorization;
  if (!idToken) {
    return res.status(401).send('Accès non autorisé');
  }

  try {
    const decodedToken = await getAuth().verifyIdToken(idToken);
    req.user = decodedToken; // Utilisateur authentifié
    next();
  } catch (error) {
    return res.status(403).send('Accès interdit');
  }
};

const compareMaps = (map1, map2) => {
  // Vérifier que les deux Maps ont le même nombre de clés
  const map1Keys = Object.keys(map1);
  const map2Keys = Object.keys(map2);

  if (map1Keys.length !== map2Keys.length) {
    return false;
  }

  // Comparer chaque clé et valeur
  for (let key of map1Keys) {
    if (map1[key] !== map2[key]) {
      return false; // Si une seule valeur diffère, les Maps ne sont pas identiques
    }
  }

  return true; // Si aucune différence n'a été trouvée, les Maps sont identiques
};


// Exporter les fonctions
module.exports = {
    createUser,
    getItemDocument,
    getFilteredItems,
    verifyToken,
    compareMaps,
  };