const quizService = require('../../services/quizService');
const quizRepository = require('../../repositories/quizRepository');
const { shuffleArray } = require('../../utils/helpers');

jest.mock('../../repositories/quizRepository');
jest.mock('../../utils/helpers');

describe('QuizService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getQuizQuestions', () => {
    it('devrait renvoyer des questions mélangées et limitées', async () => {
      quizRepository.validateQuizExists.mockResolvedValue(true);
      quizRepository.getQuizQuestions.mockResolvedValue([
        { id: 1, reponse: 'A' },
        { id: 2, reponse: 'B' },
        { id: 3, reponse: 'C' },
        { id: 4, reponse: 'D' },
        { id: 5, reponse: 'E' },
      ]);
      shuffleArray.mockReturnValue([
        { id: 3, reponse: 'C' },
        { id: 1, reponse: 'A' },
        { id: 2, reponse: 'B' },
        { id: 4, reponse: 'D' },
        { id: 5, reponse: 'E' },
      ]);

      const result = await quizService.getQuizQuestions('anime', 'naruto', 3);

      expect(result).toHaveLength(3);
      expect(quizRepository.validateQuizExists).toHaveBeenCalledWith('anime', 'naruto');
      expect(quizRepository.getQuizQuestions).toHaveBeenCalledWith('anime', 'naruto');
      expect(shuffleArray).toHaveBeenCalled();
    });

    it('devrait lever une erreur si le quiz n’existe pas', async () => {
      quizRepository.validateQuizExists.mockResolvedValue(false);

      await expect(
        quizService.getQuizQuestions('anime', 'naruto')
      ).rejects.toThrow('Quiz naruto introuvable dans le thème anime');
    });

    it('devrait lever une erreur si aucune question trouvée', async () => {
      quizRepository.validateQuizExists.mockResolvedValue(true);
      quizRepository.getQuizQuestions.mockResolvedValue([]);

      await expect(
        quizService.getQuizQuestions('anime', 'naruto')
      ).rejects.toThrow('Aucune question trouvée pour ce quiz');
    });
  });

  describe('getRandomQuestions', () => {
    it('devrait simplement appeler getQuizQuestions avec le nombre demandé', async () => {
      const spy = jest.spyOn(quizService, 'getQuizQuestions').mockResolvedValue(['Q1']);
      const result = await quizService.getRandomQuestions('anime', 'naruto', 2);

      expect(result).toEqual(['Q1']);
      expect(spy).toHaveBeenCalledWith('anime', 'naruto', 2);
    });
  });

  describe('getAllQuizzesByTheme', () => {
    it('devrait renvoyer tous les quizzes du thème', async () => {
      quizRepository.getAllQuizzesByTheme.mockResolvedValue(['quiz1', 'quiz2']);

      const result = await quizService.getAllQuizzesByTheme('anime');
      expect(result).toEqual(['quiz1', 'quiz2']);
    });

    it('devrait lever une erreur si aucun quiz trouvé', async () => {
      quizRepository.getAllQuizzesByTheme.mockResolvedValue([]);

      await expect(quizService.getAllQuizzesByTheme('anime'))
        .rejects.toThrow('Aucun quiz trouvé pour le thème anime');
    });
  });

  describe('getAllThemes', () => {
    it('devrait renvoyer tous les thèmes', async () => {
      quizRepository.getAllThemes.mockResolvedValue(['anime', 'manga']);
      const result = await quizService.getAllThemes();

      expect(result).toEqual(['anime', 'manga']);
    });

    it('devrait lever une erreur si aucun thème trouvé', async () => {
      quizRepository.getAllThemes.mockResolvedValue([]);
      await expect(quizService.getAllThemes())
        .rejects.toThrow('Aucun thème de quiz disponible');
    });
  });

  describe('validateQuizAccess', () => {
    it('devrait renvoyer true si le quiz existe', async () => {
      quizRepository.validateQuizExists.mockResolvedValue(true);
      const result = await quizService.validateQuizAccess('anime', 'naruto');

      expect(result).toBe(true);
    });

    it('devrait lever une erreur si le quiz n’existe pas', async () => {
      quizRepository.validateQuizExists.mockResolvedValue(false);
      await expect(quizService.validateQuizAccess('anime', 'naruto'))
        .rejects.toThrow('Quiz non accessible ou inexistant');
    });
  });

  describe('processQuizAnswer', () => {
    it('devrait retourner isCorrect = true si réponse correcte', () => {
      const result = quizService.processQuizAnswer({ reponse: 'A' }, 'A');

      expect(result).toEqual({
        isCorrect: true,
        correctAnswer: 'A',
        userAnswer: 'A',
      });
    });

    it('devrait retourner isCorrect = false si réponse incorrecte', () => {
      const result = quizService.processQuizAnswer({ reponse: 'A' }, 'B');

      expect(result.isCorrect).toBe(false);
    });

    it('devrait lever une erreur si question invalide', () => {
      expect(() => quizService.processQuizAnswer(null, 'A'))
        .toThrow('Question invalide');
    });
  });

  describe('calculateQuizScore', () => {
    it('devrait calculer correctement le score', () => {
      const answers = [
        { isCorrect: true },
        { isCorrect: false },
        { isCorrect: true },
      ];

      const result = quizService.calculateQuizScore(answers);

      expect(result).toEqual({
        correctAnswers: 2,
        totalQuestions: 3,
        percentage: 67,
        score: 2,
      });
    });

    it('devrait renvoyer 0 si aucune question', () => {
      const result = quizService.calculateQuizScore([]);
      expect(result.percentage).toBe(0);
    });
  });

  describe('determineQuizRating', () => {
    it('devrait renvoyer Excellent si >= 90', () => {
      expect(quizService.determineQuizRating(95))
        .toEqual({ stars: 3, rating: 'Excellent' });
    });

    it('devrait renvoyer Bien si >= 70', () => {
      expect(quizService.determineQuizRating(75))
        .toEqual({ stars: 2, rating: 'Bien' });
    });

    it('devrait renvoyer Passable si >= 50', () => {
      expect(quizService.determineQuizRating(55))
        .toEqual({ stars: 1, rating: 'Passable' });
    });

    it('devrait renvoyer Insuffisant si < 50', () => {
      expect(quizService.determineQuizRating(40))
        .toEqual({ stars: 0, rating: 'Insuffisant' });
    });
  });
});
