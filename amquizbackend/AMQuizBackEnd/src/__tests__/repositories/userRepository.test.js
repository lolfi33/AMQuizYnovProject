const mockCollection = {
  doc: jest.fn(),
  where: jest.fn().mockReturnThis(),
  get: jest.fn()
};

const mockDoc = {
  set: jest.fn(),
  get: jest.fn(),
  update: jest.fn(),
  delete: jest.fn()
};

const mockDb = {
  collection: jest.fn().mockReturnValue(mockCollection)
};

const mockFieldValue = {
  increment: jest.fn(),
  arrayUnion: jest.fn(),
  arrayRemove: jest.fn()
};

const mockAuth = {
  getUserByEmail: jest.fn(),
  createUser: jest.fn()
};

// Mock Firebase avec des valeurs persistantes
jest.mock('../../config/firebase', () => ({
  getDb: jest.fn(() => mockDb),
  getServerTimestamp: jest.fn(() => 'mocked_timestamp'),
  getFieldValue: jest.fn(() => mockFieldValue),
  getAuth: jest.fn(() => mockAuth)
}));

jest.mock('../../utils/constants', () => ({
  COLLECTION_NAMES: {
    USERS: 'users'
  }
}));

// Import APRÈS les mocks
const firebaseConfig = require('../../config/firebase');

// Force la configuration des mocks avant tout import du repository
firebaseConfig.getDb.mockReturnValue(mockDb);
firebaseConfig.getServerTimestamp.mockReturnValue('mocked_timestamp');
firebaseConfig.getFieldValue.mockReturnValue(mockFieldValue);
firebaseConfig.getAuth.mockReturnValue(mockAuth);
mockDb.collection.mockReturnValue(mockCollection);
mockCollection.doc.mockReturnValue(mockDoc);

describe('UserRepository', () => {
  let userRepository;

  beforeAll(() => {
    // Import du repository APRÈS que tous les mocks soient configurés
    userRepository = require('../../repositories/userRepository');
  });

  beforeEach(() => {
    // Reset seulement les appels, pas les implémentations
    jest.clearAllMocks();
    
    // S'assurer que les mocks sont toujours en place
    mockCollection.doc.mockReturnValue(mockDoc);
    mockCollection.where.mockReturnThis();
    firebaseConfig.getFieldValue.mockReturnValue(mockFieldValue);
    firebaseConfig.getAuth.mockReturnValue(mockAuth);
  });

  describe('createUser', () => {
    it('devrait créer un utilisateur avec succès', async () => {
      // Arrange
      const uid = 'user_123';
      const userData = {
        pseudo: 'TestUser',
        email: 'test@example.com'
      };
      mockDoc.set.mockResolvedValue();

      // Act
      const result = await userRepository.createUser(uid, userData);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockDoc.set).toHaveBeenCalledWith(userData);
      expect(result).toBeUndefined();
    });

    it('devrait propager l\'erreur si la création échoue', async () => {
      // Arrange
      const uid = 'user_123';
      const userData = { pseudo: 'TestUser' };
      const error = new Error('Firestore error');
      mockDoc.set.mockRejectedValue(error);

      // Act & Assert
      await expect(userRepository.createUser(uid, userData))
        .rejects.toThrow('Firestore error');
    });
  });

  describe('getUserByUid', () => {
    it('devrait récupérer un utilisateur existant', async () => {
      // Arrange
      const uid = 'user_123';
      const userData = { pseudo: 'TestUser', email: 'test@example.com' };
      const mockDocData = {
        exists: true,
        id: uid,
        data: () => userData
      };
      mockDoc.get.mockResolvedValue(mockDocData);

      // Act
      const result = await userRepository.getUserByUid(uid);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockDoc.get).toHaveBeenCalled();
      expect(result).toEqual({ id: uid, ...userData });
    });

    it('devrait retourner null pour un utilisateur inexistant', async () => {
      // Arrange
      const uid = 'inexistant_123';
      const mockDocData = {
        exists: false
      };
      mockDoc.get.mockResolvedValue(mockDocData);

      // Act
      const result = await userRepository.getUserByUid(uid);

      // Assert
      expect(result).toBeNull();
    });

    it('devrait gérer les erreurs Firestore', async () => {
      // Arrange
      const uid = 'user_123';
      const error = new Error('Firestore query failed');
      mockDoc.get.mockRejectedValue(error);

      // Act & Assert
      await expect(userRepository.getUserByUid(uid))
        .rejects.toThrow('Firestore query failed');
    });
  });

  describe('getUserByPseudo', () => {
    it('devrait récupérer un utilisateur par pseudo', async () => {
      // Arrange
      const pseudo = 'TestUser';
      const userData = { pseudo, email: 'test@example.com' };
      const mockDocs = [{ id: 'user_123', data: () => userData }];
      const mockSnapshot = { empty: false, docs: mockDocs };
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await userRepository.getUserByPseudo(pseudo);

      // Assert
      expect(mockCollection.where).toHaveBeenCalledWith('pseudo', '==', pseudo);
      expect(mockCollection.get).toHaveBeenCalled();
      expect(result).toEqual({ id: 'user_123', ...userData });
    });

    it('devrait retourner null si aucun utilisateur trouvé', async () => {
      // Arrange
      const pseudo = 'InexistantUser';
      const mockSnapshot = { empty: true };
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await userRepository.getUserByPseudo(pseudo);

      // Assert
      expect(result).toBeNull();
    });

    it('devrait gérer les erreurs de requête', async () => {
      // Arrange
      const pseudo = 'TestUser';
      const error = new Error('Query failed');
      mockCollection.get.mockRejectedValue(error);

      // Act & Assert
      await expect(userRepository.getUserByPseudo(pseudo))
        .rejects.toThrow('Query failed');
    });
  });

  describe('updateUser', () => {
    it('devrait mettre à jour un utilisateur', async () => {
      // Arrange
      const uid = 'user_123';
      const updateData = { pseudo: 'NewPseudo' };
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await userRepository.updateUser(uid, updateData);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockDoc.update).toHaveBeenCalledWith(updateData);
      expect(result).toBeUndefined();
    });

    it('devrait propager l\'erreur si la mise à jour échoue', async () => {
      // Arrange
      const uid = 'user_123';
      const updateData = { pseudo: 'NewPseudo' };
      const error = new Error('Update failed');
      mockDoc.update.mockRejectedValue(error);

      // Act & Assert
      await expect(userRepository.updateUser(uid, updateData))
        .rejects.toThrow('Update failed');
    });
  });

  describe('deleteUser', () => {
    it('devrait supprimer un utilisateur', async () => {
      // Arrange
      const uid = 'user_123';
      mockDoc.delete.mockResolvedValue();

      // Act
      const result = await userRepository.deleteUser(uid);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockDoc.delete).toHaveBeenCalled();
      expect(result).toBeUndefined();
    });

    it('devrait propager l\'erreur si la suppression échoue', async () => {
      // Arrange
      const uid = 'user_123';
      const error = new Error('Delete failed');
      mockDoc.delete.mockRejectedValue(error);

      // Act & Assert
      await expect(userRepository.deleteUser(uid))
        .rejects.toThrow('Delete failed');
    });
  });

  describe('incrementField', () => {
    it('devrait incrémenter un champ avec une valeur par défaut', async () => {
      // Arrange
      const uid = 'user_123';
      const field = 'score';
      const incrementValue = firebaseConfig.getFieldValue().increment(1);
      mockFieldValue.increment.mockReturnValue(incrementValue);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await userRepository.incrementField(uid, field);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockFieldValue.increment).toHaveBeenCalledWith(1);
      expect(mockDoc.update).toHaveBeenCalledWith({ [field]: incrementValue });
      expect(result).toBeUndefined();
    });

    it('devrait incrémenter un champ avec une valeur spécifique', async () => {
      // Arrange
      const uid = 'user_123';
      const field = 'score';
      const value = 5;
      const incrementValue = firebaseConfig.getFieldValue().increment(value);
      mockFieldValue.increment.mockReturnValue(incrementValue);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await userRepository.incrementField(uid, field, value);

      // Assert
      expect(mockFieldValue.increment).toHaveBeenCalledWith(value);
      expect(mockDoc.update).toHaveBeenCalledWith({ [field]: incrementValue });
    });
  });


  describe('arrayUnion', () => {
    it('devrait ajouter une valeur à un tableau', async () => {
      // Arrange
      const uid = 'user_123';
      const field = 'badges';
      const value = 'newBadge';
      const unionValue = firebaseConfig.getFieldValue().arrayUnion(value);
      mockFieldValue.arrayUnion.mockReturnValue(unionValue);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await userRepository.arrayUnion(uid, field, value);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockFieldValue.arrayUnion).toHaveBeenCalledWith(value);
      expect(mockDoc.update).toHaveBeenCalledWith({ [field]: unionValue });
      expect(result).toBeUndefined();
    });
  });

  describe('arrayRemove', () => {
    it('devrait retirer une valeur d\'un tableau', async () => {
      // Arrange
      const uid = 'user_123';
      const field = 'badges';
      const value = 'oldBadge';
      const removeValue = firebaseConfig.getFieldValue().arrayRemove(value);
      mockFieldValue.arrayRemove.mockReturnValue(removeValue);
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await userRepository.arrayRemove(uid, field, value);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockFieldValue.arrayRemove).toHaveBeenCalledWith(value);
      expect(mockDoc.update).toHaveBeenCalledWith({ [field]: removeValue });
      expect(result).toBeUndefined();
    });
  });

  describe('updateMissions', () => {
    it('devrait mettre à jour les missions', async () => {
      // Arrange
      const uid = 'user_123';
      const missions = { mission1: 'completed', mission2: 'in_progress' };
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await userRepository.updateMissions(uid, missions);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockDoc.update).toHaveBeenCalledWith({ missions });
      expect(result).toBeUndefined();
    });
  });

  describe('updateRecords', () => {
    it('devrait mettre à jour les records', async () => {
      // Arrange
      const uid = 'user_123';
      const recordField = 'quizRecords';
      const records = { quiz1: 100, quiz2: 85 };
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await userRepository.updateRecords(uid, recordField, records);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockDoc.update).toHaveBeenCalledWith({ [recordField]: records });
      expect(result).toBeUndefined();
    });
  });

  describe('updateItemsList', () => {
    it('devrait mettre à jour la liste d\'items', async () => {
      // Arrange
      const uid = 'user_123';
      const listeItems = { item1: 5, item2: 3 };
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await userRepository.updateItemsList(uid, listeItems);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockDoc.update).toHaveBeenCalledWith({ listeItems });
      expect(result).toBeUndefined();
    });
  });

  describe('checkEmailExists', () => {
    it('devrait retourner true si l\'email existe', async () => {
      // Arrange
      const email = 'test@example.com';
      mockAuth.getUserByEmail.mockResolvedValue({ uid: 'user_123' });

      // Act
      const result = await userRepository.checkEmailExists(email);

      // Assert
      expect(mockAuth.getUserByEmail).toHaveBeenCalledWith(email);
      expect(result).toBe(true);
    });

    it('devrait retourner false si l\'email n\'existe pas', async () => {
      // Arrange
      const email = 'nonexistent@example.com';
      mockAuth.getUserByEmail.mockRejectedValue(new Error('User not found'));

      // Act
      const result = await userRepository.checkEmailExists(email);

      // Assert
      expect(mockAuth.getUserByEmail).toHaveBeenCalledWith(email);
      expect(result).toBe(false);
    });
  });

  describe('createAuthUser', () => {
    it('devrait créer un utilisateur d\'authentification', async () => {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const expectedUser = { uid: 'new_user_123' };
      mockAuth.createUser.mockResolvedValue(expectedUser);

      // Act
      const result = await userRepository.createAuthUser(email, password);

      // Assert
      expect(mockAuth.createUser).toHaveBeenCalledWith({
        email: email,
        password: password
      });
      expect(result).toEqual(expectedUser);
    });

    it('devrait propager l\'erreur si la création échoue', async () => {
      // Arrange
      const email = 'test@example.com';
      const password = 'weak';
      const error = new Error('Weak password');
      mockAuth.createUser.mockRejectedValue(error);

      // Act & Assert
      await expect(userRepository.createAuthUser(email, password))
        .rejects.toThrow('Weak password');
    });
  });

  describe('incrementUserFields', () => {
    it('devrait incrémenter plusieurs champs à la fois', async () => {
      // Arrange
      const uid = 'user_123';
      const fields = { score: 10, level: 1, coins: 50 };
      
      // Configuration des mocks pour chaque increment
      mockFieldValue.increment.mockReturnValueOnce('increment_score_10');
      mockFieldValue.increment.mockReturnValueOnce('increment_level_1');
      mockFieldValue.increment.mockReturnValueOnce('increment_coins_50');
      
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await userRepository.incrementUserFields(uid, fields);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(uid);
      expect(mockFieldValue.increment).toHaveBeenCalledWith(10);
      expect(mockFieldValue.increment).toHaveBeenCalledWith(1);
      expect(mockFieldValue.increment).toHaveBeenCalledWith(50);
      expect(mockDoc.update).toHaveBeenCalledWith({
        score: 'increment_score_10',
        level: 'increment_level_1',
        coins: 'increment_coins_50'
      });
      expect(result).toBeUndefined();
    });

    it('devrait gérer un objet fields vide', async () => {
      // Arrange
      const uid = 'user_123';
      const fields = {};
      mockDoc.update.mockResolvedValue();

      // Act
      const result = await userRepository.incrementUserFields(uid, fields);

      // Assert
      expect(mockDoc.update).toHaveBeenCalledWith({});
      expect(result).toBeUndefined();
    });
  });

  describe('Initialisation', () => {
    it('devrait avoir accès à la base de données et la collection', () => {
      // Assert - Vérifier que l'instance a bien ses propriétés
      expect(userRepository).toBeDefined();
      expect(userRepository.db).toBe(mockDb);
      expect(userRepository.collection).toBe(mockCollection);
    });
  });
});

// Tests d'intégration
describe('UserRepository - Workflow complet', () => {
  let userRepository;

  beforeAll(() => {
    // Import du repository
    userRepository = require('../../repositories/userRepository');
  });

  beforeEach(() => {
    // Reset et configuration des mocks
    jest.clearAllMocks();
    
    mockCollection.doc.mockReturnValue(mockDoc);
    mockCollection.where.mockReturnThis();
    firebaseConfig.getFieldValue.mockReturnValue(mockFieldValue);
    firebaseConfig.getAuth.mockReturnValue(mockAuth);
  });

  it('devrait créer puis récupérer un utilisateur', async () => {
    // Arrange
    const uid = 'user_123';
    const userData = { pseudo: 'TestUser', email: 'test@example.com' };
    
    // Mock création
    mockDoc.set.mockResolvedValue();
    
    // Mock récupération
    mockDoc.get.mockResolvedValue({
      exists: true,
      id: uid,
      data: () => userData
    });

    // Act
    await userRepository.createUser(uid, userData);
    const retrievedUser = await userRepository.getUserByUid(uid);

    // Assert
    expect(retrievedUser).toEqual({ id: uid, ...userData });
  });

  it('devrait créer, mettre à jour puis supprimer un utilisateur', async () => {
    // Arrange
    const uid = 'user_123';
    const userData = { pseudo: 'TestUser' };
    const updateData = { pseudo: 'UpdatedUser' };

    // Mock toutes les opérations
    mockDoc.set.mockResolvedValue();
    mockDoc.update.mockResolvedValue();
    mockDoc.delete.mockResolvedValue();

    // Act
    await userRepository.createUser(uid, userData);
    await userRepository.updateUser(uid, updateData);
    await userRepository.deleteUser(uid);

    // Assert
    expect(mockDoc.set).toHaveBeenCalledWith(userData);
    expect(mockDoc.update).toHaveBeenCalledWith(updateData);
    expect(mockDoc.delete).toHaveBeenCalled();
  });

  it('devrait gérer les opérations de champs complexes', async () => {
    // Arrange
    const uid = 'user_123';
    
    mockDoc.update.mockResolvedValue();
    mockFieldValue.increment.mockReturnValue('mocked_increment');
    mockFieldValue.arrayUnion.mockReturnValue('mocked_union');

    // Act
    await userRepository.incrementField(uid, 'score', 10);
    await userRepository.setServerTimestamp(uid, 'lastLogin');
    await userRepository.arrayUnion(uid, 'badges', 'newBadge');

    // Assert
    expect(mockDoc.update).toHaveBeenCalledTimes(3);
    expect(mockFieldValue.increment).toHaveBeenCalledWith(10);
    expect(mockFieldValue.arrayUnion).toHaveBeenCalledWith('newBadge');
  });
});