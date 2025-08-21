const mockUsersCollection = {
  doc: jest.fn()
};

const mockDoc = {
  get: jest.fn(),
  update: jest.fn()
};

const mockDb = {
  collection: jest.fn().mockReturnValue(mockUsersCollection)
};

const mockFieldValue = {
  increment: jest.fn()
};

// Mock Firebase avec des valeurs persistantes
jest.mock('../../config/firebase', () => ({
  getDb: jest.fn(() => mockDb),
  getFieldValue: jest.fn(() => mockFieldValue)
}));

jest.mock('../../utils/constants', () => ({
  COLLECTION_NAMES: {
    USERS: 'users'
  }
}));

const firebaseConfig = require('../../config/firebase');

// Force la configuration des mocks avant tout import du repository
firebaseConfig.getDb.mockReturnValue(mockDb);
firebaseConfig.getFieldValue.mockReturnValue(mockFieldValue);
mockDb.collection.mockReturnValue(mockUsersCollection);
mockUsersCollection.doc.mockReturnValue(mockDoc);

describe('MissionRepository', () => {
  let missionRepository;

  beforeAll(() => {
    // Import du repository APRÈS que tous les mocks soient configurés
    missionRepository = require('../../repositories/missionRepository');
  });

  beforeEach(() => {
    // Reset seulement les appels, pas les implémentations
    jest.clearAllMocks();
    
    // S'assurer que les mocks sont toujours en place
    mockUsersCollection.doc.mockReturnValue(mockDoc);
    firebaseConfig.getFieldValue.mockReturnValue(mockFieldValue);
  });

  describe('getUserMissions', () => {
    it('devrait récupérer les missions d\'un utilisateur existant', async () => {
      // Arrange
      const uid = 'user_123';
      const missions = {
        mission1: { progress: 2, total: 5 },
        mission2: { progress: 1, total: 3 }
      };
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions, pseudo: 'TestUser' })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act
      const result = await missionRepository.getUserMissions(uid);

      // Assert
      expect(mockUsersCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockDoc.get).toHaveBeenCalled();
      expect(result).toEqual(missions);
    });

    it('devrait retourner un objet vide si l\'utilisateur n\'a pas de missions', async () => {
      // Arrange
      const uid = 'user_123';
      const mockUserDoc = {
        exists: true,
        data: () => ({ pseudo: 'TestUser' }) // Pas de missions
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act
      const result = await missionRepository.getUserMissions(uid);

      // Assert
      expect(result).toEqual({});
    });

    it('devrait lever une erreur si l\'utilisateur n\'existe pas', async () => {
      // Arrange
      const uid = 'inexistant_123';
      const mockUserDoc = { exists: false };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act & Assert
      await expect(missionRepository.getUserMissions(uid))
        .rejects.toThrow('Utilisateur non trouvé');
    });

    it('devrait propager les erreurs Firestore', async () => {
      // Arrange
      const uid = 'user_123';
      const error = new Error('Firestore error');
      mockDoc.get.mockRejectedValue(error);

      // Act & Assert
      await expect(missionRepository.getUserMissions(uid))
        .rejects.toThrow('Firestore error');
    });
  });

  describe('updateMissionProgress', () => {
    it('devrait mettre à jour le progrès d\'une mission existante', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const missions = {
        mission1: { progress: 2, total: 5 }
      };
      
      // Mock getUserMissions
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await missionRepository.updateMissionProgress(uid, missionKey);

      // Assert
      expect(result).toBe(true);
      expect(mockDoc.update).toHaveBeenCalledWith({
        missions: {
          mission1: { progress: 3, total: 5 }
        }
      });
    });

    it('devrait définir un progrès spécifique quand fourni', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const progress = 4;
      const missions = {
        mission1: { progress: 2, total: 5 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await missionRepository.updateMissionProgress(uid, missionKey, progress);

      // Assert
      expect(result).toBe(true);
      expect(mockDoc.update).toHaveBeenCalledWith({
        missions: {
          mission1: { progress: 4, total: 5 }
        }
      });
    });

    it('devrait limiter le progrès au total de la mission', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const progress = 10; // Plus que le total
      const missions = {
        mission1: { progress: 2, total: 5 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await missionRepository.updateMissionProgress(uid, missionKey, progress);

      // Assert
      expect(result).toBe(true);
      expect(mockDoc.update).toHaveBeenCalledWith({
        missions: {
          mission1: { progress: 5, total: 5 } // Limité au total
        }
      });
    });

    it('devrait retourner false si la mission n\'existe pas', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission_inexistante';
      const missions = {
        mission1: { progress: 2, total: 5 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act
      const result = await missionRepository.updateMissionProgress(uid, missionKey);

      // Assert
      expect(result).toBe(false);
      expect(mockDoc.update).not.toHaveBeenCalled();
    });

    it('devrait retourner false si la mission est déjà complétée', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const missions = {
        mission1: { progress: 5, total: 5 } // Déjà complétée
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act
      const result = await missionRepository.updateMissionProgress(uid, missionKey);

      // Assert
      expect(result).toBe(false);
      expect(mockDoc.update).not.toHaveBeenCalled();
    });
  });

  describe('incrementMissionProgress', () => {
    it('devrait incrémenter le progrès d\'une mission par défaut de 1', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const missions = {
        mission1: { progress: 2, total: 5 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await missionRepository.incrementMissionProgress(uid, missionKey);

      // Assert
      expect(result).toBe(true);
      expect(mockDoc.update).toHaveBeenCalledWith({
        missions: {
          mission1: { progress: 3, total: 5 }
        }
      });
    });

    it('devrait incrémenter le progrès d\'une mission avec une valeur spécifique', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const increment = 2;
      const missions = {
        mission1: { progress: 2, total: 5 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await missionRepository.incrementMissionProgress(uid, missionKey, increment);

      // Assert
      expect(result).toBe(true);
      expect(mockDoc.update).toHaveBeenCalledWith({
        missions: {
          mission1: { progress: 4, total: 5 }
        }
      });
    });

    it('devrait gérer les missions sans progrès initial', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const missions = {
        mission1: { total: 5 } // Pas de progress défini
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await missionRepository.incrementMissionProgress(uid, missionKey);

      // Assert
      expect(result).toBe(true);
      expect(mockDoc.update).toHaveBeenCalledWith({
        missions: {
          mission1: { progress: 1, total: 5 }
        }
      });
    });
  });

  describe('completeMission', () => {
    it('devrait compléter une mission et ajouter les récompenses', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const missions = {
        mission1: { progress: 5, total: 5, nbRecompenses: 100 },
        mission2: { progress: 1, total: 3, nbRecompenses: 50 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);
      mockDoc.update.mockResolvedValue();
      
      const incrementValue = 'mocked_increment_100';
      mockFieldValue.increment.mockReturnValue(incrementValue);

      // Act
      const result = await missionRepository.completeMission(uid, missionKey);

      // Assert
      expect(result).toBe(100);
      expect(mockFieldValue.increment).toHaveBeenCalledWith(100);
      expect(mockDoc.update).toHaveBeenCalledWith({
        missions: {
          mission2: { progress: 1, total: 3, nbRecompenses: 50 }
        },
        nbAmes: incrementValue
      });
    });

    it('devrait gérer les missions sans récompenses', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const missions = {
        mission1: { progress: 5, total: 5 } // Pas de nbRecompenses
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);
      mockDoc.update.mockResolvedValue();
      
      const incrementValue = 'mocked_increment_0';
      mockFieldValue.increment.mockReturnValue(incrementValue);

      // Act
      const result = await missionRepository.completeMission(uid, missionKey);

      // Assert
      expect(result).toBe(0);
      expect(mockFieldValue.increment).toHaveBeenCalledWith(0);
    });

    it('devrait lever une erreur si la mission n\'existe pas', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission_inexistante';
      const missions = {
        mission1: { progress: 2, total: 5 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act & Assert
      await expect(missionRepository.completeMission(uid, missionKey))
        .rejects.toThrow('Mission non trouvée');
    });
  });

  describe('isMissionCompleted', () => {
    it('devrait retourner true pour une mission complétée', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const missions = {
        mission1: { progress: 5, total: 5 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act
      const result = await missionRepository.isMissionCompleted(uid, missionKey);

      // Assert
      expect(result).toBe(true);
    });

    it('devrait retourner false pour une mission incomplète', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const missions = {
        mission1: { progress: 2, total: 5 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act
      const result = await missionRepository.isMissionCompleted(uid, missionKey);

      // Assert
      expect(result).toBe(false);
    });

    it('devrait retourner false pour une mission inexistante', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission_inexistante';
      const missions = {
        mission1: { progress: 2, total: 5 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act
      const result = await missionRepository.isMissionCompleted(uid, missionKey);

      // Assert
      expect(result).toBe(false);
    });
  });

  describe('getCompletedMissions', () => {
    it('devrait retourner seulement les missions complétées', async () => {
      // Arrange
      const uid = 'user_123';
      const missions = {
        mission1: { progress: 5, total: 5, nbRecompenses: 100 }, // Complétée
        mission2: { progress: 2, total: 3, nbRecompenses: 50 },  // Incomplète
        mission3: { progress: 10, total: 10, nbRecompenses: 75 }, // Complétée
        mission4: { progress: 1, total: 2, nbRecompenses: 25 }   // Incomplète
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act
      const result = await missionRepository.getCompletedMissions(uid);

      // Assert
      expect(result).toEqual({
        mission1: { progress: 5, total: 5, nbRecompenses: 100 },
        mission3: { progress: 10, total: 10, nbRecompenses: 75 }
      });
    });

    it('devrait retourner un objet vide si aucune mission n\'est complétée', async () => {
      // Arrange
      const uid = 'user_123';
      const missions = {
        mission1: { progress: 2, total: 5 },
        mission2: { progress: 1, total: 3 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act
      const result = await missionRepository.getCompletedMissions(uid);

      // Assert
      expect(result).toEqual({});
    });
  });

  describe('resetMission', () => {
    it('devrait remettre à zéro le progrès d\'une mission existante', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission1';
      const missions = {
        mission1: { progress: 3, total: 5 },
        mission2: { progress: 1, total: 3 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await missionRepository.resetMission(uid, missionKey);

      // Assert
      expect(result).toBe(true);
      expect(mockDoc.update).toHaveBeenCalledWith({
        missions: {
          mission1: { progress: 0, total: 5 },
          mission2: { progress: 1, total: 3 }
        }
      });
    });

    it('devrait retourner false pour une mission inexistante', async () => {
      // Arrange
      const uid = 'user_123';
      const missionKey = 'mission_inexistante';
      const missions = {
        mission1: { progress: 3, total: 5 }
      };
      
      const mockUserDoc = {
        exists: true,
        data: () => ({ missions })
      };
      mockDoc.get.mockResolvedValue(mockUserDoc);

      // Act
      const result = await missionRepository.resetMission(uid, missionKey);

      // Assert
      expect(result).toBe(false);
      expect(mockDoc.update).not.toHaveBeenCalled();
    });
  });

  describe('updateAllMissions', () => {
    it('devrait mettre à jour toutes les missions', async () => {
      // Arrange
      const uid = 'user_123';
      const missions = {
        mission1: { progress: 5, total: 5 },
        mission2: { progress: 2, total: 3 }
      };
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await missionRepository.updateAllMissions(uid, missions);

      // Assert
      expect(mockUsersCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockDoc.update).toHaveBeenCalledWith({ missions });
      expect(result).toBeUndefined();
    });

    it('devrait propager les erreurs de mise à jour', async () => {
      // Arrange
      const uid = 'user_123';
      const missions = { mission1: { progress: 1, total: 5 } };
      const error = new Error('Update failed');
      mockDoc.update.mockRejectedValue(error);

      // Act & Assert
      await expect(missionRepository.updateAllMissions(uid, missions))
        .rejects.toThrow('Update failed');
    });
  });

  describe('Initialisation', () => {
    it('devrait avoir accès à la base de données et la collection users', () => {
      // Assert - Vérifier que l'instance a bien ses propriétés
      expect(missionRepository).toBeDefined();
      expect(missionRepository.db).toBe(mockDb);
      expect(missionRepository.usersCollection).toBe(mockUsersCollection);
    });
  });
});

// Tests d'intégration
describe('MissionRepository - Workflow complet', () => {
  let missionRepository;

  beforeAll(() => {
    // Import du repository
    missionRepository = require('../../repositories/missionRepository');
  });

  beforeEach(() => {
    // Reset et configuration des mocks
    jest.clearAllMocks();
    
    mockUsersCollection.doc.mockReturnValue(mockDoc);
    firebaseConfig.getFieldValue.mockReturnValue(mockFieldValue);
  });

  it('devrait créer puis compléter une mission complète', async () => {
    // Arrange
    const uid = 'user_123';
    const missionKey = 'mission1';
    const missions = {
      mission1: { progress: 4, total: 5, nbRecompenses: 100 }
    };
    
    // Mock getUserMissions pour updateMissionProgress
    const mockUserDoc = {
      exists: true,
      data: () => ({ missions })
    };
    mockDoc.get.mockResolvedValue(mockUserDoc);
    mockDoc.update.mockResolvedValue();
    
    const incrementValue = 'mocked_increment_100';
    mockFieldValue.increment.mockReturnValue(incrementValue);

    // Act 1: Update mission to completion
    const updateResult = await missionRepository.updateMissionProgress(uid, missionKey);
    
    // Simulate mission completion for next call
    const completedMissions = {
      mission1: { progress: 5, total: 5, nbRecompenses: 100 }
    };
    mockDoc.get.mockResolvedValue({
      exists: true,
      data: () => ({ missions: completedMissions })
    });
    
    // Act 2: Complete mission
    const recompenses = await missionRepository.completeMission(uid, missionKey);

    // Assert
    expect(updateResult).toBe(true);
    expect(recompenses).toBe(100);
    expect(mockDoc.update).toHaveBeenCalledTimes(2);
  });

  it('devrait gérer un workflow d\'incrémentation multiple', async () => {
    // Arrange
    const uid = 'user_123';
    const missionKey = 'mission1';
    let currentProgress = 0;
    
    // Setup pour simuler des incréments successifs
    const getMockUserDoc = (progress) => ({
      exists: true,
      data: () => ({
        missions: {
          mission1: { progress, total: 5, nbRecompenses: 50 }
        }
      })
    });

    mockDoc.update.mockResolvedValue();

    // Act - Incrémenter 3 fois
    for (let i = 1; i <= 3; i++) {
      mockDoc.get.mockResolvedValue(getMockUserDoc(currentProgress));
      const result = await missionRepository.incrementMissionProgress(uid, missionKey);
      expect(result).toBe(true);
      currentProgress++;
    }

    // Assert
    expect(mockDoc.update).toHaveBeenCalledTimes(3);
  });

  it('devrait gérer un reset puis une progression de mission', async () => {
    // Arrange
    const uid = 'user_123';
    const missionKey = 'mission1';
    const missions = {
      mission1: { progress: 3, total: 5, nbRecompenses: 100 }
    };

    mockDoc.get.mockResolvedValue({
      exists: true,
      data: () => ({ missions })
    });
    mockDoc.update.mockResolvedValue();

    // Act 1: Reset mission
    const resetResult = await missionRepository.resetMission(uid, missionKey);

    // Mock pour après le reset
    const resetMissions = {
      mission1: { progress: 0, total: 5, nbRecompenses: 100 }
    };
    mockDoc.get.mockResolvedValue({
      exists: true,
      data: () => ({ missions: resetMissions })
    });

    // Act 2: Update progress after reset
    const updateResult = await missionRepository.updateMissionProgress(uid, missionKey);

    // Assert
    expect(resetResult).toBe(true);
    expect(updateResult).toBe(true);
    expect(mockDoc.update).toHaveBeenCalledTimes(2);
  });
});