// src/services/authService.js
const firebaseConfig = require('../config/firebase');
const userRepository = require('../repositories/userRepository');
const userService = require('./userService');
const { validateEmail, validatePassword, validatePseudo } = require('../utils/validators');

class AuthService {
  async register(email, password, pseudo) {
    // Validation des données
    const emailValidation = validateEmail(email);
    if (!emailValidation.isValid) {
      throw new Error(emailValidation.error);
    }

    const passwordValidation = validatePassword(password);
    if (!passwordValidation.isValid) {
      throw new Error(passwordValidation.error);
    }

    const pseudoValidation = validatePseudo(pseudo);
    if (!pseudoValidation.isValid) {
      throw new Error(pseudoValidation.error);
    }

    // Vérifier si l'email existe déjà
    const emailExists = await userRepository.checkEmailExists(email);
    if (emailExists) {
      throw new Error('Cet email est déjà utilisé');
    }

    // Vérifier si le pseudo existe déjà
    const existingUser = await userRepository.getUserByPseudo(pseudo);
    if (existingUser) {
      throw new Error('Ce pseudo est déjà utilisé');
    }

    // Créer l'utilisateur Firebase Auth
    const userRecord = await userRepository.createAuthUser(email, password);
    const uid = userRecord.uid;

    // Créer le profil utilisateur dans Firestore
    await userService.createUserProfile(uid, pseudo);

    return { uid, message: 'Utilisateur créé avec succès' };
  }

  async verifyToken(token) {
    if (!token) {
      throw new Error('Token manquant');
    }

    try {
      const decodedToken = await firebaseConfig.getAuth().verifyIdToken(token);
      return decodedToken;
    } catch (error) {
      throw new Error('Token invalide');
    }
  }

  async verifyTokenFromRequest(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new Error('Token d\'authentification manquant');
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await this.verifyToken(token);
    return decodedToken.uid;
  }

  async validateUserOwnership(req, targetUid) {
    const uid = await this.verifyTokenFromRequest(req);
    if (uid !== targetUid) {
      throw new Error('Action non autorisée');
    }
    return uid;
  }

  async getUserFromRequest(req) {
    const uid = await this.verifyTokenFromRequest(req);
    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }
    return user;
  }
}

module.exports = new AuthService();