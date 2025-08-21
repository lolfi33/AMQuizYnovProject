const userController = require('../../controllers/userController');
const userService = require('../../services/userService');
const authService = require('../../services/authService');

jest.mock('../../services/userService');
jest.mock('../../services/authService');

describe('UserController', () => {
  let req, res;

  beforeEach(() => {
    req = { body: {}, params: {} };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    jest.clearAllMocks();
  });

  describe('updateBiography', () => {
    it('should return 400 if biographie missing', async () => {
      await userController.updateBiography(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Biographie requise' });
    });

    it('should update biography', async () => {
      req.body.biographie = 'Nouvelle bio';
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      userService.updateBiography.mockResolvedValue(true);

      await userController.updateBiography(req, res);

      expect(userService.updateBiography).toHaveBeenCalledWith('user123', 'Nouvelle bio');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Biographie mise à jour avec succès' });
    });
  });

  describe('updateTitle', () => {
    it('should return 400 if titre missing', async () => {
      await userController.updateTitle(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Titre requis' });
    });

    it('should update title', async () => {
      req.body.titre = 'Champion';
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      userService.updateTitle.mockResolvedValue(true);

      await userController.updateTitle(req, res);

      expect(userService.updateTitle).toHaveBeenCalledWith('user123', 'Champion');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Titre mis à jour avec succès' });
    });
  });

  describe('updateProfilePicture', () => {
    it('should return 400 if urlImgProfil missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('user123');

      await userController.updateProfilePicture(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "URL de l'image de profil requise" });
    });

    it('should update profile picture', async () => {
      req.body.urlImgProfil = 'http://img.url';
      authService.verifyTokenFromRequest.mockResolvedValue('user123');

      await userController.updateProfilePicture(req, res);

      expect(userService.updateProfilePicture).toHaveBeenCalledWith('user123', 'http://img.url');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Image de profil mise à jour avec succès' });
    });
  });

  describe('updateBanner', () => {
    it('should return 400 if banniereProfil missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('user123');

      await userController.updateBanner(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Bannière de profil requise' });
    });

    it('should update banner', async () => {
      req.body.banniereProfil = 'http://banner.url';
      authService.verifyTokenFromRequest.mockResolvedValue('user123');

      await userController.updateBanner(req, res);

      expect(userService.updateBanner).toHaveBeenCalledWith('user123', 'http://banner.url');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Bannière mise à jour avec succès' });
    });
  });

  describe('sendLike', () => {
    it('should send like', async () => {
      req.body.uidUserQuiARecuLeLike = 'user456';
      authService.verifyTokenFromRequest.mockResolvedValue('user123');

      await userController.sendLike(req, res);

      expect(userService.sendLike).toHaveBeenCalledWith('user123', 'user456');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Like envoyé avec succès' });
    });
  });

  describe('updatePresence', () => {
    it('should update presence', async () => {
      req.body.isOnline = true;
      authService.verifyTokenFromRequest.mockResolvedValue('user123');

      await userController.updatePresence(req, res);

      expect(userService.updatePresence).toHaveBeenCalledWith('user123', true);
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Présence mise à jour avec succès' });
    });
  });

  describe('deleteAccount', () => {
    it('should delete account', async () => {
      req.params.uid = 'user123';
      authService.validateUserOwnership.mockResolvedValue('user123');
      userService.deleteUser.mockResolvedValue(true);

      await userController.deleteAccount(req, res);

      expect(userService.deleteUser).toHaveBeenCalledWith('user123');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Compte supprimé avec succès' });
    });
  });

  describe('loseLife', () => {
    it('should lose life', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      userService.loseLife.mockResolvedValue(true);

      await userController.loseLife(req, res);

      expect(userService.loseLife).toHaveBeenCalledWith('user123');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Vie perdue avec succès' });
    });
  });

  describe('updateRecords', () => {
    it('should return 400 if missing params', async () => {
      await userController.updateRecords(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should update records', async () => {
      req.body = { recordType: 'score', indexRecord: 1, nouveauRecord: 100 };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');

      await userController.updateRecords(req, res);

      expect(userService.updateRecords).toHaveBeenCalledWith('user123', 'score', 1, 100);
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: true, message: 'Records mis à jour avec succès' });
    });
  });

  describe('unlockNextLevel', () => {
    it('should return 400 if missing params', async () => {
      await userController.unlockNextLevel(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should unlock next level when unlocked', async () => {
      req.body = { recordType: 'score', indexRecord: 1 };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      userService.unlockNextLevel.mockResolvedValue(true);

      await userController.unlockNextLevel(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: true, message: 'Prochaine île débloquée avec succès' });
    });

    it('should respond if no modification needed', async () => {
      req.body = { recordType: 'score', indexRecord: 1 };
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      userService.unlockNextLevel.mockResolvedValue(false);

      await userController.unlockNextLevel(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: true, message: 'Aucune modification nécessaire' });
    });
  });

  describe('completeOnlineQuiz', () => {
    it('should complete online quiz', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      userService.completeOnlineQuiz.mockResolvedValue(true);

      await userController.completeOnlineQuiz(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: true, message: 'Mission quiz en ligne mise à jour' });
    });
  });

  describe('completeWhoAmI10Points', () => {
    it('should complete quiz 10 points', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      userService.completeWhoAmI10Points.mockResolvedValue(true);

      await userController.completeWhoAmI10Points(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: true, message: 'Mission "Qui suis-je 10 points" mise à jour' });
    });
  });

  describe('completeWhoAmI15Points', () => {
    it('should complete quiz 15 points', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('user123');
      userService.completeWhoAmI15Points.mockResolvedValue(true);

      await userController.completeWhoAmI15Points(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: true, message: 'Mission "Qui suis-je 15 points" mise à jour' });
    });
  });
});
