// src/utils/constants.js

const COLLECTION_NAMES = {
  USERS: 'Users',
  ITEMS: 'Items',
  SIGNALEMENTS: 'Signalements',
  COUP_SPECIAUX: 'CoupSpeciaux'
};

const ITEM_PRICES = {
  'profil bronze': 100,
  'profil argent': 200,
  'profil or': 300,
  'banniere bronze': 100,
  'banniere argent': 200,
  'banniere or': 300,
  '5 vies': 100,
  '20 vies': 200,
  '50 vies': 300,
  'banniere du mois': 300,
  'banniere du mois dateFin': '2025-12-31T23:59:59Z',
  'banniere du mois image': 'assets/images/banniere/zoroBanner.png',
};

const CHEST_PROBABILITIES = {
  commun: { commun: 80, rare: 15, legendaire: 5 },
  rare: { commun: 40, rare: 50, legendaire: 10 },
  legendaire: { commun: 10, rare: 45, legendaire: 45 },
};

const SELL_VALUES = {
  profil: {
    commun: 34,
    rare: 68,
    legendaire: 150
  },
  banniere: {
    commun: 68,
    rare: 136,
    legendaire: 300
  }
};

const INITIAL_MISSIONS = {
  mission1: {
    name: 'Finir 10 niveaux dans l\'aventure one piece',
    total: 10,
    progress: 0,
    nbRecompenses: 50,
  },
  mission2: {
    name: 'Finir 10 niveaux dans l\'aventure attaque des titans',
    total: 10,
    progress: 0,
    nbRecompenses: 50,
  },
  mission3: {
    name: 'Finir 10 niveaux dans l\'aventure my hero academia',
    total: 10,
    progress: 0,
    nbRecompenses: 50,
  },
  mission4: {
    name: 'Avoir 3 amis',
    total: 3,
    progress: 0,
    nbRecompenses: 25,
  },
  mission5: {
    name: 'Défier un ami sur n\'importe quelle oeuvre',
    total: 1,
    progress: 0,
    nbRecompenses: 10,
  },
  mission6: {
    name: 'Gagner 10 quizs en ligne',
    total: 10,
    progress: 0,
    nbRecompenses: 100,
  },
  mission7: {
    name: 'Obtenir au moins 10 points au mini-jeu "Qui suis-je ?"',
    total: 1,
    progress: 0,
    nbRecompenses: 30,
  },
  mission8: {
    name: 'Obtenir le maximum de points (15) au mini-jeu "Qui suis-je ?"',
    total: 1,
    progress: 0,
    nbRecompenses: 100,
  },
  mission9: {
    name: 'Vendre un item',
    total: 1,
    progress: 0,
    nbRecompenses: 25,
  },
  mission10: {
    name: 'Changer de biographie',
    total: 1,
    progress: 0,
    nbRecompenses: 10,
  },
  mission11: {
    name: 'Changer de titre',
    total: 1,
    progress: 0,
    nbRecompenses: 15,
  },
  mission12: {
    name: 'Envoyer un like à un joueur',
    total: 1,
    progress: 0,
    nbRecompenses: 15,
  },
  mission13: {
    name: 'Envoyer 3 likes à des joueurs',
    total: 3,
    progress: 0,
    nbRecompenses: 50,
  },
  mission14: {
    name: 'Changer de profil',
    total: 1,
    progress: 0,
    nbRecompenses: 15,
  },
  mission15: {
    name: 'Changer de banniere',
    total: 1,
    progress: 0,
    nbRecompenses: 15,
  },
  mission16: {
    name: 'Acheter un item dans la boutique',
    total: 1,
    progress: 0,
    nbRecompenses: 25,
  },
  mission17: {
    name: 'Obtenir 30 étoiles dans l\'aventure one piece',
    total: 30,
    progress: 0,
    nbRecompenses: 100,
  },
  mission18: {
    name: 'Obtenir 30 étoiles dans l\'aventure attaque des titans',
    total: 30,
    progress: 0,
    nbRecompenses: 100,
  },
  mission19: {
    name: 'Obtenir 30 étoiles dans l\'aventure my hero academia',
    total: 30,
    progress: 0,
    nbRecompenses: 100,
  },
};

module.exports = {
  COLLECTION_NAMES,
  ITEM_PRICES,
  CHEST_PROBABILITIES,
  SELL_VALUES,
  INITIAL_MISSIONS
};