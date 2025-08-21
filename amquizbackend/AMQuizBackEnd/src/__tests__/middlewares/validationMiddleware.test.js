const {
  sanitizeInputs,
  validateRequiredFields,
  validateDataTypes,
  validateUserOwnership
} = require('../../middlewares/validationMiddleware');

describe('Validation Middleware', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      body: {},
      params: {},
      uid: 'test-uid' 
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
  });

  describe('validateRequiredFields', () => {
    it('devrait passer si tous les champs requis sont présents', () => {
      req.body = { name: 'test', email: 'test@test.com' };
      const middleware = validateRequiredFields(['name', 'email']);
      
      middleware(req, res, next);
      
      expect(next).toHaveBeenCalledTimes(1);
      expect(res.status).not.toHaveBeenCalled();
    });

    it('devrait retourner une erreur 400 si des champs sont manquants', () => {
      req.body = { name: 'test' };
      const middleware = validateRequiredFields(['name', 'email']);
      
      middleware(req, res, next);
      
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        error: 'Champs requis manquants: email'
      });
      expect(next).not.toHaveBeenCalled();
    });

    it('devrait gérer plusieurs champs manquants', () => {
      req.body = {};
      const middleware = validateRequiredFields(['name', 'email', 'password']);
      
      middleware(req, res, next);
      
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        error: 'Champs requis manquants: name, email, password'
      });
    });
  });

  describe('validateDataTypes', () => {
    it('devrait passer si tous les types sont corrects', () => {
      req.body = { 
        isActive: true, 
        age: 25, 
        name: 'test' 
      };
      const middleware = validateDataTypes({
        isActive: 'boolean',
        age: 'number',
        name: 'string'
      });
      
      middleware(req, res, next);
      
      expect(next).toHaveBeenCalledTimes(1);
      expect(res.status).not.toHaveBeenCalled();
    });

    it('devrait retourner une erreur pour un type boolean incorrect', () => {
      req.body = { isActive: 'true' };
      const middleware = validateDataTypes({ isActive: 'boolean' });
      
      middleware(req, res, next);
      
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        error: 'Erreurs de validation: isActive doit être de type boolean, reçu string'
      });
      expect(next).not.toHaveBeenCalled();
    });

    it('devrait retourner une erreur pour un type number incorrect', () => {
      req.body = { age: '25' };
      const middleware = validateDataTypes({ age: 'number' });
      
      middleware(req, res, next);
      
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        error: 'Erreurs de validation: age doit être de type number, reçu string'
      });
    });

    it('devrait ignorer les champs undefined', () => {
      req.body = { name: 'test' };
      const middleware = validateDataTypes({ 
        name: 'string',
        age: 'number' // age n'est pas défini
      });
      
      middleware(req, res, next);
      
      expect(next).toHaveBeenCalledTimes(1);
    });
  });

  describe('validateUserOwnership', () => {
    it('devrait passer si l\'utilisateur possède la ressource', () => {
      req.params.uid = 'test-uid';
      req.uid = 'test-uid'; // Utilisateur authentifié
      
      validateUserOwnership(req, res, next);
      
      expect(next).toHaveBeenCalledTimes(1);
      expect(res.status).not.toHaveBeenCalled();
    });

    it('devrait retourner une erreur 403 si l\'utilisateur ne possède pas la ressource', () => {
      req.params.uid = 'other-uid';
      req.uid = 'test-uid';
      
      validateUserOwnership(req, res, next);
      
      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        error: 'Action non autorisée'
      });
      expect(next).not.toHaveBeenCalled();
    });
  });

  describe('sanitizeInputs', () => {
    it('devrait passer au middleware suivant', () => {
      sanitizeInputs(req, res, next);
      
      expect(next).toHaveBeenCalledTimes(1);
    });
  });
});