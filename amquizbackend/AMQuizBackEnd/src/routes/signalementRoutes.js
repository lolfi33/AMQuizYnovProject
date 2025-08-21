const express = require('express');
const signalementController = require('../controllers/signalementController');
const authMiddleware = require('../middlewares/authMiddleware');
const { sanitizeInputs, validateRequiredFields } = require('../middlewares/validationMiddleware');

const router = express.Router();

// Toutes les routes nécessitent une authentification
router.use(authMiddleware);
router.use(sanitizeInputs);

// Route pour créer un signalement
router.post('/signaler-utilisateur',
  validateRequiredFields(['uidJoueurQuiAEteSignale', 'raison']),
  signalementController.createSignalement
);

// Route pour récupérer mes signalements
router.get('/mes-signalements',
  signalementController.getMySignalements
);

// Routes pour les admins (nécessiteraient des permissions spéciales en production)
router.get('/all',
  signalementController.getAllSignalements
);

router.get('/user/:uid',
  signalementController.getSignalementsByUser
);

router.delete('/:signalementId',
  signalementController.deleteSignalement
);

module.exports = router;