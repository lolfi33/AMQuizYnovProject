const mockCollection = {
  add: jest.fn(),
  where: jest.fn().mockReturnThis(),
  orderBy: jest.fn().mockReturnThis(),
  get: jest.fn(),
  doc: jest.fn()
};

const mockDoc = {
  delete: jest.fn()
};

const mockDb = {
  collection: jest.fn().mockReturnValue(mockCollection)
};

// Mock Firebase avec des valeurs persistantes
jest.mock('../../config/firebase', () => ({
  getDb: jest.fn(() => mockDb),
  getServerTimestamp: jest.fn(() => 'mocked_timestamp')
}));

jest.mock('../../utils/constants', () => ({
  COLLECTION_NAMES: {
    SIGNALEMENTS: 'signalements'
  }
}));

// Import APRÈS les mocks
const firebaseConfig = require('../../config/firebase');

// Force la configuration des mocks avant tout import du repository
firebaseConfig.getDb.mockReturnValue(mockDb);
firebaseConfig.getServerTimestamp.mockReturnValue('mocked_timestamp');
mockDb.collection.mockReturnValue(mockCollection);
mockCollection.doc.mockReturnValue(mockDoc);

describe('SignalementRepository', () => {
  let signalementRepository;

  beforeAll(() => {
    // Import du repository APRÈS que tous les mocks soient configurés
    signalementRepository = require('../../repositories/signalementRepository');
  });

  beforeEach(() => {
    // Reset seulement les appels, pas les implémentations
    jest.clearAllMocks();
    
    // S'assurer que les mocks sont toujours en place
    mockCollection.where.mockReturnThis();
    mockCollection.orderBy.mockReturnThis();
    mockCollection.doc.mockReturnValue(mockDoc);
  });


  describe('getSignalementsByUser', () => {
    it('devrait récupérer les signalements pour un utilisateur spécifique', async () => {
      // Arrange
      const uidJoueurQuiAEteSignale = 'reported_123';
      const mockDocs = [
        { id: 'sig1', data: () => ({ raison: 'Spam' }) },
        { id: 'sig2', data: () => ({ raison: 'Harcèlement' }) }
      ];
      const mockSnapshot = { docs: mockDocs };

      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await signalementRepository.getSignalementsByUser(uidJoueurQuiAEteSignale);

      // Assert
      expect(mockCollection.where).toHaveBeenCalledWith('uidJoueurQuiAEteSignale', '==', uidJoueurQuiAEteSignale);
      expect(mockCollection.get).toHaveBeenCalled();
      expect(result).toEqual([
        { id: 'sig1', raison: 'Spam' },
        { id: 'sig2', raison: 'Harcèlement' }
      ]);
    });

    it('devrait retourner un tableau vide si aucun signalement trouvé', async () => {
      // Arrange
      const uidJoueurQuiAEteSignale = 'inexistant_123';
      const mockSnapshot = { docs: [] };
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await signalementRepository.getSignalementsByUser(uidJoueurQuiAEteSignale);

      // Assert
      expect(result).toEqual([]);
    });

    it('devrait gérer les erreurs Firebase', async () => {
      // Arrange
      const uidJoueurQuiAEteSignale = 'reported_123';
      const error = new Error('Firebase query failed');
      mockCollection.get.mockRejectedValue(error);

      // Act & Assert
      await expect(signalementRepository.getSignalementsByUser(uidJoueurQuiAEteSignale))
        .rejects.toThrow('Firebase query failed');
    });
  });

  describe('getAllSignalements', () => {
    it('devrait récupérer tous les signalements triés par date décroissante', async () => {
      // Arrange
      const mockDocs = [
        { id: 'sig1', data: () => ({ date: '2023-12-01', raison: 'Spam' }) },
        { id: 'sig2', data: () => ({ date: '2023-11-01', raison: 'Harcèlement' }) }
      ];
      const mockSnapshot = { docs: mockDocs };
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await signalementRepository.getAllSignalements();

      // Assert
      expect(mockCollection.orderBy).toHaveBeenCalledWith('date', 'desc');
      expect(mockCollection.get).toHaveBeenCalled();
      expect(result).toEqual([
        { id: 'sig1', date: '2023-12-01', raison: 'Spam' },
        { id: 'sig2', date: '2023-11-01', raison: 'Harcèlement' }
      ]);
    });

    it('devrait retourner un tableau vide si aucun signalement existe', async () => {
      // Arrange
      const mockSnapshot = { docs: [] };
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await signalementRepository.getAllSignalements();

      // Assert
      expect(result).toEqual([]);
    });

    it('devrait gérer les erreurs de récupération', async () => {
      // Arrange
      const error = new Error('Erreur de connexion');
      mockCollection.get.mockRejectedValue(error);

      // Act & Assert
      await expect(signalementRepository.getAllSignalements())
        .rejects.toThrow('Erreur de connexion');
    });
  });

  describe('deleteSignalement', () => {
    it('devrait supprimer un signalement avec succès', async () => {
      // Arrange
      const signalementId = 'signalement_123';
      mockDoc.delete.mockResolvedValue();

      // Act
      const result = await signalementRepository.deleteSignalement(signalementId);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(signalementId);
      expect(mockDoc.delete).toHaveBeenCalled();
      expect(result).toBeUndefined();
    });

    it('devrait propager l\'erreur si la suppression échoue', async () => {
      // Arrange
      const signalementId = 'signalement_123';
      const error = new Error('Document non trouvé');
      mockDoc.delete.mockRejectedValue(error);

      // Act & Assert
      await expect(signalementRepository.deleteSignalement(signalementId))
        .rejects.toThrow('Document non trouvé');
    });

    it('devrait gérer les signalements avec un ID vide', async () => {
      // Arrange
      const signalementId = '';
      mockDoc.delete.mockResolvedValue();
      
      // Act
      await signalementRepository.deleteSignalement(signalementId);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith('');
    });
  });

  describe('getSignalementsByReporter', () => {
    it('devrait récupérer les signalements créés par un utilisateur', async () => {
      // Arrange
      const uidJoueur = 'reporter_123';
      const mockDocs = [
        { id: 'sig1', data: () => ({ uidJoueur: 'reporter_123', raison: 'Spam' }) },
        { id: 'sig2', data: () => ({ uidJoueur: 'reporter_123', raison: 'Contenu inapproprié' }) }
      ];
      const mockSnapshot = { docs: mockDocs };
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await signalementRepository.getSignalementsByReporter(uidJoueur);

      // Assert
      expect(mockCollection.where).toHaveBeenCalledWith('uidJoueur', '==', uidJoueur);
      expect(mockCollection.get).toHaveBeenCalled();
      expect(result).toEqual([
        { id: 'sig1', uidJoueur: 'reporter_123', raison: 'Spam' },
        { id: 'sig2', uidJoueur: 'reporter_123', raison: 'Contenu inapproprié' }
      ]);
    });

    it('devrait retourner un tableau vide pour un utilisateur sans signalements', async () => {
      // Arrange
      const uidJoueur = 'nouveau_123';
      const mockSnapshot = { docs: [] };
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await signalementRepository.getSignalementsByReporter(uidJoueur);

      // Assert
      expect(result).toEqual([]);
    });

    it('devrait gérer les erreurs de requête', async () => {
      // Arrange
      const uidJoueur = 'reporter_123';
      const error = new Error('Erreur de requête Firebase');
      mockCollection.get.mockRejectedValue(error);

      // Act & Assert
      await expect(signalementRepository.getSignalementsByReporter(uidJoueur))
        .rejects.toThrow('Erreur de requête Firebase');
    });
  });

  describe('Initialisation', () => {
    it('devrait avoir accès à la base de données et la collection', () => {
      // Assert - Vérifier que l'instance a bien ses propriétés
      expect(signalementRepository).toBeDefined();
      expect(signalementRepository.db).toBe(mockDb);
      expect(signalementRepository.collection).toBe(mockCollection);
    });
  });
});

// Tests d'intégration simplifiés
describe('SignalementRepository - Workflow complet', () => {
  let signalementRepository;

  beforeAll(() => {
    // Import du repository
    signalementRepository = require('../../repositories/signalementRepository');
  });

  beforeEach(() => {
    // Reset et configuration des mocks
    jest.clearAllMocks();
    
    mockCollection.where.mockReturnThis();
    mockCollection.orderBy.mockReturnThis();
    mockCollection.doc.mockReturnValue(mockDoc);
  });

  it('devrait créer puis récupérer un signalement', async () => {
    // Arrange
    const signalementData = {
      uidJoueur: 'user1',
      uidJoueurQuiAEteSignale: 'user2',
      raison: 'Harcèlement'
    };

    // Mock création
    mockCollection.add.mockResolvedValue({ id: 'new_signalement' });

    // Mock récupération
    const mockDocData = { 
      id: 'new_signalement', 
      data: () => ({ ...signalementData, date: new Date() }) 
    };
    mockCollection.get.mockResolvedValue({ docs: [mockDocData] });

    // Act 1: Créer
    const created = await signalementRepository.createSignalement(signalementData);

    // Act 2: Récupérer
    const signalements = await signalementRepository.getSignalementsByUser('user2');

    // Assert
    expect(created.id).toBe('new_signalement');
    expect(signalements).toHaveLength(1);
    expect(signalements[0].uidJoueurQuiAEteSignale).toBe('user2');
  });

  it('devrait créer puis supprimer un signalement', async () => {
    // Arrange
    const signalementData = { uidJoueur: 'user1', raison: 'Test' };
    
    // Mock création
    mockCollection.add.mockResolvedValue({ id: 'to_delete' });
    
    // Mock suppression
    mockDoc.delete.mockResolvedValue();

    // Act
    const created = await signalementRepository.createSignalement(signalementData);
    await signalementRepository.deleteSignalement(created.id);

    // Assert
    expect(mockCollection.add).toHaveBeenCalled();
    expect(mockCollection.doc).toHaveBeenCalledWith('to_delete');
    expect(mockDoc.delete).toHaveBeenCalled();
  });

  it('devrait gérer plusieurs signalements pour le même utilisateur', async () => {
    // Arrange
    const signalement1 = { uidJoueur: 'reporter1', uidJoueurQuiAEteSignale: 'reported1', raison: 'Spam' };
    const signalement2 = { uidJoueur: 'reporter2', uidJoueurQuiAEteSignale: 'reported1', raison: 'Harcèlement' };

    mockCollection.add.mockResolvedValue({ id: 'sig_id' });

    // Mock récupération multiple
    const mockDocs = [
      { id: 'sig1', data: () => signalement1 },
      { id: 'sig2', data: () => signalement2 }
    ];
    mockCollection.get.mockResolvedValue({ docs: mockDocs });

    // Act
    await signalementRepository.createSignalement(signalement1);
    await signalementRepository.createSignalement(signalement2);
    const signalements = await signalementRepository.getSignalementsByUser('reported1');

    // Assert
    expect(signalements).toHaveLength(2);
    expect(signalements.every(s => s.uidJoueurQuiAEteSignale === 'reported1')).toBe(true);
  });
});