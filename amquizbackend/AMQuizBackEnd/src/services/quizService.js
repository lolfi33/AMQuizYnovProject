// src/services/quizService.js
const quizRepository = require('../repositories/quizRepository');
const { shuffleArray } = require('../utils/helpers');

class QuizService {
  async getQuizQuestions(themeQuizz, quizName, limit = 4) {
    // Valider que le quiz existe
    const quizExists = await quizRepository.validateQuizExists(themeQuizz, quizName);
    if (!quizExists) {
      throw new Error(`Quiz ${quizName} introuvable dans le thème ${themeQuizz}`);
    }

    // Récupérer et mélanger les questions
    const questions = await quizRepository.getQuizQuestions(themeQuizz, quizName);
    
    if (questions.length === 0) {
      throw new Error('Aucune question trouvée pour ce quiz');
    }

    // Mélanger et limiter le nombre de questions
    const shuffledQuestions = shuffleArray(questions);
    return shuffledQuestions.slice(0, limit);
  }

  async getRandomQuestions(themeQuizz, quizName, numberOfQuestions = 4) {
    return await this.getQuizQuestions(themeQuizz, quizName, numberOfQuestions);
  }

  async getAllQuizzesByTheme(theme) {
    const quizzes = await quizRepository.getAllQuizzesByTheme(theme);
    
    if (quizzes.length === 0) {
      throw new Error(`Aucun quiz trouvé pour le thème ${theme}`);
    }

    return quizzes;
  }

  async getAllThemes() {
    const themes = await quizRepository.getAllThemes();
    
    if (themes.length === 0) {
      throw new Error('Aucun thème de quiz disponible');
    }

    return themes;
  }

  async validateQuizAccess(themeQuizz, quizName) {
    const isValid = await quizRepository.validateQuizExists(themeQuizz, quizName);
    
    if (!isValid) {
      throw new Error('Quiz non accessible ou inexistant');
    }

    return true;
  }

  processQuizAnswer(question, userAnswer) {
    if (!question || !question.reponse) {
      throw new Error('Question invalide');
    }

    const correctAnswer = question.reponse;
    const isCorrect = userAnswer === correctAnswer;

    return {
      isCorrect,
      correctAnswer,
      userAnswer
    };
  }

  calculateQuizScore(answers) {
    let correctAnswers = 0;
    
    answers.forEach(answer => {
      if (answer.isCorrect) {
        correctAnswers++;
      }
    });

    const totalQuestions = answers.length;
    const percentage = totalQuestions > 0 ? Math.round((correctAnswers / totalQuestions) * 100) : 0;

    return {
      correctAnswers,
      totalQuestions,
      percentage,
      score: correctAnswers
    };
  }

  determineQuizRating(percentage) {
    if (percentage >= 90) return { stars: 3, rating: 'Excellent' };
    if (percentage >= 70) return { stars: 2, rating: 'Bien' };
    if (percentage >= 50) return { stars: 1, rating: 'Passable' };
    return { stars: 0, rating: 'Insuffisant' };
  }
}

module.exports = new QuizService();