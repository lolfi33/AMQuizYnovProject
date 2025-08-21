const shopService = require('../services/shopService');
const authService = require('../services/authService');

class ShopController {
  async buyItem(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { nomItem } = req.body;

      if (!nomItem) {
        return res.status(400).json({ error: 'Nom de l\'item requis' });
      }

      const message = await shopService.buyItem(uid, nomItem);
      res.status(200).json({ message });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getPrices(req, res) {
    try {
      const prices = shopService.getPrices();
      res.status(200).json(prices);
    } catch (error) {
      res.status(500).json({ error: 'Erreur lors de la récupération des prix' });
    }
  }

  async openChest(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { chestType } = req.body;

      if (!chestType) {
        return res.status(400).json({ error: 'Type de coffre requis' });
      }

      const item = await shopService.openChest(uid, chestType);
      res.status(200).json({ 
        success: true, 
        item: item 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async openEnvelope(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { chestType } = req.body;

      if (!chestType) {
        return res.status(400).json({ error: 'Type d\'enveloppe requis' });
      }

      const item = await shopService.openEnvelope(uid, chestType);
      res.status(200).json({ 
        success: true, 
        item: item 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async sellItem(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { itemId, itemType } = req.body;

      if (!itemId || !itemType) {
        return res.status(400).json({ 
          error: 'ID et type de l\'item requis' 
        });
      }

      const sellValue = await shopService.sellItem(uid, itemId, itemType);
      res.status(200).json({ 
        success: true, 
        sellValue: sellValue 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

module.exports = new ShopController();