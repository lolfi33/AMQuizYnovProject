
describe('QuizRoutes - Tests simples', () => {
  
  beforeEach(() => {
    // Nettoyer le cache pour chaque test
    jest.resetModules();
  });

  it('devrait importer le module sans erreur', () => {
    // Mock minimal juste pour l'import
    jest.doMock('express', () => ({
      Router: jest.fn(() => ({
        use: jest.fn(),
        get: jest.fn(),
        post: jest.fn()
      }))
    }));

    jest.doMock('../../controllers/quizController', () => ({
      getAllThemes: jest.fn(),
      getAllQuizzesByTheme: jest.fn(),
      getQuizQuestions: jest.fn(),
      getRandomQuestions: jest.fn(),
      validateQuizAccess: jest.fn(),
      processAnswer: jest.fn(),
      calculateScore: jest.fn()
    }));

    jest.doMock('../../middlewares/validationMiddleware', () => ({
      sanitizeInputs: jest.fn(),
      validateRequiredFields: jest.fn(() => jest.fn())
    }));

    expect(() => {
      require('../../routes/quizRoutes');
    }).not.toThrow();
  });

  it('devrait exporter un router Express', () => {
    const mockRouter = {
      use: jest.fn(),
      get: jest.fn(), 
      post: jest.fn()
    };

    jest.doMock('express', () => ({
      Router: jest.fn(() => mockRouter)
    }));

    jest.doMock('../../controllers/quizController', () => ({}));
    jest.doMock('../../middlewares/validationMiddleware', () => ({
      sanitizeInputs: jest.fn(),
      validateRequiredFields: jest.fn(() => jest.fn())
    }));

    const router = require('../../routes/quizRoutes');
    
    expect(router).toBeDefined();
    expect(typeof router).toBe('object');
  });

  it('devrait utiliser les bonnes dépendances', () => {
    // Test que les modules sont bien requis
    const mockRouter = { use: jest.fn(), get: jest.fn(), post: jest.fn() };
    
    jest.doMock('express', () => ({
      Router: jest.fn(() => mockRouter)
    }));

    const mockQuizController = {
      getAllThemes: jest.fn(),
      getAllQuizzesByTheme: jest.fn(),
      getQuizQuestions: jest.fn(),
      getRandomQuestions: jest.fn(),
      validateQuizAccess: jest.fn(),
      processAnswer: jest.fn(),
      calculateScore: jest.fn()
    };

    const mockValidationMiddleware = {
      sanitizeInputs: jest.fn(),
      validateRequiredFields: jest.fn(() => jest.fn())
    };

    jest.doMock('../../controllers/quizController', () => mockQuizController);
    jest.doMock('../../middlewares/validationMiddleware', () => mockValidationMiddleware);

    // Import du module
    require('../../routes/quizRoutes');

    // Vérifier que Express Router a été appelé
    const express = require('express');
    expect(express.Router).toHaveBeenCalled();
  });

  describe('Structure des routes', () => {
    it('devrait définir les routes attendues', () => {
      const mockRouter = {
        use: jest.fn(),
        get: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      jest.doMock('../../controllers/quizController', () => ({
        getAllThemes: 'getAllThemes',
        getAllQuizzesByTheme: 'getAllQuizzesByTheme',
        getQuizQuestions: 'getQuizQuestions',
        getRandomQuestions: 'getRandomQuestions',
        validateQuizAccess: 'validateQuizAccess',
        processAnswer: 'processAnswer',
        calculateScore: 'calculateScore'
      }));

      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: 'sanitizeInputs',
        validateRequiredFields: jest.fn((fields) => `validate-${fields.join('-')}`)
      }));

      // Import et exécution
      require('../../routes/quizRoutes');

      // Vérifier que les routes ont été configurées
      expect(mockRouter.use).toHaveBeenCalled();
      expect(mockRouter.get).toHaveBeenCalled();
      expect(mockRouter.post).toHaveBeenCalled();
    });
  });

  describe('Validation des middlewares', () => {
    it('devrait utiliser le middleware de sanitisation', () => {
      const mockRouter = {
        use: jest.fn(),
        get: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const sanitizeInputs = jest.fn();
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs,
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      jest.doMock('../../controllers/quizController', () => ({}));

      require('../../routes/quizRoutes');

      // Vérifier que router.use a été appelé
      expect(mockRouter.use).toHaveBeenCalledWith(sanitizeInputs);
    });

    it('devrait utiliser la validation des champs requis', () => {
      const mockRouter = {
        use: jest.fn(),
        get: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const validateRequiredFields = jest.fn(() => 'middleware');
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields
      }));

      jest.doMock('../../controllers/quizController', () => ({
        processAnswer: 'processAnswer',
        calculateScore: 'calculateScore'
      }));

      require('../../routes/quizRoutes');

      // Vérifier que validateRequiredFields a été appelé
      expect(validateRequiredFields).toHaveBeenCalledWith(['question', 'userAnswer']);
      expect(validateRequiredFields).toHaveBeenCalledWith(['answers']);
    });
  });

  describe('Configuration des contrôleurs', () => {
    it('devrait lier les contrôleurs aux routes', () => {
      const mockRouter = {
        use: jest.fn(),
        get: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const quizController = {
        getAllThemes: 'getAllThemes-controller',
        getAllQuizzesByTheme: 'getAllQuizzesByTheme-controller',
        getQuizQuestions: 'getQuizQuestions-controller',
        getRandomQuestions: 'getRandomQuestions-controller',
        validateQuizAccess: 'validateQuizAccess-controller',
        processAnswer: 'processAnswer-controller',
        calculateScore: 'calculateScore-controller'
      };

      jest.doMock('../../controllers/quizController', () => quizController);

      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => 'validation-middleware')
      }));

      require('../../routes/quizRoutes');

      // Vérifier que les contrôleurs sont utilisés
      expect(mockRouter.get).toHaveBeenCalledWith('/themes', quizController.getAllThemes);
      expect(mockRouter.get).toHaveBeenCalledWith('/themes/:theme', quizController.getAllQuizzesByTheme);
      expect(mockRouter.post).toHaveBeenCalledWith(
        '/process-answer',
        'validation-middleware',
        quizController.processAnswer
      );
      expect(mockRouter.post).toHaveBeenCalledWith(
        '/calculate-score',
        'validation-middleware',
        quizController.calculateScore
      );
    });
  });

  describe('Tests d\'intégration basiques', () => {
    it('devrait exporter le module correctement', () => {
      jest.doMock('express', () => ({
        Router: jest.fn(() => ({ 
          use: jest.fn(), 
          get: jest.fn(), 
          post: jest.fn() 
        }))
      }));

      jest.doMock('../../controllers/quizController', () => ({}));
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      const quizRoutes = require('../../routes/quizRoutes');

      expect(quizRoutes).toBeDefined();
      expect(typeof quizRoutes).toBe('object');
    });

    it('devrait être utilisable comme middleware Express', () => {
      const mockRouter = {
        use: jest.fn(),
        get: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      jest.doMock('../../controllers/quizController', () => ({}));
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      const quizRoutes = require('../../routes/quizRoutes');

      // Simuler l'utilisation dans une app Express
      const mockApp = {
        use: jest.fn()
      };

      expect(() => {
        mockApp.use('/api/quiz', quizRoutes);
      }).not.toThrow();

      expect(mockApp.use).toHaveBeenCalledWith('/api/quiz', quizRoutes);
    });
  });

  describe('Couverture des routes', () => {
    it('devrait couvrir toutes les routes GET attendues', () => {
      const mockRouter = {
        use: jest.fn(),
        get: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      jest.doMock('../../controllers/quizController', () => ({
        getAllThemes: jest.fn(),
        getAllQuizzesByTheme: jest.fn(),
        getQuizQuestions: jest.fn(),
        getRandomQuestions: jest.fn(),
        validateQuizAccess: jest.fn()
      }));

      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      require('../../routes/quizRoutes');

      // Vérifier que toutes les routes GET sont définies
      const getRoutes = mockRouter.get.mock.calls.map(call => call[0]);
      
      expect(getRoutes).toContain('/themes');
      expect(getRoutes).toContain('/themes/:theme');
      expect(getRoutes).toContain('/:category/:fileName');
      expect(getRoutes).toContain('/:category/:fileName/random');
      expect(getRoutes).toContain('/:category/:fileName/validate');
    });

    it('devrait couvrir toutes les routes POST attendues', () => {
      const mockRouter = {
        use: jest.fn(),
        get: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      jest.doMock('../../controllers/quizController', () => ({
        processAnswer: jest.fn(),
        calculateScore: jest.fn()
      }));

      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      require('../../routes/quizRoutes');

      // Vérifier que toutes les routes POST sont définies
      const postRoutes = mockRouter.post.mock.calls.map(call => call[0]);
      
      expect(postRoutes).toContain('/process-answer');
      expect(postRoutes).toContain('/calculate-score');
    });
  });
});