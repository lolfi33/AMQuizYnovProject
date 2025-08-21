const express = require('express');
const missionController = require('../controllers/missionController');
const authMiddleware = require('../middlewares/authMiddleware');
const { sanitizeInputs, validateRequiredFields, validateDataTypes } = require('../middlewares/validationMiddleware');

const router = express.Router();

// Toutes les routes nécessitent une authentification
router.use(authMiddleware);
router.use(sanitizeInputs);

// Routes pour récupérer les missions
router.get('/user-missions',
  missionController.getUserMissions
);

router.get('/progress',
  missionController.getAllMissionsProgress
);

router.get('/progress/:missionKey',
  missionController.getMissionProgress
);

router.get('/completed',
  missionController.getCompletedMissions
);

router.get('/available-rewards',
  missionController.getAvailableRewards
);

// Route pour réclamer une récompense
router.post('/obtenirRecompense',
  validateRequiredFields(['missionKey']),
  missionController.claimReward
);

// Routes pour mettre à jour les missions
router.post('/update-progress',
  validateRequiredFields(['missionKey']),
  missionController.updateMissionProgress
);

router.post('/reset-mission',
  validateRequiredFields(['missionKey']),
  missionController.resetMission
);

// Routes spécifiques pour différents types de missions
router.post('/update-adventure',
  validateRequiredFields(['adventureType']),
  missionController.updateAdventureMission
);

router.post('/update-score',
  validateRequiredFields(['score', 'gameType']),
  validateDataTypes({ score: 'number' }),
  missionController.updateScoreMission
);

router.post('/update-stars',
  validateRequiredFields(['stars', 'adventureType']),
  validateDataTypes({ stars: 'number' }),
  missionController.updateStarMission
);



module.exports = router;