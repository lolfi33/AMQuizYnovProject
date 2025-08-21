jest.mock('../../repositories/userRepository', () => ({
  checkEmailExists: jest.fn(),
  getUserByPseudo: jest.fn(),
  createAuthUser: jest.fn(),
  getUserByUid: jest.fn(),
}));

jest.mock('../../services/userService', () => ({
  createUserProfile: jest.fn(),
}));

jest.mock('../../config/firebase', () => ({
  getAuth: jest.fn(() => ({
    verifyIdToken: jest.fn(),
  })),
}));

jest.mock('../../utils/validators', () => ({
  validateEmail: jest.fn(),
  validatePassword: jest.fn(),
  validatePseudo: jest.fn(),
}));

const authService = require('../../services/authService');
const userRepository = require('../../repositories/userRepository');
const userService = require('../../services/userService');
const validators = require('../../utils/validators');
const firebaseConfig = require('../../config/firebase');


describe('AuthService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('crée un utilisateur avec des données valides', async () => {
      validators.validateEmail.mockReturnValue({ isValid: true });
      validators.validatePassword.mockReturnValue({ isValid: true });
      validators.validatePseudo.mockReturnValue({ isValid: true });

      userRepository.checkEmailExists.mockResolvedValue(false);
      userRepository.getUserByPseudo.mockResolvedValue(null);
      userRepository.createAuthUser.mockResolvedValue({ uid: 'uid123' });
      userService.createUserProfile.mockResolvedValue(true);

      const result = await authService.register('test@mail.com', 'Password123', 'Pseudo');

      expect(result).toEqual({ uid: 'uid123', message: 'Utilisateur créé avec succès' });
      expect(userRepository.createAuthUser).toHaveBeenCalledWith('test@mail.com', 'Password123');
      expect(userService.createUserProfile).toHaveBeenCalledWith('uid123', 'Pseudo');
    });

    it('lève une erreur si l\'email est invalide', async () => {
      validators.validateEmail.mockReturnValue({ isValid: false, error: 'Email invalide' });

      await expect(authService.register('bad', 'Password123', 'Pseudo'))
        .rejects.toThrow('Email invalide');
    });

    it('lève une erreur si le mot de passe est invalide', async () => {
      validators.validateEmail.mockReturnValue({ isValid: true });
      validators.validatePassword.mockReturnValue({ isValid: false, error: 'Mot de passe invalide' });

      await expect(authService.register('test@mail.com', 'bad', 'Pseudo'))
        .rejects.toThrow('Mot de passe invalide');
    });

    it('lève une erreur si le pseudo est invalide', async () => {
      validators.validateEmail.mockReturnValue({ isValid: true });
      validators.validatePassword.mockReturnValue({ isValid: true });
      validators.validatePseudo.mockReturnValue({ isValid: false, error: 'Pseudo invalide' });

      await expect(authService.register('test@mail.com', 'Password123', 'bad'))
        .rejects.toThrow('Pseudo invalide');
    });

    it('lève une erreur si l\'email existe déjà', async () => {
      validators.validateEmail.mockReturnValue({ isValid: true });
      validators.validatePassword.mockReturnValue({ isValid: true });
      validators.validatePseudo.mockReturnValue({ isValid: true });

      userRepository.checkEmailExists.mockResolvedValue(true);

      await expect(authService.register('test@mail.com', 'Password123', 'Pseudo'))
        .rejects.toThrow('Cet email est déjà utilisé');
    });

    it('lève une erreur si le pseudo existe déjà', async () => {
      validators.validateEmail.mockReturnValue({ isValid: true });
      validators.validatePassword.mockReturnValue({ isValid: true });
      validators.validatePseudo.mockReturnValue({ isValid: true });

      userRepository.checkEmailExists.mockResolvedValue(false);
      userRepository.getUserByPseudo.mockResolvedValue({ uidUser: 'uid456' });

      await expect(authService.register('test@mail.com', 'Password123', 'Pseudo'))
        .rejects.toThrow('Ce pseudo est déjà utilisé');
    });
  });

  describe('verifyToken', () => {
    it('retourne le token décodé', async () => {
      firebaseConfig.getAuth.mockReturnValue({
        verifyIdToken: jest.fn().mockResolvedValue({ uid: 'uid123' })
      });

      const decoded = await authService.verifyToken('token123');
      expect(decoded).toEqual({ uid: 'uid123' });
    });

    it('lève une erreur si token manquant', async () => {
      await expect(authService.verifyToken()).rejects.toThrow('Token manquant');
    });

    it('lève une erreur si token invalide', async () => {
      firebaseConfig.getAuth.mockReturnValue({
        verifyIdToken: jest.fn().mockRejectedValue(new Error('Invalid'))
      });

      await expect(authService.verifyToken('badtoken')).rejects.toThrow('Token invalide');
    });
  });

  describe('verifyTokenFromRequest', () => {
    it('retourne le uid du token', async () => {
      const req = { headers: { authorization: 'Bearer token123' } };
      jest.spyOn(authService, 'verifyToken').mockResolvedValue({ uid: 'uid123' });

      const uid = await authService.verifyTokenFromRequest(req);
      expect(uid).toBe('uid123');
    });

    it('lève une erreur si header manquant', async () => {
      const req = { headers: {} };
      await expect(authService.verifyTokenFromRequest(req)).rejects.toThrow('Token d\'authentification manquant');
    });
  });

  describe('validateUserOwnership', () => {
    it('retourne le uid si correspond au target', async () => {
      const req = { headers: { authorization: 'Bearer token123' } };
      jest.spyOn(authService, 'verifyTokenFromRequest').mockResolvedValue('uid123');

      const uid = await authService.validateUserOwnership(req, 'uid123');
      expect(uid).toBe('uid123');
    });

    it('lève une erreur si uid différent du target', async () => {
      const req = { headers: { authorization: 'Bearer token123' } };
      jest.spyOn(authService, 'verifyTokenFromRequest').mockResolvedValue('uid123');

      await expect(authService.validateUserOwnership(req, 'uid456'))
        .rejects.toThrow('Action non autorisée');
    });
  });

  describe('getUserFromRequest', () => {
    it('retourne l\'utilisateur si trouvé', async () => {
      const req = { headers: { authorization: 'Bearer token123' } };
      jest.spyOn(authService, 'verifyTokenFromRequest').mockResolvedValue('uid123');
      userRepository.getUserByUid.mockResolvedValue({ uid: 'uid123', pseudo: 'Pseudo' });

      const user = await authService.getUserFromRequest(req);
      expect(user).toEqual({ uid: 'uid123', pseudo: 'Pseudo' });
    });

    it('lève une erreur si utilisateur non trouvé', async () => {
      const req = { headers: { authorization: 'Bearer token123' } };
      jest.spyOn(authService, 'verifyTokenFromRequest').mockResolvedValue('uid123');
      userRepository.getUserByUid.mockResolvedValue(null);

      await expect(authService.getUserFromRequest(req)).rejects.toThrow('Utilisateur non trouvé');
    });
  });
});
