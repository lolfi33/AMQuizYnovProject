const AuthController = require('../../controllers/authController');
const authService = require('../../services/authService');
const userRepository = require('../../repositories/userRepository');
const userService = require('../../services/userService');

jest.mock('../../services/authService');
jest.mock('../../repositories/userRepository');
jest.mock('../../services/userService');

describe('AuthController', () => {
  let req;
  let res;
  const authController = require('../../controllers/authController');

  beforeEach(() => {
    req = { body: {}, headers: {} };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should return 400 if email, password or pseudo is missing', async () => {
      req.body = { email: 'test@test.com', password: '' };
      await authController.register(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Email, mot de passe et pseudo sont requis' });
    });

    it('should call authService.register and return 201', async () => {
      req.body = { email: 'test@test.com', password: '123456', pseudo: 'TestUser' };
      authService.register.mockResolvedValue({ uid: 'uid123', message: 'Utilisateur créé avec succès' });

      await authController.register(req, res);

      expect(authService.register).toHaveBeenCalledWith('test@test.com', '123456', 'TestUser');
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({ message: 'Utilisateur créé avec succès', uid: 'uid123' });
    });

    it('should return 400 if authService.register throws', async () => {
      req.body = { email: 'test@test.com', password: '123456', pseudo: 'TestUser' };
      authService.register.mockRejectedValue(new Error('Erreur test'));

      await authController.register(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur test' });
    });
  });

  describe('registerGoogle', () => {
    it('should return 400 if user already exists', async () => {
      req.body = { pseudo: 'TestUser' };
      authService.verifyTokenFromRequest.mockResolvedValue('uid123');
      userRepository.getUserByUid.mockResolvedValue({ uidUser: 'uid123' });

      await authController.registerGoogle(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "L'utilisateur existe déjà" });
    });

    it('should return 400 if pseudo already used', async () => {
      req.body = { pseudo: 'TestUser' };
      authService.verifyTokenFromRequest.mockResolvedValue('uid123');
      userRepository.getUserByUid.mockResolvedValue(null);
      userRepository.getUserByPseudo.mockResolvedValue({ uidUser: 'uid456' });

      await authController.registerGoogle(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Ce pseudo est déjà utilisé' });
    });

    it('should create user profile and return 201', async () => {
      req.body = { pseudo: 'TestUser' };
      authService.verifyTokenFromRequest.mockResolvedValue('uid123');
      userRepository.getUserByUid.mockResolvedValue(null);
      userRepository.getUserByPseudo.mockResolvedValue(null);
      userService.createUserProfile.mockResolvedValue();

      await authController.registerGoogle(req, res);

      expect(userService.createUserProfile).toHaveBeenCalledWith('uid123', 'TestUser');
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({ message: 'Profil utilisateur créé avec succès' });
    });

    it('should return 400 if an error occurs', async () => {
      req.body = { pseudo: 'TestUser' };
      authService.verifyTokenFromRequest.mockRejectedValue(new Error('Erreur test'));

      await authController.registerGoogle(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur test' });
    });
  });

  describe('verifyToken', () => {
    it('should return 400 if token is missing', async () => {
      req.body = {};
      await authController.verifyToken(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Token requis' });
    });

    it('should return 200 with decoded token', async () => {
      req.body = { token: 'token123' };
      authService.verifyToken.mockResolvedValue({ uid: 'uid123', email: 'test@test.com' });

      await authController.verifyToken(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ uid: 'uid123', email: 'test@test.com' });
    });

    it('should return 401 if verifyToken throws', async () => {
      req.body = { token: 'token123' };
      authService.verifyToken.mockRejectedValue(new Error('Token invalide'));

      await authController.verifyToken(req, res);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: 'Token invalide' });
    });
  });

  describe('refreshToken', () => {
    it('should return 200 with uid if token is valid', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uid123');

      await authController.refreshToken(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ message: 'Token valide', uid: 'uid123' });
    });

    it('should return 401 if token is invalid', async () => {
      authService.verifyTokenFromRequest.mockRejectedValue(new Error('Token invalide'));

      await authController.refreshToken(req, res);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: 'Token invalide' });
    });
  });
});
