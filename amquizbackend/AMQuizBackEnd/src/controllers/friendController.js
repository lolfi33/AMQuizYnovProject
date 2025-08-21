const friendService = require('../services/friendService');
const authService = require('../services/authService');

class FriendController {
  async sendInvitation(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { uidAmi } = req.body;

      if (!uidAmi) {
        return res.status(400).json({ error: 'UID de l\'ami requis' });
      }

      const message = await friendService.sendInvitation(uid, uidAmi);
      res.status(200).json({ message });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async sendInvitationByPseudo(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { pseudo } = req.body;

      if (!pseudo) {
        return res.status(400).json({ error: 'Pseudo requis' });
      }

      const message = await friendService.sendInvitationByPseudo(uid, pseudo);
      res.status(200).json({ message });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async verifyInvitation(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { pseudo } = req.body;

      if (!pseudo) {
        return res.status(400).json({ error: 'Pseudo requis' });
      }

      const result = await friendService.verifyInvitation(uid, pseudo);
      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async acceptInvitation(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { uidAmi, pseudoAmi } = req.body;

      if (!uidAmi || !pseudoAmi) {
        return res.status(400).json({ 
          error: 'UID et pseudo de l\'ami requis' 
        });
      }

      const message = await friendService.acceptInvitation(uid, uidAmi, pseudoAmi);
      res.status(200).json({ message });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async deleteInvitation(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { indexInvitation } = req.body;

      if (indexInvitation === undefined || indexInvitation < 0) {
        return res.status(400).json({ error: 'Index d\'invitation valide requis' });
      }

      const message = await friendService.deleteInvitation(uid, indexInvitation);
      res.status(200).json({ message });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async deleteFriend(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { uidAmi } = req.body;

      if (!uidAmi) {
        return res.status(400).json({ error: 'UID de l\'ami requis' });
      }

      const message = await friendService.deleteFriend(uid, uidAmi);
      res.status(200).json({ message });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getFriendsList(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      const friends = await friendService.getFriendsList(uid);
      res.status(200).json({ friends });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getPendingInvitations(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      const invitations = await friendService.getPendingInvitations(uid);
      res.status(200).json(invitations);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

module.exports = new FriendController();