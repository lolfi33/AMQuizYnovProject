// src/services/missionService.js
const missionRepository = require('../repositories/missionRepository');
const userRepository = require('../repositories/userRepository');

class MissionService {
  async getUserMissions(uid) {
    return await missionRepository.getUserMissions(uid);
  }

  async updateMissionProgress(uid, missionKey, progress = null) {
    const updated = await missionRepository.updateMissionProgress(uid, missionKey, progress);
    
    if (!updated) {
      console.log(`Mission ${missionKey} non trouvée ou déjà complétée pour l'utilisateur ${uid}`);
    }

    return updated;
  }

  async incrementMissionProgress(uid, missionKey, increment = 1) {
    return await missionRepository.incrementMissionProgress(uid, missionKey, increment);
  }

  async claimMissionReward(uid, missionKey) {
    // Vérifier que la mission est complétée
    const isCompleted = await missionRepository.isMissionCompleted(uid, missionKey);
    if (!isCompleted) {
      throw new Error('Mission non complétée');
    }

    // Récupérer et distribuer les récompenses
    const recompenses = await missionRepository.completeMission(uid, missionKey);
    
    return {
      message: 'Récompense réclamée avec succès',
      recompenses: recompenses
    };
  }

  async getCompletedMissions(uid) {
    return await missionRepository.getCompletedMissions(uid);
  }

  async getMissionProgress(uid, missionKey) {
    const missions = await missionRepository.getUserMissions(uid);
    
    if (!missions[missionKey]) {
      throw new Error('Mission non trouvée');
    }

    const mission = missions[missionKey];
    return {
      name: mission.name,
      progress: mission.progress || 0,
      total: mission.total || 0,
      completed: (mission.progress || 0) >= (mission.total || 0),
      recompenses: mission.nbRecompenses || 0
    };
  }

  async resetMission(uid, missionKey) {
    const reset = await missionRepository.resetMission(uid, missionKey);
    
    if (!reset) {
      throw new Error('Mission non trouvée ou impossible à réinitialiser');
    }

    return 'Mission réinitialisée avec succès';
  }

  async checkAllMissionsProgress(uid) {
    const missions = await missionRepository.getUserMissions(uid);
    const progress = {};

    Object.entries(missions).forEach(([key, mission]) => {
      progress[key] = {
        name: mission.name,
        progress: mission.progress || 0,
        total: mission.total || 0,
        completed: (mission.progress || 0) >= (mission.total || 0),
        percentage: Math.round(((mission.progress || 0) / (mission.total || 1)) * 100),
        recompenses: mission.nbRecompenses || 0
      };
    });

    return progress;
  }

  async getAvailableRewards(uid) {
    const missions = await missionRepository.getUserMissions(uid);
    const availableRewards = {};

    Object.entries(missions).forEach(([key, mission]) => {
      const isCompleted = (mission.progress || 0) >= (mission.total || 0);
      if (isCompleted) {
        availableRewards[key] = {
          name: mission.name,
          recompenses: mission.nbRecompenses || 0
        };
      }
    });

    return availableRewards;
  }

  // Méthodes spécifiques pour différents types de missions
  async updateAdventureMission(uid, adventureType) {
    const missionMap = {
      'onepiece': 'mission1',
      'snk': 'mission2', 
      'mha': 'mission3'
    };

    const missionKey = missionMap[adventureType];
    if (missionKey) {
      await this.updateMissionProgress(uid, missionKey);
    }
  }

  async updateScoreMission(uid, score, gameType) {
    if (gameType === 'whoami') {
      if (score >= 10) {
        await this.updateMissionProgress(uid, 'mission7');
      }
      if (score >= 15) {
        await this.updateMissionProgress(uid, 'mission8');
      }
    }
  }

  async updateStarMission(uid, stars, adventureType) {
    const missionMap = {
      'onepiece': 'mission17',
      'snk': 'mission18',
      'mha': 'mission19'
    };

    const missionKey = missionMap[adventureType];
    if (missionKey && stars > 0) {
      await this.incrementMissionProgress(uid, missionKey, stars);
    }
  }
}

module.exports = new MissionService();