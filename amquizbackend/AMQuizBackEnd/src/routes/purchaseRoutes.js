const express = require('express');
const purchaseController = require('../controllers/purchaseController');
const authMiddleware = require('../middlewares/authMiddleware');
const { sanitizeInputs, validateRequiredFields } = require('../middlewares/validationMiddleware');

const router = express.Router();

// Toutes les routes nécessitent une authentification
router.use(authMiddleware);
router.use(sanitizeInputs);

// Route pour valider les achats Android (Google Play)
router.post('/validate-receipt',
  validateRequiredFields(['receiptData', 'productId']),
  purchaseController.validateGooglePlayReceipt
);

// Route pour valider les transactions (iOS & Android)
router.post('/validate-transaction',
  validateRequiredFields(['transactionId', 'productId', 'platform']),
  purchaseController.validateTransaction
);

module.exports = router;