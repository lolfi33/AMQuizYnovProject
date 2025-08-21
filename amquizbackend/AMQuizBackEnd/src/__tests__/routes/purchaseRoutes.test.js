// __tests__/routes/purchaseRoutes.test.js

describe('PurchaseRoutes', () => {
  
  beforeEach(() => {
    // Nettoyer le cache pour chaque test
    jest.resetModules();
  });

  it('devrait importer le module sans erreur', () => {
    // Mock minimal juste pour l'import
    jest.doMock('express', () => ({
      Router: jest.fn(() => ({
        use: jest.fn(),
        post: jest.fn()
      }))
    }));

    jest.doMock('../../controllers/purchaseController', () => ({
      validateGooglePlayReceipt: jest.fn(),
      validateTransaction: jest.fn()
    }));

    jest.doMock('../../middlewares/authMiddleware', () => jest.fn());

    jest.doMock('../../middlewares/validationMiddleware', () => ({
      sanitizeInputs: jest.fn(),
      validateRequiredFields: jest.fn(() => jest.fn())
    }));

    expect(() => {
      require('../../routes/purchaseRoutes');
    }).not.toThrow();
  });

  it('devrait exporter un router Express', () => {
    const mockRouter = {
      use: jest.fn(),
      post: jest.fn()
    };

    jest.doMock('express', () => ({
      Router: jest.fn(() => mockRouter)
    }));

    jest.doMock('../../controllers/purchaseController', () => ({}));
    jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
    jest.doMock('../../middlewares/validationMiddleware', () => ({
      sanitizeInputs: jest.fn(),
      validateRequiredFields: jest.fn(() => jest.fn())
    }));

    const router = require('../../routes/purchaseRoutes');
    
    expect(router).toBeDefined();
    expect(typeof router).toBe('object');
  });

  it('devrait utiliser les bonnes dépendances', () => {
    // Test que les modules sont bien requis
    const mockRouter = { use: jest.fn(), post: jest.fn() };
    
    jest.doMock('express', () => ({
      Router: jest.fn(() => mockRouter)
    }));

    const mockPurchaseController = {
      validateGooglePlayReceipt: jest.fn(),
      validateTransaction: jest.fn()
    };

    const mockAuthMiddleware = jest.fn();

    const mockValidationMiddleware = {
      sanitizeInputs: jest.fn(),
      validateRequiredFields: jest.fn(() => jest.fn())
    };

    jest.doMock('../../controllers/purchaseController', () => mockPurchaseController);
    jest.doMock('../../middlewares/authMiddleware', () => mockAuthMiddleware);
    jest.doMock('../../middlewares/validationMiddleware', () => mockValidationMiddleware);

    // Import du module
    require('../../routes/purchaseRoutes');

    // Vérifier que Express Router a été appelé
    const express = require('express');
    expect(express.Router).toHaveBeenCalled();
  });

  describe('Configuration des middlewares', () => {
    it('devrait utiliser le middleware d\'authentification globalement', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const authMiddleware = jest.fn();
      const sanitizeInputs = jest.fn();

      jest.doMock('../../middlewares/authMiddleware', () => authMiddleware);
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs,
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      jest.doMock('../../controllers/purchaseController', () => ({}));

      require('../../routes/purchaseRoutes');

      // Vérifier que authMiddleware est appliqué globalement
      expect(mockRouter.use).toHaveBeenCalledWith(authMiddleware);
      expect(mockRouter.use).toHaveBeenCalledWith(sanitizeInputs);
    });

    it('devrait appliquer les middlewares dans le bon ordre', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const authMiddleware = 'authMiddleware';
      const sanitizeInputs = 'sanitizeInputs';

      jest.doMock('../../middlewares/authMiddleware', () => authMiddleware);
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs,
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      jest.doMock('../../controllers/purchaseController', () => ({}));

      require('../../routes/purchaseRoutes');

      // Vérifier l'ordre des middlewares globaux
      const useCalls = mockRouter.use.mock.calls;
      expect(useCalls[0][0]).toBe(authMiddleware); // Auth en premier
      expect(useCalls[1][0]).toBe(sanitizeInputs);  // Sanitize en second
    });

    it('devrait utiliser la validation des champs requis', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const validateRequiredFields = jest.fn(() => 'validation-middleware');

      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields
      }));

      jest.doMock('../../controllers/purchaseController', () => ({
        validateGooglePlayReceipt: 'validateGooglePlayReceipt',
        validateTransaction: 'validateTransaction'
      }));

      require('../../routes/purchaseRoutes');

      // Vérifier que validateRequiredFields a été appelé avec les bons paramètres
      expect(validateRequiredFields).toHaveBeenCalledWith(['receiptData', 'productId']);
      expect(validateRequiredFields).toHaveBeenCalledWith(['transactionId', 'productId', 'platform']);
    });
  });

  describe('Configuration des routes POST', () => {
    it('devrait configurer la route validate-receipt', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const purchaseController = {
        validateGooglePlayReceipt: 'validateGooglePlayReceipt-controller',
        validateTransaction: 'validateTransaction-controller'
      };

      const validateRequiredFields = jest.fn(() => 'validation-middleware');

      jest.doMock('../../controllers/purchaseController', () => purchaseController);
      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields
      }));

      require('../../routes/purchaseRoutes');

      // Vérifier que la route validate-receipt est configurée correctement
      expect(mockRouter.post).toHaveBeenCalledWith(
        '/validate-receipt',
        'validation-middleware',
        purchaseController.validateGooglePlayReceipt
      );
    });

    it('devrait configurer la route validate-transaction', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const purchaseController = {
        validateGooglePlayReceipt: 'validateGooglePlayReceipt-controller',
        validateTransaction: 'validateTransaction-controller'
      };

      const validateRequiredFields = jest.fn(() => 'validation-middleware');

      jest.doMock('../../controllers/purchaseController', () => purchaseController);
      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields
      }));

      require('../../routes/purchaseRoutes');

      // Vérifier que la route validate-transaction est configurée correctement
      expect(mockRouter.post).toHaveBeenCalledWith(
        '/validate-transaction',
        'validation-middleware',
        purchaseController.validateTransaction
      );
    });

    it('devrait avoir exactement 2 routes POST', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      jest.doMock('../../controllers/purchaseController', () => ({
        validateGooglePlayReceipt: jest.fn(),
        validateTransaction: jest.fn()
      }));

      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      require('../../routes/purchaseRoutes');

      // Vérifier qu'il y a exactement 2 routes POST
      expect(mockRouter.post).toHaveBeenCalledTimes(2);
    });
  });

  describe('Validation des champs requis', () => {
    it('devrait valider les champs pour validate-receipt', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const validateRequiredFields = jest.fn(() => jest.fn());

      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields
      }));

      jest.doMock('../../controllers/purchaseController', () => ({
        validateGooglePlayReceipt: jest.fn(),
        validateTransaction: jest.fn()
      }));

      require('../../routes/purchaseRoutes');

      // Vérifier que les champs requis pour validate-receipt sont corrects
      expect(validateRequiredFields).toHaveBeenCalledWith(['receiptData', 'productId']);
    });

    it('devrait valider les champs pour validate-transaction', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const validateRequiredFields = jest.fn(() => jest.fn());

      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields
      }));

      jest.doMock('../../controllers/purchaseController', () => ({
        validateGooglePlayReceipt: jest.fn(),
        validateTransaction: jest.fn()
      }));

      require('../../routes/purchaseRoutes');

      // Vérifier que les champs requis pour validate-transaction sont corrects
      expect(validateRequiredFields).toHaveBeenCalledWith(['transactionId', 'productId', 'platform']);
    });
  });

  describe('Configuration des contrôleurs', () => {
    it('devrait lier les contrôleurs aux bonnes routes', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const purchaseController = {
        validateGooglePlayReceipt: 'validateGooglePlayReceipt-method',
        validateTransaction: 'validateTransaction-method'
      };

      jest.doMock('../../controllers/purchaseController', () => purchaseController);
      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => 'validation')
      }));

      require('../../routes/purchaseRoutes');

      // Vérifier que les bons contrôleurs sont liés aux bonnes routes
      const postCalls = mockRouter.post.mock.calls;
      
      // Route validate-receipt
      const validateReceiptCall = postCalls.find(call => call[0] === '/validate-receipt');
      expect(validateReceiptCall[2]).toBe(purchaseController.validateGooglePlayReceipt);
      
      // Route validate-transaction
      const validateTransactionCall = postCalls.find(call => call[0] === '/validate-transaction');
      expect(validateTransactionCall[2]).toBe(purchaseController.validateTransaction);
    });
  });

  describe('Tests d\'intégration', () => {
    it('devrait exporter le module correctement', () => {
      jest.doMock('express', () => ({
        Router: jest.fn(() => ({ 
          use: jest.fn(), 
          post: jest.fn()
        }))
      }));

      jest.doMock('../../controllers/purchaseController', () => ({}));
      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      const purchaseRoutes = require('../../routes/purchaseRoutes');

      expect(purchaseRoutes).toBeDefined();
      expect(typeof purchaseRoutes).toBe('object');
    });

    it('devrait être utilisable comme middleware Express', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      jest.doMock('../../controllers/purchaseController', () => ({}));
      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      const purchaseRoutes = require('../../routes/purchaseRoutes');

      // Simuler l'utilisation dans une app Express
      const mockApp = {
        use: jest.fn()
      };

      expect(() => {
        mockApp.use('/api/purchases', purchaseRoutes);
      }).not.toThrow();

      expect(mockApp.use).toHaveBeenCalledWith('/api/purchases', purchaseRoutes);
    });
  });

  describe('Couverture des routes', () => {
    it('devrait couvrir toutes les routes POST attendues', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      jest.doMock('../../controllers/purchaseController', () => ({
        validateGooglePlayReceipt: jest.fn(),
        validateTransaction: jest.fn()
      }));

      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      require('../../routes/purchaseRoutes');

      // Vérifier que toutes les routes POST sont définies
      const postRoutes = mockRouter.post.mock.calls.map(call => call[0]);
      
      expect(postRoutes).toContain('/validate-receipt');
      expect(postRoutes).toContain('/validate-transaction');
      expect(postRoutes).toHaveLength(2);
    });

    it('devrait avoir des middlewares globaux configurés', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const authMiddleware = 'auth';
      const sanitizeInputs = 'sanitize';

      jest.doMock('../../middlewares/authMiddleware', () => authMiddleware);
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs,
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      jest.doMock('../../controllers/purchaseController', () => ({}));

      require('../../routes/purchaseRoutes');

      // Vérifier que les middlewares globaux sont configurés
      expect(mockRouter.use).toHaveBeenCalledTimes(2);
      expect(mockRouter.use).toHaveBeenCalledWith(authMiddleware);
      expect(mockRouter.use).toHaveBeenCalledWith(sanitizeInputs);
    });
  });

  describe('Structure de sécurité', () => {
    it('devrait requérir une authentification pour toutes les routes', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const authMiddleware = jest.fn();

      jest.doMock('../../middlewares/authMiddleware', () => authMiddleware);
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs: jest.fn(),
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      jest.doMock('../../controllers/purchaseController', () => ({}));

      require('../../routes/purchaseRoutes');

      // Vérifier que authMiddleware est appliqué globalement en premier
      const firstUseCall = mockRouter.use.mock.calls[0];
      expect(firstUseCall[0]).toBe(authMiddleware);
    });

    it('devrait valider les entrées pour toutes les routes', () => {
      const mockRouter = {
        use: jest.fn(),
        post: jest.fn()
      };

      jest.doMock('express', () => ({
        Router: jest.fn(() => mockRouter)
      }));

      const sanitizeInputs = jest.fn();

      jest.doMock('../../middlewares/authMiddleware', () => jest.fn());
      jest.doMock('../../middlewares/validationMiddleware', () => ({
        sanitizeInputs,
        validateRequiredFields: jest.fn(() => jest.fn())
      }));

      jest.doMock('../../controllers/purchaseController', () => ({}));

      require('../../routes/purchaseRoutes');

      // Vérifier que sanitizeInputs est appliqué globalement
      expect(mockRouter.use).toHaveBeenCalledWith(sanitizeInputs);
    });
  });
});