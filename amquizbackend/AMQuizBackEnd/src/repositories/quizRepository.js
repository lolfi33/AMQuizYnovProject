const path = require('path');
const fs = require('fs');

class QuizRepository {
  constructor() {
    this.quizDataPath = path.join(__dirname, '../../data/quizzes');
  }

  async getQuizQuestions(themeQuizz, quizName) {
    try {
      const filePath = path.join(this.quizDataPath, themeQuizz, `${quizName}.json`);
      
      if (!fs.existsSync(filePath)) {
        throw new Error(`Quiz file not found: ${filePath}`);
      }

      const fileContent = fs.readFileSync(filePath, 'utf-8');
      const questions = JSON.parse(fileContent);
      
      return questions;
    } catch (error) {
      console.error(`Erreur lors du chargement des questions pour ${quizName}:`, error);
      return [];
    }
  }

  async getShuffledQuestions(themeQuizz, quizName, limit = 4) {
    const questions = await this.getQuizQuestions(themeQuizz, quizName);
    
    // Mélanger et limiter le nombre de questions
    const shuffled = questions.sort(() => Math.random() - 0.5);
    return shuffled.slice(0, limit);
  }

  async getAllQuizzesByTheme(theme) {
    try {
      const themePath = path.join(this.quizDataPath, theme);
      
      if (!fs.existsSync(themePath)) {
        return [];
      }

      const files = fs.readdirSync(themePath);
      const quizzes = files
        .filter(file => file.endsWith('.json'))
        .map(file => file.replace('.json', ''));
      
      return quizzes;
    } catch (error) {
      console.error(`Erreur lors de la récupération des quiz pour le thème ${theme}:`, error);
      return [];
    }
  }

  async getAllThemes() {
    try {
      const themes = fs.readdirSync(this.quizDataPath, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory())
        .map(dirent => dirent.name);
      
      return themes;
    } catch (error) {
      console.error('Erreur lors de la récupération des thèmes:', error);
      return [];
    }
  }

  async validateQuizExists(themeQuizz, quizName) {
    const filePath = path.join(this.quizDataPath, themeQuizz, `${quizName}.json`);
    return fs.existsSync(filePath);
  }
}

module.exports = new QuizRepository();