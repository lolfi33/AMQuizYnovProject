const shopController = require('../../controllers/shopController');
const shopService = require('../../services/shopService');
const authService = require('../../services/authService');

jest.mock('../../services/shopService');
jest.mock('../../services/authService');

describe('ShopController', () => {
  let req, res;

  beforeEach(() => {
    req = { body: {}, query: {} };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    jest.clearAllMocks();
  });

  describe('buyItem', () => {
    it('should return 400 if nomItem is missing', async () => {
      await shopController.buyItem(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Nom de l\'item requis' });
    });

    it('should buy item and return message', async () => {
      req.body = { nomItem: 'épée' };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      shopService.buyItem.mockResolvedValue('Item acheté avec succès');

      await shopController.buyItem(req, res);

      expect(shopService.buyItem).toHaveBeenCalledWith('user123', 'épée');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Item acheté avec succès' });
    });

    it('should return 400 if service throws', async () => {
      req.body = { nomItem: 'épée' };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      shopService.buyItem.mockRejectedValue(new Error('Erreur achat'));

      await shopController.buyItem(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur achat' });
    });
  });

  describe('getPrices', () => {
    it('should return prices with 200', async () => {
      shopService.getPrices.mockReturnValue({ épée: 100, bouclier: 50 });

      await shopController.getPrices(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ épée: 100, bouclier: 50 });
    });

    it('should return 500 if service throws', async () => {
      shopService.getPrices.mockImplementation(() => { throw new Error(); });

      await shopController.getPrices(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur lors de la récupération des prix' });
    });
  });

  describe('openChest', () => {
    it('should return 400 if chestType missing', async () => {
      await shopController.openChest(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Type de coffre requis' });
    });

    it('should open chest and return item', async () => {
      req.body = { chestType: 'doré' };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      shopService.openChest.mockResolvedValue('épée légendaire');

      await shopController.openChest(req, res);

      expect(shopService.openChest).toHaveBeenCalledWith('user123', 'doré');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: true, item: 'épée légendaire' });
    });

    it('should return 400 if service throws', async () => {
      req.body = { chestType: 'doré' };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      shopService.openChest.mockRejectedValue(new Error('Erreur coffre'));

      await shopController.openChest(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur coffre' });
    });
  });

  describe('openEnvelope', () => {
    it('should return 400 if chestType missing', async () => {
      await shopController.openEnvelope(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Type d\'enveloppe requis' });
    });

    it('should open envelope and return item', async () => {
      req.body = { chestType: 'doré' };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      shopService.openEnvelope.mockResolvedValue('bouclier légendaire');

      await shopController.openEnvelope(req, res);

      expect(shopService.openEnvelope).toHaveBeenCalledWith('user123', 'doré');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: true, item: 'bouclier légendaire' });
    });

    it('should return 400 if service throws', async () => {
      req.body = { chestType: 'doré' };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      shopService.openEnvelope.mockRejectedValue(new Error('Erreur enveloppe'));

      await shopController.openEnvelope(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur enveloppe' });
    });
  });

  describe('sellItem', () => {
    it('should return 400 if itemId or itemType missing', async () => {
      await shopController.sellItem(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'ID et type de l\'item requis' });
    });

    it('should sell item and return sellValue', async () => {
      req.body = { itemId: 'item123', itemType: 'épée' };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      shopService.sellItem.mockResolvedValue(50);

      await shopController.sellItem(req, res);

      expect(shopService.sellItem).toHaveBeenCalledWith('user123', 'item123', 'épée');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: true, sellValue: 50 });
    });

    it('should return 400 if service throws', async () => {
      req.body = { itemId: 'item123', itemType: 'épée' };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      shopService.sellItem.mockRejectedValue(new Error('Erreur vente'));

      await shopController.sellItem(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur vente' });
    });
  });
});
