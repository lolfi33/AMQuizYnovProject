const purchaseController = require('../../controllers/purchaseController');
const purchaseService = require('../../services/purchaseService');
const authService = require('../../services/authService');

jest.mock('../../services/purchaseService');
jest.mock('../../services/authService');

describe('PurchaseController', () => {
  let req, res;

  beforeEach(() => {
    req = { body: {}, headers: {} };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    jest.clearAllMocks();
  });

  describe('validateGooglePlayReceipt', () => {
    it('should validate receipt and return 200', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.body = { receiptData: 'data123', productId: 'prod1' };
      purchaseService.validateGooglePlayReceipt.mockResolvedValue({ coins: 100 });

      await purchaseController.validateGooglePlayReceipt(req, res);

      expect(purchaseService.validateGooglePlayReceipt).toHaveBeenCalledWith(
        'uidUser',
        'data123',
        'prod1'
      );
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'Achat validé avec succès',
        coins: 100
      });
    });

    it('should return 400 if service throws', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.body = { receiptData: 'data123', productId: 'prod1' };
      purchaseService.validateGooglePlayReceipt.mockRejectedValue(new Error('Erreur'));

      await purchaseController.validateGooglePlayReceipt(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('validateTransaction', () => {
    it('should validate transaction and return 200', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.body = { transactionId: 'tx123', productId: 'prod1', platform: 'ios' };
      purchaseService.validateTransaction.mockResolvedValue({ coins: 50 });

      await purchaseController.validateTransaction(req, res);

      expect(purchaseService.validateTransaction).toHaveBeenCalledWith(
        'uidUser',
        'tx123',
        'prod1',
        'ios'
      );
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'Transaction validée avec succès',
        coins: 50
      });
    });

    it('should return 400 if service throws', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.body = { transactionId: 'tx123', productId: 'prod1', platform: 'ios' };
      purchaseService.validateTransaction.mockRejectedValue(new Error('Erreur'));

      await purchaseController.validateTransaction(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });
});
