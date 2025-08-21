const express = require('express');
const quizController = require('../controllers/quizController');
const { sanitizeInputs, validateRequiredFields } = require('../middlewares/validationMiddleware');

const router = express.Router();

router.use(sanitizeInputs);

// Routes publiques pour les quiz
router.get('/themes', quizController.getAllThemes);

router.get('/themes/:theme', quizController.getAllQuizzesByTheme);

router.get('/:category/:fileName',
  quizController.getQuizQuestions
);

router.get('/:category/:fileName/random',
  quizController.getRandomQuestions
);

router.get('/:category/:fileName/validate',
  quizController.validateQuizAccess
);

// Routes pour traiter les réponses
router.post('/process-answer',
  validateRequiredFields(['question', 'userAnswer']),
  quizController.processAnswer
);

router.post('/calculate-score',
  validateRequiredFields(['answers']),
  quizController.calculateScore
);

module.exports = router;