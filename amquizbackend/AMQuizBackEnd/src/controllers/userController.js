const userService = require('../services/userService');
const authService = require('../services/authService');

class UserController {
  async updateBiography(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { biographie } = req.body;

      if (!biographie && biographie !== '') {
        return res.status(400).json({ error: 'Biographie requise' });
      }

      await userService.updateBiography(uid, biographie);
      res.status(200).json({ message: 'Biographie mise à jour avec succès' });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async updateTitle(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { titre } = req.body;

      if (!titre) {
        return res.status(400).json({ error: 'Titre requis' });
      }

      await userService.updateTitle(uid, titre);
      res.status(200).json({ message: 'Titre mis à jour avec succès' });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async updateProfilePicture(req, res) {
    try {
      console.log('📸 [CONTROLLER] updateProfilePicture appelé');
      console.log('📸 [CONTROLLER] Body reçu:', req.body);
      
      const uid = await authService.verifyTokenFromRequest(req);
      console.log('📸 [CONTROLLER] UID vérifié:', uid);
      
      const { urlImgProfil } = req.body;

      if (!urlImgProfil) {
        console.log('📸 [CONTROLLER] Erreur: URL manquante');
        return res.status(400).json({ error: 'URL de l\'image de profil requise' });
      }

      console.log('📸 [CONTROLLER] Appel du service avec:', urlImgProfil);
      await userService.updateProfilePicture(uid, urlImgProfil);
      
      console.log('📸 [CONTROLLER] Succès!');
      res.status(200).json({ message: 'Image de profil mise à jour avec succès' });
    } catch (error) {
      console.log('📸 [CONTROLLER] Erreur:', error.message);
      res.status(400).json({ error: error.message });
    }
  }

  async updateBanner(req, res) {
    try {
      console.log('🖼️ [CONTROLLER] updateBanner appelé');
      console.log('🖼️ [CONTROLLER] Body reçu:', req.body);
      
      const uid = await authService.verifyTokenFromRequest(req);
      console.log('🖼️ [CONTROLLER] UID vérifié:', uid);
      
      const { banniereProfil } = req.body;

      if (!banniereProfil) {
        console.log('🖼️ [CONTROLLER] Erreur: Bannière manquante');
        return res.status(400).json({ error: 'Bannière de profil requise' });
      }

      console.log('🖼️ [CONTROLLER] Appel du service avec:', banniereProfil);
      await userService.updateBanner(uid, banniereProfil);
      
      console.log('🖼️ [CONTROLLER] Succès!');
      res.status(200).json({ message: 'Bannière mise à jour avec succès' });
    } catch (error) {
      console.log('🖼️ [CONTROLLER] Erreur:', error.message);
      res.status(400).json({ error: error.message });
    }
  }

  async sendLike(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { uidUserQuiARecuLeLike } = req.body;

      await userService.sendLike(uid, uidUserQuiARecuLeLike);
      res.status(200).json({ message: 'Like envoyé avec succès' });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async updatePresence(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { isOnline } = req.body;

      await userService.updatePresence(uid, isOnline);
      res.status(200).json({ message: 'Présence mise à jour avec succès' });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async deleteAccount(req, res) {
    try {
      const { uid: targetUid } = req.params;
      const uid = await authService.validateUserOwnership(req, targetUid);

      await userService.deleteUser(uid);
      res.status(200).json({ message: 'Compte supprimé avec succès' });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async loseLife(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      await userService.loseLife(uid);
      res.status(200).json({ message: 'Vie perdue avec succès' });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async updateRecords(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { recordType, indexRecord, nouveauRecord } = req.body;

      if (recordType === undefined || indexRecord === undefined || nouveauRecord === undefined) {
        return res.status(400).json({ 
          error: 'Type de record, index et nouveau record requis' 
        });
      }

      await userService.updateRecords(uid, recordType, indexRecord, nouveauRecord);
      res.status(200).json({ 
        success: true, 
        message: 'Records mis à jour avec succès' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async unlockNextLevel(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { recordType, indexRecord } = req.body;

      if (recordType === undefined || indexRecord === undefined) {
        return res.status(400).json({ 
          error: 'Type de record et index requis' 
        });
      }

      const unlocked = await userService.unlockNextLevel(uid, recordType, indexRecord);
      
      if (unlocked) {
        res.status(200).json({ 
          success: true, 
          message: 'Prochaine île débloquée avec succès' 
        });
      } else {
        res.status(200).json({ 
          success: true, 
          message: 'Aucune modification nécessaire' 
        });
      }
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async completeOnlineQuiz(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      await userService.completeOnlineQuiz(uid);
      res.status(200).json({ 
        success: true, 
        message: 'Mission quiz en ligne mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async completeWhoAmI10Points(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      await userService.completeWhoAmI10Points(uid);
      res.status(200).json({ 
        success: true, 
        message: 'Mission "Qui suis-je 10 points" mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async completeWhoAmI15Points(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      await userService.completeWhoAmI15Points(uid);
      res.status(200).json({ 
        success: true, 
        message: 'Mission "Qui suis-je 15 points" mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

module.exports = new UserController();