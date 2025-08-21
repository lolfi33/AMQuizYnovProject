const express = require('express');
const shopController = require('../controllers/shopController');
const authMiddleware = require('../middlewares/authMiddleware');
const { shopLimiter } = require('../middlewares/rateLimitMiddleware');
const { sanitizeInputs, validateRequiredFields } = require('../middlewares/validationMiddleware');

const router = express.Router();

// Routes publiques
router.get('/get-prices', shopController.getPrices);

// Routes nécessitant une authentification
router.use(authMiddleware);
router.use(sanitizeInputs);

// Route pour acheter un item (avec limitation)
router.post('/acheter-item',
  shopLimiter,
  validateRequiredFields(['nomItem']),
  shopController.buyItem
);

// Routes pour ouvrir des coffres/enveloppes
router.post('/open-coffre',
  validateRequiredFields(['chestType']),
  shopController.openChest
);

router.post('/open-enveloppe',
  validateRequiredFields(['chestType']),
  shopController.openEnvelope
);

// Route pour vendre un item
router.post('/sell-item',
  validateRequiredFields(['itemId', 'itemType']),
  shopController.sellItem
);

module.exports = router;