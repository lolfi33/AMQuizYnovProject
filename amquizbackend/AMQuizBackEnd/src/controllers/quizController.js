const quizService = require('../services/quizService');

class QuizController {
  async getQuizQuestions(req, res) {
    try {
      const { category, fileName } = req.params;
      const { limit } = req.query;

      if (!category || !fileName) {
        return res.status(400).json({ 
          error: 'Catégorie et nom du fichier requis' 
        });
      }

      const questions = await quizService.getQuizQuestions(
        category, 
        fileName, 
        limit ? parseInt(limit) : 4
      );

      res.status(200).json(questions);
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async getRandomQuestions(req, res) {
    try {
      const { category, fileName } = req.params;
      const { count } = req.query;

      if (!category || !fileName) {
        return res.status(400).json({ 
          error: 'Catégorie et nom du fichier requis' 
        });
      }

      const questions = await quizService.getRandomQuestions(
        category, 
        fileName, 
        count ? parseInt(count) : 4
      );

      res.status(200).json(questions);
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async getAllQuizzesByTheme(req, res) {
    try {
      const { theme } = req.params;

      if (!theme) {
        return res.status(400).json({ error: 'Thème requis' });
      }

      const quizzes = await quizService.getAllQuizzesByTheme(theme);
      res.status(200).json(quizzes);
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async getAllThemes(req, res) {
    try {
      const themes = await quizService.getAllThemes();
      res.status(200).json(themes);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async validateQuizAccess(req, res) {
    try {
      const { category, fileName } = req.params;

      if (!category || !fileName) {
        return res.status(400).json({ 
          error: 'Catégorie et nom du fichier requis' 
        });
      }

      const isValid = await quizService.validateQuizAccess(category, fileName);
      res.status(200).json({ 
        valid: isValid,
        message: 'Quiz accessible' 
      });
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async processAnswer(req, res) {
    try {
      const { question, userAnswer } = req.body;

      if (!question || userAnswer === undefined) {
        return res.status(400).json({ 
          error: 'Question et réponse utilisateur requises' 
        });
      }

      const result = quizService.processQuizAnswer(question, userAnswer);
      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async calculateScore(req, res) {
    try {
      const { answers } = req.body;

      if (!answers || !Array.isArray(answers)) {
        return res.status(400).json({ 
          error: 'Liste des réponses requise' 
        });
      }

      const score = quizService.calculateQuizScore(answers);
      const rating = quizService.determineQuizRating(score.percentage);

      res.status(200).json({
        ...score,
        ...rating
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

module.exports = new QuizController();