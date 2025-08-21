const express = require('express');
const userController = require('../controllers/userController');
const authMiddleware = require('../middlewares/authMiddleware');
const { sanitizeInputs, validateUserOwnership, validateRequiredFields, validateDataTypes } = require('../middlewares/validationMiddleware');

const router = express.Router();

// Toutes les routes nécessitent une authentification
router.use(authMiddleware);
router.use(sanitizeInputs);

// Routes de mise à jour du profil
router.post('/update-biographie', 
  validateRequiredFields(['biographie']),
  userController.updateBiography
);

router.post('/update-titre',
  validateRequiredFields(['titre']),
  userController.updateTitle
);

router.post('/update-pdp',
  validateRequiredFields(['urlImgProfil']),
  userController.updateProfilePicture
);

router.post('/update-banniere',
  validateRequiredFields(['banniereProfil']),
  userController.updateBanner
);

// Route pour envoyer un like
router.post('/update-like',
  validateRequiredFields(['uidUserQuiARecuLeLike']),
  userController.sendLike
);

// Route pour mettre à jour la présence
router.post('/update-presence',
  validateRequiredFields(['isOnline']),
  validateDataTypes({ isOnline: 'boolean' }),
  userController.updatePresence
);

// Route pour perdre une vie
router.post('/perdre-vies',
  userController.loseLife
);

// Routes pour les records
router.post('/update-records-onepiece',
  validateRequiredFields(['indexRecord', 'nouveauRecord']),
  validateDataTypes({ indexRecord: 'number', nouveauRecord: 'number' }),
  (req, res) => {
    req.body.recordType = 'recordsOnePiece';
    userController.updateRecords(req, res);
  }
);

router.post('/update-records-snk',
  validateRequiredFields(['indexRecord', 'nouveauRecord']),
  validateDataTypes({ indexRecord: 'number', nouveauRecord: 'number' }),
  (req, res) => {
    req.body.recordType = 'recordsSNK';
    userController.updateRecords(req, res);
  }
);

router.post('/update-records-mha',
  validateRequiredFields(['indexRecord', 'nouveauRecord']),
  validateDataTypes({ indexRecord: 'number', nouveauRecord: 'number' }),
  (req, res) => {
    req.body.recordType = 'recordsMHA';
    userController.updateRecords(req, res);
  }
);

// Routes pour débloquer les niveaux
router.post('/debloque-prochaine-ile-onepiece',
  validateRequiredFields(['indexRecord']),
  validateDataTypes({ indexRecord: 'number' }),
  (req, res) => {
    req.body.recordType = 'recordsOnePiece';
    userController.unlockNextLevel(req, res);
  }
);

router.post('/debloque-prochaine-ile-snk',
  validateRequiredFields(['indexRecord']),
  validateDataTypes({ indexRecord: 'number' }),
  (req, res) => {
    req.body.recordType = 'recordsSNK';
    userController.unlockNextLevel(req, res);
  }
);

router.post('/debloque-prochaine-ile-mha',
  validateRequiredFields(['indexRecord']),
  validateDataTypes({ indexRecord: 'number' }),
  (req, res) => {
    req.body.recordType = 'recordsMHA';
    userController.unlockNextLevel(req, res);
  }
);

// Routes pour les missions de jeu
router.post('/gagnerQuizEnLigne',
  userController.completeOnlineQuiz
);

router.post('/gagner10ptsQuiSuisJe',
  userController.completeWhoAmI10Points
);

router.post('/gagner15ptsQuiSuisJe',
  userController.completeWhoAmI15Points
);

// Route pour supprimer le compte
router.delete('/supprimer-compte/:uid',
  validateUserOwnership,
  userController.deleteAccount
);

module.exports = router;