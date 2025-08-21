// src/app.js
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const path = require('path');

// Initialisation de l'application Express
const app = express();

// ==================== MIDDLEWARES GLOBAUX ====================
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.set('trust proxy', 1);

// Rate limiting global
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // Limite globale plus élevée
  message: {
    error: 'Trop de requêtes depuis cette IP, veuillez réessayer plus tard.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(globalLimiter);

// ==================== ROUTES DE SANTÉ ET INFORMATIONS ====================
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: process.env.npm_package_version || '2.0.0'
  });
});

app.get('/info', (req, res) => {
  res.status(200).json({
    name: 'AMQuiz Backend',
    version: '2.0.0',
    description: 'Backend pour l\'application AMQuiz',
    endpoints: {
      auth: '/api/auth',
      shop: '/api/shop', 
      quiz: '/api/quiz',
      users: '/api/users',
      friends: '/api/friends',
      missions: '/api/missions',
      signalement: '/api/signalement'
    }
  });
});

// ==================== ROUTES STATIQUES ====================
// Servir les fichiers de quiz depuis le dossier data
app.use('/quiz', express.static(path.join(__dirname, '../data/quizzes')));

// ==================== MONTAGE DES ROUTES API ====================
// Routes d'authentification
app.use('/api/auth', require('./routes/authRoutes'));

// Routes utilisateur
app.use('/api/users', require('./routes/userRoutes'));

// Routes shop - IMPORTANT: montage sur /api/shop
app.use('/api/shop', require('./routes/shopRoutes'));

// Routes quiz
app.use('/api/quiz', require('./routes/quizRoutes'));

// Routes amis
app.use('/api/friends', require('./routes/friendRoutes'));

// Routes missions
app.use('/api/missions', require('./routes/missionRoutes'));

// Routes signalement
app.use('/api/signalement', require('./routes/signalementRoutes'));

// Route achat intégrés
app.use('/', require('./routes/purchaseRoutes'));

// ==================== ROUTES DE COMPATIBILITÉ (ANCIENNES) ====================
// Routes directes pour compatibilité avec l'ancien système
// À supprimer progressivement une fois que le frontend est mis à jour

app.get('/quiz/:category/:fileName', async(req, res) => {
  const { category, fileName } = req.params;
  
  try {
    console.log(`🔍 Demande de quiz: category=${category}, fileName=${fileName}`);
    
    // Construction du chemin correct
    const filePath = path.join(__dirname, '../data/quizzes', category, `${fileName}.json`);
    console.log(`🔍 Chemin fichier: ${filePath}`);
    
    // Vérifier si le fichier existe
    const fs = require('fs');
    if (!fs.existsSync(filePath)) {
      console.log(`❌ Fichier non trouvé: ${filePath}`);
      return res.status(404).json({ error: `Quiz ${fileName} non trouvé dans la catégorie ${category}` });
    }
    
    // Lire et retourner le contenu JSON
    const fileContent = fs.readFileSync(filePath, 'utf-8');
    const questions = JSON.parse(fileContent);
    
    console.log(`✅ Quiz trouvé: ${questions.length} questions`);
    res.status(200).json(questions);
    
  } catch (error) {
    console.error(`❌ Erreur lors du chargement du quiz:`, error);
    res.status(500).json({ error: 'Erreur serveur lors du chargement du quiz' });
  }
});

// Routes de missions sans /api (pour compatibilité)
const missionController = require('./controllers/missionController');
const authMiddleware = require('./middlewares/authMiddleware');

app.post('/obtenirRecompense', authMiddleware, missionController.claimReward);
app.post('/gagnerQuizEnLigne', authMiddleware, missionController.updateQuizOnlineProgress);
app.post('/gagner10ptsQuiSuisJe', authMiddleware, missionController.updateQuiSuisJe10Points);
app.post('/gagner15ptsQuiSuisJe', authMiddleware, missionController.updateQuiSuisJe15Points);
app.post('/faireQuizAvecAmi', authMiddleware, missionController.updateQuizWithFriend);
app.post('/faireQuizMultiAvecAmi', authMiddleware, missionController.updateMultiQuizWithFriend);
app.post('/faireQuizMulti', authMiddleware, missionController.updateMultiQuiz);
app.post('/jouerQuiSuiJe', authMiddleware, missionController.updateQuiSuisJePlay);

// Routes utilisateur sans /api (pour compatibilité)
const userController = require('./controllers/userController');

app.post('/update-pdp', authMiddleware, userController.updateProfilePicture);
app.post('/update-banniere', authMiddleware, userController.updateBanner);
app.post('/update-titre', authMiddleware, userController.updateTitle);
app.post('/update-like', authMiddleware, userController.sendLike);
app.post('/update-presence', authMiddleware, userController.updatePresence);
app.post('/perdre-vies', authMiddleware, userController.loseLife);

// Routes records sans /api (pour compatibilité)
app.post('/update-records-onepiece', authMiddleware, (req, res) => {
  req.body.recordType = 'recordsOnePiece';
  userController.updateRecords(req, res);
});

app.post('/update-records-snk', authMiddleware, (req, res) => {
  req.body.recordType = 'recordsSNK';
  userController.updateRecords(req, res);
});

app.post('/update-records-mha', authMiddleware, (req, res) => {
  req.body.recordType = 'recordsMHA';
  userController.updateRecords(req, res);
});

// Routes déblocage sans /api (pour compatibilité)
app.post('/debloque-prochaine-ile-onepiece', authMiddleware, (req, res) => {
  req.body.adventureType = 'onepiece';
  userController.unlockNextLevel(req, res);
});

app.post('/debloque-prochaine-ile-snk', authMiddleware, (req, res) => {
  req.body.adventureType = 'snk';
  userController.unlockNextLevel(req, res);
});

app.post('/debloque-prochaine-ile-mha', authMiddleware, (req, res) => {
  req.body.adventureType = 'mha';
  userController.unlockNextLevel(req, res);
});

// Routes amis sans /api (pour compatibilité)
const friendController = require('./controllers/friendController');

app.post('/add-friend', authMiddleware, friendController.acceptInvitation);
app.post('/delete-friend', authMiddleware, friendController.deleteFriend);
app.post('/envoyer-invitation', authMiddleware, friendController.sendInvitation);
app.post('/delete-invitation', authMiddleware, friendController.deleteInvitation);

// Routes shop sans /api (pour compatibilité)
const shopController = require('./controllers/shopController');

app.get('/get-prices', shopController.getPrices);
app.post('/acheter-item', authMiddleware, shopController.buyItem);
app.post('/open-coffre', authMiddleware, shopController.openChest);
app.post('/open-enveloppe', authMiddleware, shopController.openEnvelope);
app.post('/sell-item', authMiddleware, shopController.sellItem);

// Routes signalement sans /api (pour compatibilité)
const signalementController = require('./controllers/signalementController');

app.post('/signaler-utilisateur', authMiddleware, signalementController.createSignalement);

// ==================== GESTION DES ERREURS ====================
// Middleware pour les routes non trouvées
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route non trouvée',
    path: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString()
  });
});

// Middleware de gestion d'erreurs globales
app.use((error, req, res, next) => {
  console.error('Erreur serveur:', error);
  
  res.status(error.status || 500).json({
    error: process.env.NODE_ENV === 'production' 
      ? 'Erreur interne du serveur' 
      : error.message,
    timestamp: new Date().toISOString(),
    path: req.originalUrl
  });
});

// ==================== EXPORT ====================
module.exports = {
  getApp: () => app
};