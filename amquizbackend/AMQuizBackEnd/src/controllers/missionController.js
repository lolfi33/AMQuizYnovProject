const missionService = require('../services/missionService');
const authService = require('../services/authService');

class MissionController {
  async getUserMissions(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      const missions = await missionService.getUserMissions(uid);
      res.status(200).json(missions);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

async addDailyMissions(req, res) {
  try {
    console.log('🎯 [CONTROLLER] Ajout de daily missions...');
    
    const uid = await authService.verifyTokenFromRequest(req);

    const result = await missionService.addDailyMissions(uid);
    
    console.log('✅ [CONTROLLER] Daily missions ajoutées avec succès');
    res.status(200).json({
      message: '3 nouvelles daily missions ajoutées avec succès',
      missions: result
    });
    
  } catch (error) {
    console.error('❌ [CONTROLLER] Erreur daily missions:', error.message);
    res.status(400).json({ error: error.message });
  }
}

async getDailyMissions(req, res) {
  try {
    const uid = await authService.verifyTokenFromRequest(req);

    const dailyMissions = await missionService.getDailyMissions(uid);
    res.status(200).json(dailyMissions);
    
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

async checkAndAssignDailyMissions(req, res) {
  try {
    const uid = await authService.verifyTokenFromRequest(req);

    const result = await missionService.checkAndAssignDailyMissions(uid);
    res.status(200).json(result);
    
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

  async getMissionProgress(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { missionKey } = req.params;

      if (!missionKey) {
        return res.status(400).json({ error: 'Clé de mission requise' });
      }

      const progress = await missionService.getMissionProgress(uid, missionKey);
      res.status(200).json(progress);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getAllMissionsProgress(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      const progress = await missionService.checkAllMissionsProgress(uid);
      res.status(200).json(progress);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async claimReward(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { missionKey } = req.body;

      if (!missionKey) {
        return res.status(400).json({ error: 'Clé de mission requise' });
      }

      const result = await missionService.claimMissionReward(uid, missionKey);
      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getAvailableRewards(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      const rewards = await missionService.getAvailableRewards(uid);
      res.status(200).json(rewards);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getCompletedMissions(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      const completed = await missionService.getCompletedMissions(uid);
      res.status(200).json(completed);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async updateMissionProgress(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { missionKey, progress } = req.body;

      if (!missionKey) {
        return res.status(400).json({ error: 'Clé de mission requise' });
      }

      const updated = await missionService.updateMissionProgress(uid, missionKey, progress);
      
      if (updated) {
        res.status(200).json({ 
          success: true, 
          message: 'Progression de mission mise à jour' 
        });
      } else {
        res.status(200).json({ 
          success: false, 
          message: 'Mission non trouvée ou déjà complétée' 
        });
      }
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async resetMission(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { missionKey } = req.body;

      if (!missionKey) {
        return res.status(400).json({ error: 'Clé de mission requise' });
      }

      const message = await missionService.resetMission(uid, missionKey);
      res.status(200).json({ message });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  // ==================== MÉTHODES MANQUANTES ====================
  
  // Quiz en ligne
  async updateQuizOnlineProgress(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      await missionService.updateMissionProgress(uid, 'mission6'); // Mission quiz en ligne
      res.status(200).json({ 
        success: true, 
        message: 'Mission quiz en ligne mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  // Qui suis-je 10 points
  async updateQuiSuisJe10Points(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      await missionService.updateMissionProgress(uid, 'mission7'); // Mission 10 points qui suis-je
      res.status(200).json({ 
        success: true, 
        message: 'Mission "Qui suis-je 10 points" mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  // Qui suis-je 15 points
  async updateQuiSuisJe15Points(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      await missionService.updateMissionProgress(uid, 'mission8'); // Mission 15 points qui suis-je
      res.status(200).json({ 
        success: true, 
        message: 'Mission "Qui suis-je 15 points" mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  // Quiz avec ami
  async updateQuizWithFriend(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      await missionService.updateMissionProgress(uid, 'mission20'); // Mission quiz avec ami
      res.status(200).json({ 
        success: true, 
        message: 'Mission "Quiz avec ami" mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  // Quiz multi avec ami
  async updateMultiQuizWithFriend(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      await missionService.updateMissionProgress(uid, 'mission21'); // Mission quiz multi avec ami
      res.status(200).json({ 
        success: true, 
        message: 'Mission "Quiz multi avec ami" mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  // Quiz multi
  async updateMultiQuiz(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { themeQuiz } = req.body;

      await missionService.updateMissionProgress(uid, 'mission22'); // Mission quiz multi
      res.status(200).json({ 
        success: true, 
        message: 'Mission "Quiz multi" mise à jour',
        theme: themeQuiz 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  // Jouer qui suis-je
  async updateQuiSuisJePlay(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);

      await missionService.updateMissionProgress(uid, 'mission23'); // Mission jouer qui suis-je
      res.status(200).json({ 
        success: true, 
        message: 'Mission "Jouer qui suis-je" mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  // Routes spécifiques pour différents types de missions
  async updateAdventureMission(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { adventureType } = req.body;

      if (!adventureType) {
        return res.status(400).json({ error: 'Type d\'aventure requis' });
      }

      await missionService.updateAdventureMission(uid, adventureType);
      res.status(200).json({ 
        success: true, 
        message: 'Mission d\'aventure mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async updateScoreMission(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { score, gameType } = req.body;

      if (score === undefined || !gameType) {
        return res.status(400).json({ 
          error: 'Score et type de jeu requis' 
        });
      }

      await missionService.updateScoreMission(uid, score, gameType);
      res.status(200).json({ 
        success: true, 
        message: 'Mission de score mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async updateStarMission(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      const { stars, adventureType } = req.body;

      if (stars === undefined || !adventureType) {
        return res.status(400).json({ 
          error: 'Nombre d\'étoiles et type d\'aventure requis' 
        });
      }

      await missionService.updateStarMission(uid, stars, adventureType);
      res.status(200).json({ 
        success: true, 
        message: 'Mission d\'étoiles mise à jour' 
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

}

module.exports = new MissionController();