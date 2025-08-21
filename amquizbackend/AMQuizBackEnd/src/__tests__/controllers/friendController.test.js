const friendController = require('../../controllers/friendController');
const friendService = require('../../services/friendService');
const authService = require('../../services/authService');

jest.mock('../../services/friendService');
jest.mock('../../services/authService');

describe('FriendController', () => {
  let req, res;

  beforeEach(() => {
    req = { body: {}, headers: {} };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    jest.clearAllMocks();
  });

  describe('sendInvitation', () => {
    it('should return 400 if uidAmi is missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      await friendController.sendInvitation(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "UID de l'ami requis" });
    });

    it('should call friendService.sendInvitation and return 200', async () => {
      req.body.uidAmi = 'friendUid';
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.sendInvitation.mockResolvedValue('Invitation envoyée');

      await friendController.sendInvitation(req, res);

      expect(friendService.sendInvitation).toHaveBeenCalledWith('uidUser', 'friendUid');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Invitation envoyée' });
    });

    it('should return 400 if service throws', async () => {
      req.body.uidAmi = 'friendUid';
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.sendInvitation.mockRejectedValue(new Error('Erreur'));

      await friendController.sendInvitation(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('sendInvitationByPseudo', () => {
    it('should return 400 if pseudo is missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      await friendController.sendInvitationByPseudo(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Pseudo requis' });
    });

    it('should call friendService.sendInvitationByPseudo and return 200', async () => {
      req.body.pseudo = 'friendPseudo';
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.sendInvitationByPseudo.mockResolvedValue('Invitation envoyée');

      await friendController.sendInvitationByPseudo(req, res);

      expect(friendService.sendInvitationByPseudo).toHaveBeenCalledWith('uidUser', 'friendPseudo');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Invitation envoyée' });
    });

    it('should return 400 if service throws', async () => {
      req.body.pseudo = 'friendPseudo';
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.sendInvitationByPseudo.mockRejectedValue(new Error('Erreur'));

      await friendController.sendInvitationByPseudo(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('verifyInvitation', () => {
    it('should return 400 if pseudo is missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      await friendController.verifyInvitation(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Pseudo requis' });
    });

    it('should call friendService.verifyInvitation and return 200', async () => {
      req.body.pseudo = 'friendPseudo';
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.verifyInvitation.mockResolvedValue({ message: 'Tout est OK', uidAmi: 'friendUid' });

      await friendController.verifyInvitation(req, res);

      expect(friendService.verifyInvitation).toHaveBeenCalledWith('uidUser', 'friendPseudo');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Tout est OK', uidAmi: 'friendUid' });
    });

    it('should return 400 if service throws', async () => {
      req.body.pseudo = 'friendPseudo';
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.verifyInvitation.mockRejectedValue(new Error('Erreur'));

      await friendController.verifyInvitation(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('acceptInvitation', () => {
    it('should return 400 if uidAmi or pseudoAmi is missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      await friendController.acceptInvitation(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "UID et pseudo de l'ami requis" });
    });

    it('should call friendService.acceptInvitation and return 200', async () => {
      req.body.uidAmi = 'friendUid';
      req.body.pseudoAmi = 'friendPseudo';
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.acceptInvitation.mockResolvedValue('Ami ajouté avec succès');

      await friendController.acceptInvitation(req, res);

      expect(friendService.acceptInvitation).toHaveBeenCalledWith('uidUser', 'friendUid', 'friendPseudo');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Ami ajouté avec succès' });
    });

    it('should return 400 if service throws', async () => {
      req.body.uidAmi = 'friendUid';
      req.body.pseudoAmi = 'friendPseudo';
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.acceptInvitation.mockRejectedValue(new Error('Erreur'));

      await friendController.acceptInvitation(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('deleteInvitation', () => {
    it('should return 400 if indexInvitation is missing or invalid', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      await friendController.deleteInvitation(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "Index d'invitation valide requis" });
    });

    it('should call friendService.deleteInvitation and return 200', async () => {
      req.body.indexInvitation = 0;
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.deleteInvitation.mockResolvedValue('Invitation supprimée avec succès');

      await friendController.deleteInvitation(req, res);

      expect(friendService.deleteInvitation).toHaveBeenCalledWith('uidUser', 0);
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Invitation supprimée avec succès' });
    });

    it('should return 400 if service throws', async () => {
      req.body.indexInvitation = 0;
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.deleteInvitation.mockRejectedValue(new Error('Erreur'));

      await friendController.deleteInvitation(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('deleteFriend', () => {
    it('should return 400 if uidAmi is missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      await friendController.deleteFriend(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "UID de l'ami requis" });
    });

    it('should call friendService.deleteFriend and return 200', async () => {
      req.body.uidAmi = 'friendUid';
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.deleteFriend.mockResolvedValue('Ami supprimé avec succès des deux listes');

      await friendController.deleteFriend(req, res);

      expect(friendService.deleteFriend).toHaveBeenCalledWith('uidUser', 'friendUid');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Ami supprimé avec succès des deux listes' });
    });

    it('should return 400 if service throws', async () => {
      req.body.uidAmi = 'friendUid';
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.deleteFriend.mockRejectedValue(new Error('Erreur'));

      await friendController.deleteFriend(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('getFriendsList', () => {
    it('should call friendService.getFriendsList and return 200', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.getFriendsList.mockResolvedValue(['friend1', 'friend2']);

      await friendController.getFriendsList(req, res);

      expect(friendService.getFriendsList).toHaveBeenCalledWith('uidUser');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ friends: ['friend1', 'friend2'] });
    });

    it('should return 400 if service throws', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.getFriendsList.mockRejectedValue(new Error('Erreur'));

      await friendController.getFriendsList(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('getPendingInvitations', () => {
    it('should call friendService.getPendingInvitations and return 200', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.getPendingInvitations.mockResolvedValue({ invitations: [], uidInvitations: [] });

      await friendController.getPendingInvitations(req, res);

      expect(friendService.getPendingInvitations).toHaveBeenCalledWith('uidUser');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ invitations: [], uidInvitations: [] });
    });

    it('should return 400 if service throws', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      friendService.getPendingInvitations.mockRejectedValue(new Error('Erreur'));

      await friendController.getPendingInvitations(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });
});
