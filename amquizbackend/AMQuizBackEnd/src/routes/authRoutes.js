const express = require('express');
const authController = require('../controllers/authController');
const { strictLimiter } = require('../middlewares/rateLimitMiddleware');
const authMiddleware = require('../middlewares/authMiddleware');
const { sanitizeInputs, validateRequiredFields } = require('../middlewares/validationMiddleware');

const router = express.Router();

// Route d'inscription avec validation stricte
router.post('/register', 
  strictLimiter,
  sanitizeInputs,
  validateRequiredFields(['email', 'password', 'pseudo']),
  authController.register
);

router.post('/register-google',
  authMiddleware,
  sanitizeInputs,
  validateRequiredFields(['pseudo']),
  authController.registerGoogle
);

// Route de vérification de token
router.post('/verify-token',
  sanitizeInputs,
  validateRequiredFields(['token']),
  authController.verifyToken
);

// Route de refresh token
router.post('/refresh-token',
  authController.refreshToken
);

module.exports = router;