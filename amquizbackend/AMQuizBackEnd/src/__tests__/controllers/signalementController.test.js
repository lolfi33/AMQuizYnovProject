const signalementController = require('../../controllers/signalementController');
const signalementService = require('../../services/signalementService');
const authService = require('../../services/authService');

jest.mock('../../services/signalementService');
jest.mock('../../services/authService');

describe('SignalementController', () => {
  let req, res;

  beforeEach(() => {
    req = { body: {}, params: {} };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    jest.clearAllMocks();
  });

  describe('createSignalement', () => {
    it('should return 400 if uidJoueurQuiAEteSignale or raison missing', async () => {
      await signalementController.createSignalement(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'UID du joueur signalé et raison requis' });
    });

    it('should create signalement and return message', async () => {
      req.body = { uidJoueurQuiAEteSignale: 'player123', raison: 'triche' };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      signalementService.validateSignalementReason.mockResolvedValue(true);
      signalementService.createSignalement.mockResolvedValue('Signalement créé avec succès');

      await signalementController.createSignalement(req, res);

      expect(signalementService.validateSignalementReason).toHaveBeenCalledWith('triche');
      expect(signalementService.createSignalement).toHaveBeenCalledWith('user123', 'player123', 'triche');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Signalement créé avec succès' });
    });

    it('should return 400 if service throws', async () => {
      req.body = { uidJoueurQuiAEteSignale: 'player123', raison: 'triche' };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      signalementService.validateSignalementReason.mockResolvedValue(true);
      signalementService.createSignalement.mockRejectedValue(new Error('Erreur création'));

      await signalementController.createSignalement(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur création' });
    });
  });

  describe('getSignalementsByUser', () => {
    it('should return 400 if uid missing', async () => {
      await signalementController.getSignalementsByUser(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'UID requis' });
    });

    it('should return signalements for a user', async () => {
      req.params.uid = 'user123';
      signalementService.getSignalementsByUser.mockResolvedValue(['sig1', 'sig2']);

      await signalementController.getSignalementsByUser(req, res);

      expect(signalementService.getSignalementsByUser).toHaveBeenCalledWith('user123');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(['sig1', 'sig2']);
    });

    it('should return 400 if service throws', async () => {
      req.params.uid = 'user123';
      signalementService.getSignalementsByUser.mockRejectedValue(new Error('Erreur lecture'));

      await signalementController.getSignalementsByUser(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur lecture' });
    });
  });

  describe('getAllSignalements', () => {
    it('should return all signalements', async () => {
      signalementService.getAllSignalements.mockResolvedValue(['sig1', 'sig2']);

      await signalementController.getAllSignalements(req, res);

      expect(signalementService.getAllSignalements).toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(['sig1', 'sig2']);
    });

    it('should return 500 if service throws', async () => {
      signalementService.getAllSignalements.mockRejectedValue(new Error('Erreur générale'));

      await signalementController.getAllSignalements(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur générale' });
    });
  });

  describe('deleteSignalement', () => {
    it('should return 400 if signalementId missing', async () => {
      await signalementController.deleteSignalement(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'ID du signalement requis' });
    });

    it('should delete signalement and return message', async () => {
      req.params.signalementId = 'sig123';
      signalementService.deleteSignalement.mockResolvedValue('Signalement supprimé');

      await signalementController.deleteSignalement(req, res);

      expect(signalementService.deleteSignalement).toHaveBeenCalledWith('sig123');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Signalement supprimé' });
    });

    it('should return 400 if service throws', async () => {
      req.params.signalementId = 'sig123';
      signalementService.deleteSignalement.mockRejectedValue(new Error('Erreur suppression'));

      await signalementController.deleteSignalement(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur suppression' });
    });
  });

  describe('getMySignalements', () => {
    it('should return signalements for current user', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      signalementService.getSignalementsByReporter.mockResolvedValue(['sig1', 'sig2']);

      await signalementController.getMySignalements(req, res);

      expect(signalementService.getSignalementsByReporter).toHaveBeenCalledWith('user123');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(['sig1', 'sig2']);
    });

    it('should return 400 if service throws', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      signalementService.getSignalementsByReporter.mockRejectedValue(new Error('Erreur'));

      await signalementController.getMySignalements(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });
});
