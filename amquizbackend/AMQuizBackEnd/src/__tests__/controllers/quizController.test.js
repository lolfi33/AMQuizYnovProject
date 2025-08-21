const quizController = require('../../controllers/quizController');
const quizService = require('../../services/quizService');

jest.mock('../../services/quizService');

describe('QuizController', () => {
  let req, res;

  beforeEach(() => {
    req = { params: {}, query: {}, body: {} };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    jest.clearAllMocks();
  });

  describe('getQuizQuestions', () => {
    it('should return 400 if category or fileName missing', async () => {
      await quizController.getQuizQuestions(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Catégorie et nom du fichier requis' });
    });

    it('should return questions with 200', async () => {
      req.params = { category: 'anime', fileName: 'quiz1' };
      req.query = { limit: '5' };
      quizService.getQuizQuestions.mockResolvedValue(['q1','q2']);
      
      await quizController.getQuizQuestions(req, res);

      expect(quizService.getQuizQuestions).toHaveBeenCalledWith('anime','quiz1',5);
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(['q1','q2']);
    });

    it('should return 404 if service throws', async () => {
      req.params = { category: 'anime', fileName: 'quiz1' };
      quizService.getQuizQuestions.mockRejectedValue(new Error('Erreur'));

      await quizController.getQuizQuestions(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('getRandomQuestions', () => {
    it('should return 400 if category or fileName missing', async () => {
      await quizController.getRandomQuestions(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Catégorie et nom du fichier requis' });
    });

    it('should return random questions with 200', async () => {
      req.params = { category: 'anime', fileName: 'quiz1' };
      req.query = { count: '3' };
      quizService.getRandomQuestions.mockResolvedValue(['qA','qB']);

      await quizController.getRandomQuestions(req, res);

      expect(quizService.getRandomQuestions).toHaveBeenCalledWith('anime','quiz1',3);
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(['qA','qB']);
    });

    it('should return 404 if service throws', async () => {
      req.params = { category: 'anime', fileName: 'quiz1' };
      quizService.getRandomQuestions.mockRejectedValue(new Error('Erreur'));
      
      await quizController.getRandomQuestions(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('getAllQuizzesByTheme', () => {
    it('should return 400 if theme missing', async () => {
      await quizController.getAllQuizzesByTheme(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Thème requis' });
    });

    it('should return quizzes with 200', async () => {
      req.params = { theme: 'shonen' };
      quizService.getAllQuizzesByTheme.mockResolvedValue(['quiz1','quiz2']);

      await quizController.getAllQuizzesByTheme(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(['quiz1','quiz2']);
    });

    it('should return 404 if service throws', async () => {
      req.params = { theme: 'shonen' };
      quizService.getAllQuizzesByTheme.mockRejectedValue(new Error('Erreur'));

      await quizController.getAllQuizzesByTheme(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('getAllThemes', () => {
    it('should return themes with 200', async () => {
      quizService.getAllThemes.mockResolvedValue(['anime','manga']);

      await quizController.getAllThemes(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(['anime','manga']);
    });

    it('should return 500 if service throws', async () => {
      quizService.getAllThemes.mockRejectedValue(new Error('Erreur'));

      await quizController.getAllThemes(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('validateQuizAccess', () => {
    it('should return 400 if category or fileName missing', async () => {
      await quizController.validateQuizAccess(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should return 200 with validation', async () => {
      req.params = { category: 'anime', fileName: 'quiz1' };
      quizService.validateQuizAccess.mockResolvedValue(true);

      await quizController.validateQuizAccess(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ valid: true, message: 'Quiz accessible' });
    });

    it('should return 404 if service throws', async () => {
      req.params = { category: 'anime', fileName: 'quiz1' };
      quizService.validateQuizAccess.mockRejectedValue(new Error('Erreur'));

      await quizController.validateQuizAccess(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('processAnswer', () => {
    it('should return 400 if question or userAnswer missing', async () => {
      await quizController.processAnswer(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should return result with 200', async () => {
      req.body = { question: 'q1', userAnswer: 'a1' };
      quizService.processQuizAnswer.mockReturnValue({ correct: true });

      await quizController.processAnswer(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ correct: true });
    });
  });

  describe('calculateScore', () => {
    it('should return 400 if answers missing or not array', async () => {
      await quizController.calculateScore(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should return score and rating with 200', async () => {
      req.body = { answers: ['a1','a2'] };
      quizService.calculateQuizScore.mockReturnValue({ total: 2, correct: 1, percentage: 50 });
      quizService.determineQuizRating.mockReturnValue({ rating: 'B' });

      await quizController.calculateScore(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ total: 2, correct: 1, percentage: 50, rating: 'B' });
    });
  });
});
