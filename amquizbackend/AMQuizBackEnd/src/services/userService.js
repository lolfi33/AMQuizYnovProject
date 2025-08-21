// src/services/userService.js
const userRepository = require('../repositories/userRepository');
const itemRepository = require('../repositories/itemRepository');
const missionRepository = require('../repositories/missionRepository');
const { validateBiography, validateTitle } = require('../utils/validators');
const { sanitizeInput, compareMaps } = require('../utils/helpers');
const { INITIAL_MISSIONS } = require('../utils/constants');

class UserService {
  async createUserProfile(uid, pseudo) {
    // Récupérer les items de base
    const defaultItems = await itemRepository.getMultipleItemsById(['zoro', 'luffy', 'nami', 'ussop']);
    const banniereProfil = await itemRepository.getItemById('laboonBanniere');

    const userData = {
      uidUser: uid,
      pseudo: pseudo,
      biographie: 'Je suis nouveau !',
      titre: 'Baka novice',
      urlImgProfil: 'assets/images/profil/zoro.png',
      nbLike: 0,
      nbVie: 5,
      dateDernierLike: new Date(Date.now() - 24 * 60 * 60 * 1000),
      banniereProfil: banniereProfil,
      nbAmes: 0,
      nbCoffreCommun: 0,
      nbCoffreRare: 0,
      nbCoffreLegendaire: 0,
      nbLettreCommun: 0,
      nbLettreRare: 0,
      nbLettreLegendaire: 0,
      amis: [],
      invitations: [],
      uidInvitations: [],
      listeTitres: ['pirate', 'Baka novice'],
      hasDoneTuto: false,
      missions: INITIAL_MISSIONS,
      presence: true,
      listeItems: defaultItems,
      recordsOnePiece: [1, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      recordsMHA: [1, 0, 0, 0, 0, 0, 0, 0],
      recordsSNK: [1, 0, 0, 0, 0, 0, 0, 0],
    };

    await userRepository.createUser(uid, userData);
    return userData;
  }

  async updateBiography(uid, newBiography) {
    const sanitizedBiography = sanitizeInput(newBiography);
    
    const validation = validateBiography(sanitizedBiography);
    if (!validation.isValid) {
      throw new Error(validation.error);
    }

    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    if (user.biographie === sanitizedBiography) {
      throw new Error('Aucune modification détectée');
    }

    await userRepository.updateUser(uid, { biographie: sanitizedBiography });
    await missionRepository.updateMissionProgress(uid, 'mission10');
  }

  async updateTitle(uid, newTitle) {
    const sanitizedTitle = sanitizeInput(newTitle);
    
    const validation = validateTitle(sanitizedTitle);
    if (!validation.isValid) {
      throw new Error(validation.error);
    }

    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    if (user.titre === sanitizedTitle) {
      throw new Error('Aucune modification détectée');
    }

    await userRepository.updateUser(uid, { titre: sanitizedTitle });
    await missionRepository.updateMissionProgress(uid, 'mission11');
  }

  async updateProfilePicture(uid, newUrlImgProfil) {
    const sanitizedUrl = sanitizeInput(newUrlImgProfil);

    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    if (user.urlImgProfil === sanitizedUrl) {
      throw new Error('Aucune modification détectée');
    }

    await userRepository.updateUser(uid, { urlImgProfil: sanitizedUrl });
    await missionRepository.updateMissionProgress(uid, 'mission14');
  }

  async updateBanner(uid, newBanniereProfil) {
    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    const isIdentical = compareMaps(user.banniereProfil, newBanniereProfil);
    if (isIdentical) {
      throw new Error('Aucune modification détectée');
    }

    await userRepository.updateUser(uid, { banniereProfil: newBanniereProfil });
    await missionRepository.updateMissionProgress(uid, 'mission15');
  }

  async sendLike(uid, targetUid) {
    if (!targetUid) {
      throw new Error('UID de l\'utilisateur liké manquant');
    }

    const targetUser = await userRepository.getUserByUid(targetUid);
    if (!targetUser) {
      throw new Error('Utilisateur cible non trouvé');
    }

    // Mettre à jour la date du dernier like
    await userRepository.setServerTimestamp(uid, 'dateDernierLike');
    
    // Incrémenter les likes du destinataire
    await userRepository.incrementField(targetUid, 'nbLike');
    
  // Mettre à jour les missions
  await missionRepository.updateMissionProgress(uid, 'mission12');
  await missionRepository.updateMissionProgress(uid, 'mission13');
  
  // Mettre à jour les daily missions
  await missionRepository.updateDailyMissionByType(uid, 'sendLike');
  }

  async updatePresence(uid, isOnline) {
    if (typeof isOnline !== 'boolean') {
      throw new Error('Statut de présence non valide');
    }

    await userRepository.updateUser(uid, { presence: isOnline });
  }

  async deleteUser(uid) {
    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    await userRepository.deleteUser(uid);
  }

  async loseLife(uid) {
    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    const nbVie = user.nbVie || 0;
    if (nbVie <= 0) {
      throw new Error('Aucune vie restante');
    }

    await userRepository.incrementField(uid, 'nbVie', -1);
  }

  async updateRecords(uid, recordType, indexRecord, nouveauRecord) {
    const validRecordTypes = ['recordsOnePiece', 'recordsSNK', 'recordsMHA'];
    if (!validRecordTypes.includes(recordType)) {
      throw new Error('Type de record invalide');
    }

    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    const records = user[recordType] || [];
    if (indexRecord < 0 || indexRecord >= records.length) {
      throw new Error('Index de record invalide');
    }

    records[indexRecord] = nouveauRecord;
    await userRepository.updateRecords(uid, recordType, records);

    // Mettre à jour les missions selon le type de record
    const missionMap = {
      'recordsOnePiece': 'mission17',
      'recordsSNK': 'mission18',
      'recordsMHA': 'mission19'
    };

    const missionKey = missionMap[recordType];
    if (nouveauRecord > 79) {
      await missionRepository.updateMissionProgress(uid, missionKey);
    }
    if (nouveauRecord > 89) {
      await missionRepository.updateMissionProgress(uid, missionKey);
    }
    if (nouveauRecord > 99) {
      await missionRepository.updateMissionProgress(uid, missionKey);
    }
  }

  async unlockNextLevel(uid, recordType, indexRecord) {
    const validRecordTypes = ['recordsOnePiece', 'recordsSNK', 'recordsMHA'];
    if (!validRecordTypes.includes(recordType)) {
      throw new Error('Type de record invalide');
    }

    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    const records = user[recordType] || [];
    if (indexRecord + 1 >= records.length) {
      throw new Error('Index de record invalide ou hors limites');
    }

    if (records[indexRecord + 1] === 0) {
      records[indexRecord + 1] = 1;
      await userRepository.updateRecords(uid, recordType, records);

      // Mettre à jour les missions selon le type
      const missionMap = {
        'recordsOnePiece': 'mission1',
        'recordsSNK': 'mission2',
        'recordsMHA': 'mission3'
      };

      await missionRepository.updateMissionProgress(uid, missionMap[recordType]);
      return true;
    }

    return false;
  }

  async completeOnlineQuiz(uid) {
    await missionRepository.updateMissionProgress(uid, 'mission6');
  }

  async completeWhoAmI10Points(uid) {
    await missionRepository.updateMissionProgress(uid, 'mission7');
  }

  async completeWhoAmI15Points(uid) {
    await missionRepository.updateMissionProgress(uid, 'mission8');
  }
}

module.exports = new UserService();