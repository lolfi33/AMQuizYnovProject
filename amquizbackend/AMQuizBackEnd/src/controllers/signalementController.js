const signalementService = require('../services/signalementService');
const authService = require('../services/authService');

class SignalementController {
  async createSignalement(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { uidJoueurQuiAEteSignale, raison } = req.body;

      if (!uidJoueurQuiAEteSignale || !raison) {
        return res.status(400).json({ 
          error: 'UID du joueur signalé et raison requis' 
        });
      }

      // Valider la raison
      await signalementService.validateSignalementReason(raison);

      const message = await signalementService.createSignalement(
        uid, 
        uidJoueurQuiAEteSignale, 
        raison
      );

      res.status(200).json({ message });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getSignalementsByUser(req, res) {
    try {
      const { uid } = req.params;

      if (!uid) {
        return res.status(400).json({ error: 'UID requis' });
      }

      const signalements = await signalementService.getSignalementsByUser(uid);
      res.status(200).json(signalements);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getAllSignalements(req, res) {
    try {
      // Cette route pourrait nécessiter des permissions d'admin
      const signalements = await signalementService.getAllSignalements();
      res.status(200).json(signalements);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async deleteSignalement(req, res) {
    try {
      const { signalementId } = req.params;

      if (!signalementId) {
        return res.status(400).json({ error: 'ID du signalement requis' });
      }

      const message = await signalementService.deleteSignalement(signalementId);
      res.status(200).json({ message });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getMySignalements(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      const signalements = await signalementService.getSignalementsByReporter(uid);
      res.status(200).json(signalements);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

module.exports = new SignalementController();