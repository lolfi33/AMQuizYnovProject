const authService = require('../services/authService');
const userRepository = require('../repositories/userRepository');
const userService = require('../services/userService');

class AuthController {
  async register(req, res) {
    try {
      const { email, password, pseudo } = req.body;

      if (!email || !password || !pseudo) {
        return res.status(400).json({ 
          error: 'Email, mot de passe et pseudo sont requis' 
        });
      }

      const result = await authService.register(email, password, pseudo);
      
      res.status(201).json({
        message: result.message,
        uid: result.uid
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

async registerGoogle(req, res) {
  try {
    const uid = await authService.verifyTokenFromRequest(req);
    const { pseudo } = req.body;

    const existingUser = await userRepository.getUserByUid(uid);
    
    if (existingUser) {
      // L'utilisateur existe déjà dans Firestore
      return res.status(400).json({ error: 'L\'utilisateur existe déjà' });
    }

    // Vérifier si le pseudo est déjà utilisé
    const pseudoExists = await userRepository.getUserByPseudo(pseudo);
    if (pseudoExists) {
      return res.status(400).json({ error: 'Ce pseudo est déjà utilisé' });
    }

    // Créer le profil utilisateur dans Firestore
    await userService.createUserProfile(uid, pseudo);
    
    res.status(201).json({ message: 'Profil utilisateur créé avec succès' });
  } catch (error) {
    console.error('Erreur lors de l\'inscription Google:', error);
    res.status(400).json({ error: error.message });
  }
}

  async verifyToken(req, res) {
    try {
      const { token } = req.body;

      if (!token) {
        return res.status(400).json({ error: 'Token requis' });
      }

      const decodedToken = await authService.verifyToken(token);
      
      res.status(200).json({ 
        uid: decodedToken.uid,
        email: decodedToken.email 
      });
    } catch (error) {
      res.status(401).json({ error: error.message });
    }
  }

  async refreshToken(req, res) {
    try {
      const uid = await authService.verifyTokenFromRequest(req);
      
      res.status(200).json({ 
        message: 'Token valide',
        uid: uid 
      });
    } catch (error) {
      res.status(401).json({ error: error.message });
    }
  }
}

module.exports = new AuthController();