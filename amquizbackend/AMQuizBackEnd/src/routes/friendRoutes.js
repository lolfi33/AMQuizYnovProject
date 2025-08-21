const express = require('express');
const friendController = require('../controllers/friendController');
const authMiddleware = require('../middlewares/authMiddleware');
const { sanitizeInputs, validateRequiredFields, validateDataTypes } = require('../middlewares/validationMiddleware');

const router = express.Router();

// Toutes les routes nécessitent une authentification
router.use(authMiddleware);
router.use(sanitizeInputs);

// Routes pour envoyer des invitations
router.post('/envoyer-invitation',
  validateRequiredFields(['uidAmi']),
  friendController.sendInvitation
);

router.post('/envoyer-invitation-pseudo',
  validateRequiredFields(['pseudo']),
  friendController.sendInvitationByPseudo
);

// Route pour vérifier une invitation avant l'envoi
router.post('/verify-invitation',
  validateRequiredFields(['pseudo']),
  friendController.verifyInvitation
);

// Route pour accepter une invitation
router.post('/add-friend',
  validateRequiredFields(['uidAmi', 'pseudoAmi']),
  friendController.acceptInvitation
);

// Route pour supprimer une invitation
router.post('/delete-invitation',
  validateRequiredFields(['indexInvitation']),
  validateDataTypes({ indexInvitation: 'number' }),
  friendController.deleteInvitation
);

// Route pour supprimer un ami
router.post('/delete-friend',
  validateRequiredFields(['uidAmi']),
  friendController.deleteFriend
);

// Routes pour récupérer des données
router.get('/friends-list',
  friendController.getFriendsList
);

router.get('/pending-invitations',
  friendController.getPendingInvitations
);

module.exports = router;