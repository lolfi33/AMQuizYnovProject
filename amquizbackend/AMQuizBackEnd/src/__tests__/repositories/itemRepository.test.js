const mockCollection = {
  doc: jest.fn(),
  where: jest.fn().mockReturnThis(),
  get: jest.fn()
};

const mockDoc = {
  get: jest.fn()
};

const mockDb = {
  collection: jest.fn().mockReturnValue(mockCollection)
};

// Mock Firebase avec des valeurs persistantes
jest.mock('../../config/firebase', () => ({
  getDb: jest.fn(() => mockDb)
}));

jest.mock('../../utils/constants', () => ({
  COLLECTION_NAMES: {
    ITEMS: 'items'
  }
}));

const firebaseConfig = require('../../config/firebase');

// Force la configuration des mocks avant tout import du repository
firebaseConfig.getDb.mockReturnValue(mockDb);
mockDb.collection.mockReturnValue(mockCollection);
mockCollection.doc.mockReturnValue(mockDoc);

describe('ItemRepository', () => {
  let itemRepository;

  beforeAll(() => {
    // Import du repository APRÈS que tous les mocks soient configurés
    itemRepository = require('../../repositories/itemRepository');
  });

  beforeEach(() => {
    // Reset seulement les appels, pas les implémentations
    jest.clearAllMocks();
    
    // S'assurer que les mocks sont toujours en place
    mockCollection.doc.mockReturnValue(mockDoc);
    mockCollection.where.mockReturnThis();
  });

  describe('getItemById', () => {
    it('devrait récupérer un item existant par son ID', async () => {
      // Arrange
      const itemId = 'item_123';
      const itemData = {
        id: itemId,
        name: 'Épée Légendaire',
        rarity: 'legendary',
        type: 'weapon',
        oeuvre: 'onepiece'
      };
      const mockDocData = {
        exists: true,
        data: () => itemData
      };
      mockDoc.get.mockResolvedValue(mockDocData);

      // Act
      const result = await itemRepository.getItemById(itemId);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(itemId);
      expect(mockDoc.get).toHaveBeenCalled();
      expect(result).toEqual(itemData);
    });

    it('devrait retourner null pour un item inexistant', async () => {
      // Arrange
      const itemId = 'item_inexistant';
      const mockDocData = {
        exists: false
      };
      mockDoc.get.mockResolvedValue(mockDocData);

      // Act
      const result = await itemRepository.getItemById(itemId);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith(itemId);
      expect(mockDoc.get).toHaveBeenCalled();
      expect(result).toBeNull();
    });

    it('devrait propager les erreurs Firestore', async () => {
      // Arrange
      const itemId = 'item_123';
      const error = new Error('Firestore error');
      mockDoc.get.mockRejectedValue(error);

      // Act & Assert
      await expect(itemRepository.getItemById(itemId))
        .rejects.toThrow('Firestore error');
    });

    it('devrait gérer les IDs vides ou nulls', async () => {
      // Arrange
      const itemId = '';
      const mockDocData = { exists: false };
      mockDoc.get.mockResolvedValue(mockDocData);

      // Act
      const result = await itemRepository.getItemById(itemId);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledWith('');
      expect(result).toBeNull();
    });
  });

  describe('getItemsByFilter', () => {
    it('devrait récupérer des items avec un filtre simple', async () => {
      // Arrange
      const filters = { rarity: 'legendary' };
      const itemsData = [
        { id: 'item1', name: 'Épée', rarity: 'legendary' },
        { id: 'item2', name: 'Bouclier', rarity: 'legendary' }
      ];
      const mockDocs = itemsData.map(item => ({ data: () => item }));
      const mockSnapshot = { docs: mockDocs };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getItemsByFilter(filters);

      // Assert
      expect(mockCollection.where).toHaveBeenCalledWith('rarity', '==', 'legendary');
      expect(mockCollection.get).toHaveBeenCalled();
      expect(result).toEqual(itemsData);
    });

    it('devrait récupérer des items avec plusieurs filtres', async () => {
      // Arrange
      const filters = { 
        rarity: 'legendary', 
        type: 'weapon',
        oeuvre: 'onepiece'
      };
      const itemsData = [
        { id: 'item1', name: 'Épée Légendaire', rarity: 'legendary', type: 'weapon', oeuvre: 'onepiece' }
      ];
      const mockDocs = itemsData.map(item => ({ data: () => item }));
      const mockSnapshot = { docs: mockDocs };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getItemsByFilter(filters);

      // Assert
      expect(mockCollection.where).toHaveBeenCalledWith('rarity', '==', 'legendary');
      expect(mockCollection.where).toHaveBeenCalledWith('type', '==', 'weapon');
      expect(mockCollection.where).toHaveBeenCalledWith('oeuvre', '==', 'onepiece');
      expect(mockCollection.where).toHaveBeenCalledTimes(3);
      expect(result).toEqual(itemsData);
    });

    it('devrait retourner un tableau vide si aucun item trouvé', async () => {
      // Arrange
      const filters = { rarity: 'inexistant' };
      const mockSnapshot = { docs: [] };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getItemsByFilter(filters);

      // Assert
      expect(result).toEqual([]);
    });

    it('devrait gérer un objet filters vide', async () => {
      // Arrange
      const filters = {};
      const itemsData = [
        { id: 'item1', name: 'Item 1' },
        { id: 'item2', name: 'Item 2' }
      ];
      const mockDocs = itemsData.map(item => ({ data: () => item }));
      const mockSnapshot = { docs: mockDocs };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getItemsByFilter(filters);

      // Assert
      expect(mockCollection.where).not.toHaveBeenCalled();
      expect(mockCollection.get).toHaveBeenCalled();
      expect(result).toEqual(itemsData);
    });

    it('devrait propager les erreurs de requête', async () => {
      // Arrange
      const filters = { rarity: 'legendary' };
      const error = new Error('Query failed');
      mockCollection.get.mockRejectedValue(error);

      // Act & Assert
      await expect(itemRepository.getItemsByFilter(filters))
        .rejects.toThrow('Query failed');
    });
  });

  describe('getItemsByRarityAndType', () => {
    it('devrait récupérer des items par rareté et type', async () => {
      // Arrange
      const rarity = 'legendary';
      const type = 'weapon';
      const itemsData = [
        { id: 'item1', name: 'Épée Légendaire', rarity: 'legendary', type: 'weapon' },
        { id: 'item2', name: 'Hache Légendaire', rarity: 'legendary', type: 'weapon' }
      ];
      const mockDocs = itemsData.map(item => ({ data: () => item }));
      const mockSnapshot = { docs: mockDocs };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getItemsByRarityAndType(rarity, type);

      // Assert
      expect(mockCollection.where).toHaveBeenCalledWith('rarity', '==', rarity);
      expect(mockCollection.where).toHaveBeenCalledWith('type', '==', type);
      expect(mockCollection.get).toHaveBeenCalled();
      expect(result).toEqual(itemsData);
    });

    it('devrait retourner un tableau vide si aucun item correspondant', async () => {
      // Arrange
      const rarity = 'mythical';
      const type = 'shield';
      const mockSnapshot = { docs: [] };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getItemsByRarityAndType(rarity, type);

      // Assert
      expect(result).toEqual([]);
    });

    it('devrait gérer les valeurs null ou undefined', async () => {
      // Arrange
      const rarity = null;
      const type = undefined;
      const mockSnapshot = { docs: [] };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getItemsByRarityAndType(rarity, type);

      // Assert
      expect(mockCollection.where).toHaveBeenCalledWith('rarity', '==', null);
      expect(mockCollection.where).toHaveBeenCalledWith('type', '==', undefined);
      expect(result).toEqual([]);
    });
  });

  describe('getAllItems', () => {
    it('devrait récupérer tous les items', async () => {
      // Arrange
      const itemsData = [
        { id: 'item1', name: 'Item 1', rarity: 'common' },
        { id: 'item2', name: 'Item 2', rarity: 'rare' },
        { id: 'item3', name: 'Item 3', rarity: 'legendary' }
      ];
      const mockDocs = itemsData.map(item => ({ data: () => item }));
      const mockSnapshot = { docs: mockDocs };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getAllItems();

      // Assert
      expect(mockCollection.get).toHaveBeenCalled();
      expect(mockCollection.where).not.toHaveBeenCalled();
      expect(result).toEqual(itemsData);
    });

    it('devrait retourner un tableau vide si aucun item', async () => {
      // Arrange
      const mockSnapshot = { docs: [] };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getAllItems();

      // Assert
      expect(result).toEqual([]);
    });

    it('devrait propager les erreurs de récupération', async () => {
      // Arrange
      const error = new Error('Collection access denied');
      mockCollection.get.mockRejectedValue(error);

      // Act & Assert
      await expect(itemRepository.getAllItems())
        .rejects.toThrow('Collection access denied');
    });
  });

  describe('getItemsByOeuvreAndType', () => {
    it('devrait récupérer des items par œuvre et type', async () => {
      // Arrange
      const oeuvre = 'onepiece';
      const type = 'weapon';
      const itemsData = [
        { id: 'item1', name: 'Épée de Zoro', oeuvre: 'onepiece', type: 'weapon' },
        { id: 'item2', name: 'Bâton de Luffy', oeuvre: 'onepiece', type: 'weapon' }
      ];
      const mockDocs = itemsData.map(item => ({ data: () => item }));
      const mockSnapshot = { docs: mockDocs };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getItemsByOeuvreAndType(oeuvre, type);

      // Assert
      expect(mockCollection.where).toHaveBeenCalledWith('oeuvre', '==', oeuvre);
      expect(mockCollection.where).toHaveBeenCalledWith('type', '==', type);
      expect(mockCollection.get).toHaveBeenCalled();
      expect(result).toEqual(itemsData);
    });

    it('devrait retourner un tableau vide si aucun item correspondant', async () => {
      // Arrange
      const oeuvre = 'naruto';
      const type = 'armor';
      const mockSnapshot = { docs: [] };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getItemsByOeuvreAndType(oeuvre, type);

      // Assert
      expect(result).toEqual([]);
    });

    it('devrait gérer les paramètres avec caractères spéciaux', async () => {
      // Arrange
      const oeuvre = 'one-piece';
      const type = 'épée';
      const itemsData = [
        { id: 'item1', name: 'Épée spéciale', oeuvre: 'one-piece', type: 'épée' }
      ];
      const mockDocs = itemsData.map(item => ({ data: () => item }));
      const mockSnapshot = { docs: mockDocs };
      
      mockCollection.get.mockResolvedValue(mockSnapshot);

      // Act
      const result = await itemRepository.getItemsByOeuvreAndType(oeuvre, type);

      // Assert
      expect(mockCollection.where).toHaveBeenCalledWith('oeuvre', '==', 'one-piece');
      expect(mockCollection.where).toHaveBeenCalledWith('type', '==', 'épée');
      expect(result).toEqual(itemsData);
    });
  });

  describe('getMultipleItemsById', () => {
    it('devrait récupérer plusieurs items par leurs IDs', async () => {
      // Arrange
      const itemIds = ['item1', 'item2', 'item3'];
      const itemsData = [
        { id: 'item1', name: 'Item 1' },
        { id: 'item2', name: 'Item 2' },
        { id: 'item3', name: 'Item 3' }
      ];
      
      // Mock des appels successifs à getItemById
      mockDoc.get
        .mockResolvedValueOnce({ exists: true, data: () => itemsData[0] })
        .mockResolvedValueOnce({ exists: true, data: () => itemsData[1] })
        .mockResolvedValueOnce({ exists: true, data: () => itemsData[2] });

      // Act
      const result = await itemRepository.getMultipleItemsById(itemIds);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledTimes(3);
      expect(mockCollection.doc).toHaveBeenCalledWith('item1');
      expect(mockCollection.doc).toHaveBeenCalledWith('item2');
      expect(mockCollection.doc).toHaveBeenCalledWith('item3');
      expect(result).toEqual(itemsData);
    });

    it('devrait ignorer les items inexistants', async () => {
      // Arrange
      const itemIds = ['item1', 'item_inexistant', 'item3'];
      const existingItems = [
        { id: 'item1', name: 'Item 1' },
        { id: 'item3', name: 'Item 3' }
      ];
      
      // Mock des appels - le deuxième item n'existe pas
      mockDoc.get
        .mockResolvedValueOnce({ exists: true, data: () => existingItems[0] })
        .mockResolvedValueOnce({ exists: false })
        .mockResolvedValueOnce({ exists: true, data: () => existingItems[1] });

      // Act
      const result = await itemRepository.getMultipleItemsById(itemIds);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledTimes(3);
      expect(result).toEqual(existingItems);
    });

    it('devrait retourner un tableau vide si aucun ID fourni', async () => {
      // Arrange
      const itemIds = [];

      // Act
      const result = await itemRepository.getMultipleItemsById(itemIds);

      // Assert
      expect(mockCollection.doc).not.toHaveBeenCalled();
      expect(result).toEqual([]);
    });

    it('devrait retourner un tableau vide si tous les items sont inexistants', async () => {
      // Arrange
      const itemIds = ['inexistant1', 'inexistant2'];
      
      mockDoc.get
        .mockResolvedValueOnce({ exists: false })
        .mockResolvedValueOnce({ exists: false });

      // Act
      const result = await itemRepository.getMultipleItemsById(itemIds);

      // Assert
      expect(result).toEqual([]);
    });

    it('devrait propager les erreurs lors de la récupération', async () => {
      // Arrange
      const itemIds = ['item1', 'item2'];
      const error = new Error('Item retrieval failed');
      
      mockDoc.get
        .mockResolvedValueOnce({ exists: true, data: () => ({ id: 'item1' }) })
        .mockRejectedValueOnce(error);

      // Act & Assert
      await expect(itemRepository.getMultipleItemsById(itemIds))
        .rejects.toThrow('Item retrieval failed');
    });

    it('devrait gérer les IDs dupliqués', async () => {
      // Arrange
      const itemIds = ['item1', 'item1', 'item2'];
      const itemsData = [
        { id: 'item1', name: 'Item 1' },
        { id: 'item1', name: 'Item 1' }, // Dupliqué
        { id: 'item2', name: 'Item 2' }
      ];
      
      mockDoc.get
        .mockResolvedValue({ exists: true, data: () => ({ id: 'item1', name: 'Item 1' }) })
        .mockResolvedValueOnce({ exists: true, data: () => ({ id: 'item1', name: 'Item 1' }) })
        .mockResolvedValueOnce({ exists: true, data: () => ({ id: 'item2', name: 'Item 2' }) });

      // Act
      const result = await itemRepository.getMultipleItemsById(itemIds);

      // Assert
      expect(mockCollection.doc).toHaveBeenCalledTimes(3);
      expect(result).toHaveLength(3); // Doit inclure les doublons
    });
  });

  describe('Initialisation', () => {
    it('devrait avoir accès à la base de données et la collection items', () => {
      // Assert - Vérifier que l'instance a bien ses propriétés
      expect(itemRepository).toBeDefined();
      expect(itemRepository.db).toBe(mockDb);
      expect(itemRepository.collection).toBe(mockCollection);
    });
  });
});

// Tests d'intégration
describe('ItemRepository - Workflow complet', () => {
  let itemRepository;

  beforeAll(() => {
    // Import du repository
    itemRepository = require('../../repositories/itemRepository');
  });

  beforeEach(() => {
    // Reset et configuration des mocks
    jest.clearAllMocks();
    
    mockCollection.doc.mockReturnValue(mockDoc);
    mockCollection.where.mockReturnThis();
  });

  it('devrait effectuer une recherche complète d\'items', async () => {
    // Arrange
    const itemsData = [
      { id: 'item1', name: 'Épée Légendaire', rarity: 'legendary', type: 'weapon', oeuvre: 'onepiece' },
      { id: 'item2', name: 'Bouclier Légendaire', rarity: 'legendary', type: 'shield', oeuvre: 'onepiece' },
      { id: 'item3', name: 'Arc Rare', rarity: 'rare', type: 'weapon', oeuvre: 'onepiece' }
    ];
    const mockDocs = itemsData.map(item => ({ data: () => item }));
    const mockSnapshot = { docs: mockDocs };

    // Setup pour getAllItems
    mockCollection.get.mockResolvedValueOnce(mockSnapshot);

    // Setup pour getItemsByFilter (legendary items)
    const legendaryItems = itemsData.filter(item => item.rarity === 'legendary');
    const legendaryMockDocs = legendaryItems.map(item => ({ data: () => item }));
    mockCollection.get.mockResolvedValueOnce({ docs: legendaryMockDocs });

    // Setup pour getItemsByRarityAndType (legendary weapons)
    const legendaryWeapons = itemsData.filter(item => item.rarity === 'legendary' && item.type === 'weapon');
    const weaponMockDocs = legendaryWeapons.map(item => ({ data: () => item }));
    mockCollection.get.mockResolvedValueOnce({ docs: weaponMockDocs });

    // Act
    const allItems = await itemRepository.getAllItems();
    const legendaryItemsResult = await itemRepository.getItemsByFilter({ rarity: 'legendary' });
    const legendaryWeaponsResult = await itemRepository.getItemsByRarityAndType('legendary', 'weapon');

    // Assert
    expect(allItems).toHaveLength(3);
    expect(legendaryItemsResult).toHaveLength(2);
    expect(legendaryWeaponsResult).toHaveLength(1);
    expect(legendaryWeaponsResult[0].name).toBe('Épée Légendaire');
  });

  it('devrait gérer la récupération multiple avec filtres', async () => {
    // Arrange
    const itemIds = ['item1', 'item2'];
    const itemsData = [
      { id: 'item1', name: 'Item 1', oeuvre: 'onepiece', type: 'weapon' },
      { id: 'item2', name: 'Item 2', oeuvre: 'onepiece', type: 'weapon' }
    ];

    // Setup pour getMultipleItemsById
    mockDoc.get
      .mockResolvedValueOnce({ exists: true, data: () => itemsData[0] })
      .mockResolvedValueOnce({ exists: true, data: () => itemsData[1] });

    // Setup pour getItemsByOeuvreAndType
    const mockDocs = itemsData.map(item => ({ data: () => item }));
    mockCollection.get.mockResolvedValueOnce({ docs: mockDocs });

    // Act
    const multipleItems = await itemRepository.getMultipleItemsById(itemIds);
    const onepieceWeapons = await itemRepository.getItemsByOeuvreAndType('onepiece', 'weapon');

    // Assert
    expect(multipleItems).toHaveLength(2);
    expect(onepieceWeapons).toHaveLength(2);
    expect(multipleItems.every(item => item.oeuvre === 'onepiece')).toBe(true);
  });

  it('devrait gérer un workflow avec des résultats vides', async () => {
    // Arrange
    const emptySnapshot = { docs: [] };
    
    // Tous les appels retournent des résultats vides
    mockCollection.get.mockResolvedValue(emptySnapshot);
    mockDoc.get.mockResolvedValue({ exists: false });

    // Act
    const allItems = await itemRepository.getAllItems();
    const filteredItems = await itemRepository.getItemsByFilter({ rarity: 'inexistant' });
    const singleItem = await itemRepository.getItemById('inexistant');
    const multipleItems = await itemRepository.getMultipleItemsById(['inexistant1', 'inexistant2']);

    // Assert
    expect(allItems).toEqual([]);
    expect(filteredItems).toEqual([]);
    expect(singleItem).toBeNull();
    expect(multipleItems).toEqual([]);
  });
});