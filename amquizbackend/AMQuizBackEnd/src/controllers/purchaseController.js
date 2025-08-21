const purchaseService = require('../services/purchaseService');
const authService = require('../services/authService');

class PurchaseController {
  async validateGooglePlayReceipt(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { receiptData, productId } = req.body;

      console.log(`Validation achat pour ${uid}, produit: ${productId}`);

      const result = await purchaseService.validateGooglePlayReceipt(
        uid, 
        receiptData, 
        productId
      );

      res.status(200).json({
        success: true,
        message: 'Achat validé avec succès',
        ...result
      });
    } catch (error) {
      console.error('Erreur validation Google Play:', error);
      res.status(400).json({ error: error.message });
    }
  }

  async validateTransaction(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { transactionId, productId, platform } = req.body;

      console.log(`Validation transaction pour ${uid}, produit: ${productId}, platform: ${platform}`);

      const result = await purchaseService.validateTransaction(
        uid, 
        transactionId, 
        productId, 
        platform
      );

      res.status(200).json({
        success: true,
        message: 'Transaction validée avec succès',
        ...result
      });
    } catch (error) {
      console.error('Erreur validation transaction:', error);
      res.status(400).json({ error: error.message });
    }
  }
}

module.exports = new PurchaseController();