const mockPath = {
  join: jest.fn()
};

const mockFs = {
  existsSync: jest.fn(),
  readFileSync: jest.fn(),
  readdirSync: jest.fn()
};

// Mock des modules Node.js
jest.mock('path', () => mockPath);
jest.mock('fs', () => mockFs);

// Mock console.error pour éviter les logs pendant les tests
const originalConsoleError = console.error;
beforeAll(() => {
  console.error = jest.fn();
});

afterAll(() => {
  console.error = originalConsoleError;
});

describe('QuizRepository', () => {
  let quizRepository;

  beforeAll(() => {
    // Configuration des mocks path
    mockPath.join.mockImplementation((...args) => args.join('/'));
    
    // Import du repository APRÈS que tous les mocks soient configurés
    quizRepository = require('../../repositories/quizRepository');
  });

  beforeEach(() => {
    // Reset seulement les appels, pas les implémentations
    jest.clearAllMocks();
    
    // Réinitialiser console.error mock
    console.error.mockClear();
    
    // S'assurer que path.join fonctionne
    mockPath.join.mockImplementation((...args) => args.join('/'));
  });

  describe('getQuizQuestions', () => {
    it('devrait récupérer les questions d\'un quiz existant', async () => {
      // Arrange
      const themeQuizz = 'onepiece';
      const quizName = 'equipage-chapeau-paille';
      const expectedPath = `${quizRepository.quizDataPath}/${themeQuizz}/${quizName}.json`;
      const questionsData = [
        { question: 'Qui est le capitaine?', reponses: ['Luffy', 'Zoro', 'Nami', 'Usopp'], bonneReponse: 0 },
        { question: 'Quel est le rêve de Luffy?', reponses: ['Roi des Pirates', 'Meilleur épéiste', 'Cartographe', 'Sniper'], bonneReponse: 0 }
      ];
      
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readFileSync.mockReturnValue(JSON.stringify(questionsData));

      // Act
      const result = await quizRepository.getQuizQuestions(themeQuizz, quizName);

      // Assert
      expect(mockPath.join).toHaveBeenCalledWith(
        quizRepository.quizDataPath, 
        themeQuizz, 
        `${quizName}.json`
      );
      expect(mockFs.existsSync).toHaveBeenCalledWith(expectedPath);
      expect(mockFs.readFileSync).toHaveBeenCalledWith(expectedPath, 'utf-8');
      expect(result).toEqual(questionsData);
    });

    it('devrait retourner un tableau vide si le fichier n\'existe pas', async () => {
      // Arrange
      const themeQuizz = 'onepiece';
      const quizName = 'quiz-inexistant';
      const expectedPath = `${quizRepository.quizDataPath}/${themeQuizz}/${quizName}.json`;
      
      mockFs.existsSync.mockReturnValue(false);

      // Act
      const result = await quizRepository.getQuizQuestions(themeQuizz, quizName);

      // Assert
      expect(mockFs.existsSync).toHaveBeenCalledWith(expectedPath);
      expect(mockFs.readFileSync).not.toHaveBeenCalled();
      expect(result).toEqual([]);
      expect(console.error).toHaveBeenCalled();
    });

    it('devrait retourner un tableau vide si le JSON est invalide', async () => {
      // Arrange
      const themeQuizz = 'onepiece';
      const quizName = 'quiz-corrompu';
      
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readFileSync.mockReturnValue('{ invalid json }');

      // Act
      const result = await quizRepository.getQuizQuestions(themeQuizz, quizName);

      // Assert
      expect(result).toEqual([]);
      expect(console.error).toHaveBeenCalled();
    });

    it('devrait retourner un tableau vide si la lecture du fichier échoue', async () => {
      // Arrange
      const themeQuizz = 'onepiece';
      const quizName = 'quiz-inaccessible';
      
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readFileSync.mockImplementation(() => {
        throw new Error('Permission denied');
      });

      // Act
      const result = await quizRepository.getQuizQuestions(themeQuizz, quizName);

      // Assert
      expect(result).toEqual([]);
      expect(console.error).toHaveBeenCalledWith(
        expect.stringContaining('Erreur lors du chargement des questions pour quiz-inaccessible'),
        expect.any(Error)
      );
    });

    it('devrait gérer les chemins avec des caractères spéciaux', async () => {
      // Arrange
      const themeQuizz = 'one-piece';
      const quizName = 'équipage-chapeau-paille';
      const questionsData = [{ question: 'Test', reponses: ['A', 'B'], bonneReponse: 0 }];
      
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readFileSync.mockReturnValue(JSON.stringify(questionsData));

      // Act
      const result = await quizRepository.getQuizQuestions(themeQuizz, quizName);

      // Assert
      expect(result).toEqual(questionsData);
    });
  });

  describe('getShuffledQuestions', () => {
    beforeEach(() => {
      // Mock Math.random pour avoir des résultats prévisibles
      jest.spyOn(Math, 'random').mockReturnValue(0.5);
    });

    afterEach(() => {
      Math.random.mockRestore();
    });

    it('devrait retourner des questions mélangées avec limite par défaut', async () => {
      // Arrange
      const themeQuizz = 'onepiece';
      const quizName = 'test-quiz';
      const questionsData = [
        { question: 'Q1', reponses: ['A', 'B'], bonneReponse: 0 },
        { question: 'Q2', reponses: ['C', 'D'], bonneReponse: 1 },
        { question: 'Q3', reponses: ['E', 'F'], bonneReponse: 0 },
        { question: 'Q4', reponses: ['G', 'H'], bonneReponse: 1 },
        { question: 'Q5', reponses: ['I', 'J'], bonneReponse: 0 }
      ];
      
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readFileSync.mockReturnValue(JSON.stringify(questionsData));

      // Act
      const result = await quizRepository.getShuffledQuestions(themeQuizz, quizName);

      // Assert
      expect(result).toHaveLength(4); // Limite par défaut
      expect(result).toEqual(expect.arrayContaining([
        expect.objectContaining({ question: expect.any(String) })
      ]));
    });

    it('devrait respecter la limite spécifiée', async () => {
      // Arrange
      const themeQuizz = 'onepiece';
      const quizName = 'test-quiz';
      const limit = 2;
      const questionsData = [
        { question: 'Q1', reponses: ['A', 'B'], bonneReponse: 0 },
        { question: 'Q2', reponses: ['C', 'D'], bonneReponse: 1 },
        { question: 'Q3', reponses: ['E', 'F'], bonneReponse: 0 }
      ];
      
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readFileSync.mockReturnValue(JSON.stringify(questionsData));

      // Act
      const result = await quizRepository.getShuffledQuestions(themeQuizz, quizName, limit);

      // Assert
      expect(result).toHaveLength(limit);
    });

    it('devrait retourner toutes les questions si moins que la limite', async () => {
      // Arrange
      const themeQuizz = 'onepiece';
      const quizName = 'petit-quiz';
      const limit = 10;
      const questionsData = [
        { question: 'Q1', reponses: ['A', 'B'], bonneReponse: 0 },
        { question: 'Q2', reponses: ['C', 'D'], bonneReponse: 1 }
      ];
      
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readFileSync.mockReturnValue(JSON.stringify(questionsData));

      // Act
      const result = await quizRepository.getShuffledQuestions(themeQuizz, quizName, limit);

      // Assert
      expect(result).toHaveLength(2); // Seulement les questions disponibles
    });

    it('devrait retourner un tableau vide si aucune question disponible', async () => {
      // Arrange
      const themeQuizz = 'onepiece';
      const quizName = 'quiz-vide';
      
      mockFs.existsSync.mockReturnValue(false);

      // Act
      const result = await quizRepository.getShuffledQuestions(themeQuizz, quizName);

      // Assert
      expect(result).toEqual([]);
    });
  });

  describe('getAllQuizzesByTheme', () => {
    it('devrait récupérer tous les quiz d\'un thème existant', async () => {
      // Arrange
      const theme = 'onepiece';
      const files = [
        'equipage-chapeau-paille.json',
        'fruits-du-demon.json',
        'marine.json',
        'readme.txt' // Fichier non-JSON à ignorer
      ];
      const expectedQuizzes = [
        'equipage-chapeau-paille',
        'fruits-du-demon',
        'marine'
      ];
      
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readdirSync.mockReturnValue(files);

      // Act
      const result = await quizRepository.getAllQuizzesByTheme(theme);

      // Assert
      expect(mockPath.join).toHaveBeenCalledWith(quizRepository.quizDataPath, theme);
      expect(mockFs.readdirSync).toHaveBeenCalled();
      expect(result).toEqual(expectedQuizzes);
    });

    it('devrait retourner un tableau vide si le thème n\'existe pas', async () => {
      // Arrange
      const theme = 'theme-inexistant';
      
      mockFs.existsSync.mockReturnValue(false);

      // Act
      const result = await quizRepository.getAllQuizzesByTheme(theme);

      // Assert
      expect(mockFs.existsSync).toHaveBeenCalled();
      expect(mockFs.readdirSync).not.toHaveBeenCalled();
      expect(result).toEqual([]);
    });

    it('devrait retourner un tableau vide si erreur de lecture', async () => {
      // Arrange
      const theme = 'onepiece';
      
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readdirSync.mockImplementation(() => {
        throw new Error('Permission denied');
      });

      // Act
      const result = await quizRepository.getAllQuizzesByTheme(theme);

      // Assert
      expect(result).toEqual([]);
      expect(console.error).toHaveBeenCalledWith(
        expect.stringContaining('Erreur lors de la récupération des quiz pour le thème onepiece'),
        expect.any(Error)
      );
    });

    it('devrait filtrer seulement les fichiers .json', async () => {
      // Arrange
      const theme = 'onepiece';
      const files = [
        'quiz1.json',
        'quiz2.JSON', // Extension en majuscules - ne devrait pas être inclus
        'quiz3.txt',
        'quiz4.json',
        '.hidden.json',
        'quiz5'
      ];
      
      mockFs.existsSync.mockReturnValue(true);
      mockFs.readdirSync.mockReturnValue(files);

      // Act
      const result = await quizRepository.getAllQuizzesByTheme(theme);

      // Assert
      expect(result).toEqual(['quiz1', 'quiz4', '.hidden']);
    });
  });

  describe('getAllThemes', () => {
    it('devrait récupérer tous les thèmes (dossiers)', async () => {
      // Arrange
      const dirents = [
        { name: 'onepiece', isDirectory: () => true },
        { name: 'naruto', isDirectory: () => true },
        { name: 'dbz', isDirectory: () => true },
        { name: 'config.json', isDirectory: () => false } // Fichier à ignorer
      ];
      const expectedThemes = ['onepiece', 'naruto', 'dbz'];
      
      mockFs.readdirSync.mockReturnValue(dirents);

      // Act
      const result = await quizRepository.getAllThemes();

      // Assert
      expect(mockFs.readdirSync).toHaveBeenCalledWith(
        quizRepository.quizDataPath, 
        { withFileTypes: true }
      );
      expect(result).toEqual(expectedThemes);
    });

    it('devrait retourner un tableau vide si aucun dossier', async () => {
      // Arrange
      const dirents = [
        { name: 'file1.txt', isDirectory: () => false },
        { name: 'file2.json', isDirectory: () => false }
      ];
      
      mockFs.readdirSync.mockReturnValue(dirents);

      // Act
      const result = await quizRepository.getAllThemes();

      // Assert
      expect(result).toEqual([]);
    });

    it('devrait retourner un tableau vide si erreur de lecture', async () => {
      // Arrange
      mockFs.readdirSync.mockImplementation(() => {
        throw new Error('Directory not accessible');
      });

      // Act
      const result = await quizRepository.getAllThemes();

      // Assert
      expect(result).toEqual([]);
      expect(console.error).toHaveBeenCalledWith(
        'Erreur lors de la récupération des thèmes:',
        expect.any(Error)
      );
    });
  });

  describe('validateQuizExists', () => {
    it('devrait retourner true si le quiz existe', async () => {
      // Arrange
      const themeQuizz = 'onepiece';
      const quizName = 'equipage-chapeau-paille';
      const expectedPath = `${quizRepository.quizDataPath}/${themeQuizz}/${quizName}.json`;
      
      mockFs.existsSync.mockReturnValue(true);

      // Act
      const result = await quizRepository.validateQuizExists(themeQuizz, quizName);

      // Assert
      expect(mockPath.join).toHaveBeenCalledWith(
        quizRepository.quizDataPath, 
        themeQuizz, 
        `${quizName}.json`
      );
      expect(mockFs.existsSync).toHaveBeenCalledWith(expectedPath);
      expect(result).toBe(true);
    });

    it('devrait retourner false si le quiz n\'existe pas', async () => {
      // Arrange
      const themeQuizz = 'onepiece';
      const quizName = 'quiz-inexistant';
      
      mockFs.existsSync.mockReturnValue(false);

      // Act
      const result = await quizRepository.validateQuizExists(themeQuizz, quizName);

      // Assert
      expect(result).toBe(false);
    });

    it('devrait construire le bon chemin avec caractères spéciaux', async () => {
      // Arrange
      const themeQuizz = 'one-piece';
      const quizName = 'équipage-spécial';
      
      mockFs.existsSync.mockReturnValue(true);

      // Act
      const result = await quizRepository.validateQuizExists(themeQuizz, quizName);

      // Assert
      expect(mockPath.join).toHaveBeenCalledWith(
        quizRepository.quizDataPath, 
        themeQuizz, 
        `${quizName}.json`
      );
      expect(result).toBe(true);
    });
  });

  describe('Initialisation', () => {
    it('devrait initialiser le chemin des données quiz correctement', () => {
      // Assert
      expect(quizRepository).toBeDefined();
      expect(quizRepository.quizDataPath).toBeDefined();
      expect(quizRepository.quizDataPath).toContain('data/quizzes');
    });
  });
});

// Tests d'intégration
describe('QuizRepository - Workflow complet', () => {
  let quizRepository;

  beforeAll(() => {
    quizRepository = require('../../repositories/quizRepository');
  });

  beforeEach(() => {
    jest.clearAllMocks();
    console.error.mockClear();
    mockPath.join.mockImplementation((...args) => args.join('/'));
  });

  it('devrait effectuer un workflow complet de recherche de quiz', async () => {
    // Arrange - Setup pour getAllThemes
    const themes = [
      { name: 'onepiece', isDirectory: () => true },
      { name: 'naruto', isDirectory: () => true }
    ];
    mockFs.readdirSync.mockReturnValueOnce(themes);

    // Setup pour getAllQuizzesByTheme
    mockFs.existsSync.mockReturnValue(true);
    mockFs.readdirSync.mockReturnValueOnce(['quiz1.json', 'quiz2.json']);

    // Setup pour validateQuizExists
    mockFs.existsSync.mockReturnValue(true);

    // Setup pour getQuizQuestions
    const questionsData = [
      { question: 'Test?', reponses: ['A', 'B'], bonneReponse: 0 }
    ];
    mockFs.readFileSync.mockReturnValue(JSON.stringify(questionsData));

    // Act
    const allThemes = await quizRepository.getAllThemes();
    const quizzesInTheme = await quizRepository.getAllQuizzesByTheme('onepiece');
    const quizExists = await quizRepository.validateQuizExists('onepiece', 'quiz1');
    const questions = await quizRepository.getQuizQuestions('onepiece', 'quiz1');

    // Assert
    expect(allThemes).toEqual(['onepiece', 'naruto']);
    expect(quizzesInTheme).toEqual(['quiz1', 'quiz2']);
    expect(quizExists).toBe(true);
    expect(questions).toEqual(questionsData);
  });

  it('devrait gérer une recherche sur un thème inexistant', async () => {
    // Arrange
    mockFs.existsSync.mockReturnValue(false);

    // Act
    const quizzes = await quizRepository.getAllQuizzesByTheme('theme-inexistant');
    const quizExists = await quizRepository.validateQuizExists('theme-inexistant', 'quiz');
    const questions = await quizRepository.getQuizQuestions('theme-inexistant', 'quiz');

    // Assert
    expect(quizzes).toEqual([]);
    expect(quizExists).toBe(false);
    expect(questions).toEqual([]);
  });

  it('devrait mélanger les questions correctement', async () => {
    // Arrange
    const questionsData = [
      { question: 'Q1', id: 1 },
      { question: 'Q2', id: 2 },
      { question: 'Q3', id: 3 },
      { question: 'Q4', id: 4 },
      { question: 'Q5', id: 5 }
    ];
    
    mockFs.existsSync.mockReturnValue(true);
    mockFs.readFileSync.mockReturnValue(JSON.stringify(questionsData));

    // Mock Math.random pour un mélange spécifique
    const randomValues = [0.1, 0.9, 0.3, 0.7, 0.5];
    let callCount = 0;
    jest.spyOn(Math, 'random').mockImplementation(() => {
      return randomValues[callCount++ % randomValues.length];
    });

    // Act
    const shuffledQuestions = await quizRepository.getShuffledQuestions('onepiece', 'test', 3);

    // Assert
    expect(shuffledQuestions).toHaveLength(3);
    expect(shuffledQuestions).toEqual(expect.arrayContaining([
      expect.objectContaining({ question: expect.any(String) })
    ]));

    // Cleanup
    Math.random.mockRestore();
  });
});