const firebaseConfig = require('../config/firebase');
const { COLLECTION_NAMES } = require('../utils/constants');

class MissionRepository {
  constructor() {
    this.db = firebaseConfig.getDb();
    this.usersCollection = this.db.collection(COLLECTION_NAMES.USERS);
  }

  async getUserMissions(uid) {
    const userDoc = await this.usersCollection.doc(uid).get();
    if (!userDoc.exists) {
      throw new Error('Utilisateur non trouvé');
    }
    
    return userDoc.data().missions || {};
  }

  async updateMissionProgress(uid, missionKey, progress = null) {
    const missions = await this.getUserMissions(uid);
    
    if (!missions[missionKey]) {
      return false; // Mission n'existe pas
    }

    const mission = missions[missionKey];
    const currentProgress = mission.progress || 0;
    const total = mission.total || 0;

    if (currentProgress >= total) {
      return false; // Mission déjà complétée
    }

    // Si progress n'est pas spécifié, on incrémente de 1
    if (progress === null) {
      mission.progress = Math.min(currentProgress + 1, total);
    } else {
      mission.progress = Math.min(progress, total);
    }

    missions[missionKey] = mission;
    
    await this.usersCollection.doc(uid).update({ missions });
    return true;
  }

  async incrementMissionProgress(uid, missionKey, increment = 1) {
    const missions = await this.getUserMissions(uid);
    
    if (!missions[missionKey]) {
      return false;
    }

    const mission = missions[missionKey];
    const currentProgress = mission.progress || 0;
    const total = mission.total || 0;

    if (currentProgress >= total) {
      return false;
    }

    mission.progress = Math.min(currentProgress + increment, total);
    missions[missionKey] = mission;
    
    await this.usersCollection.doc(uid).update({ missions });
    return true;
  }

  async completeMission(uid, missionKey) {
    const missions = await this.getUserMissions(uid);
    
    if (!missions[missionKey]) {
      throw new Error('Mission non trouvée');
    }

    const mission = missions[missionKey];
    const recompenses = mission.nbRecompenses || 0;

    // Supprimer la mission
    delete missions[missionKey];

    // Mettre à jour les missions et ajouter les récompenses
    const updates = {
      missions: missions,
      nbAmes: firebaseConfig.getFieldValue().increment(recompenses)
    };

    await this.usersCollection.doc(uid).update(updates);
    return recompenses;
  }

  async isMissionCompleted(uid, missionKey) {
    const missions = await this.getUserMissions(uid);
    
    if (!missions[missionKey]) {
      return false;
    }

    const mission = missions[missionKey];
    return (mission.progress || 0) >= (mission.total || 0);
  }

  async getCompletedMissions(uid) {
    const missions = await this.getUserMissions(uid);
    const completed = {};

    Object.entries(missions).forEach(([key, mission]) => {
      if ((mission.progress || 0) >= (mission.total || 0)) {
        completed[key] = mission;
      }
    });

    return completed;
  }

  async resetMission(uid, missionKey) {
    const missions = await this.getUserMissions(uid);
    
    if (missions[missionKey]) {
      missions[missionKey].progress = 0;
      await this.usersCollection.doc(uid).update({ missions });
      return true;
    }
    
    return false;
  }

  async updateAllMissions(uid, missions) {
  return await this.usersCollection.doc(uid).update({ missions });
}

}

module.exports = new MissionRepository();