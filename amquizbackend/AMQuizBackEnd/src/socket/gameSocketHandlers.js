// src/socket/gameSocketHandlers.js
const quizService = require('../services/quizService');
const { generateRoomId } = require('../utils/helpers');

class GameSocketHandlers {
  handleGameEvents(socket, io, rooms) {
    // Rejoindre ou créer une salle pour un quiz
    socket.on('joinRoom', async ({ quizName, pseudo, themeQuizz, uid }) => {
      try {
        await this.handleJoinRoom(socket, io, rooms, { quizName, pseudo, themeQuizz, uid });
      } catch (error) {
        console.error('Erreur lors de la jointure de salle:', error);
        socket.emit('error', { message: 'Erreur lors de la jointure de salle' });
      }
    });

    // Soumission d'une réponse
    socket.on('submitAnswer', ({ roomId, isCorrect }) => {
      try {
        this.handleSubmitAnswer(socket, io, rooms, { roomId, isCorrect });
      } catch (error) {
        console.error('Erreur lors de la soumission de réponse:', error);
        socket.emit('error', { message: 'Erreur lors de la soumission de réponse' });
      }
    });
  }

  async handleJoinRoom(socket, io, rooms, { quizName, pseudo, themeQuizz, uid }) {
    // Chercher une salle existante avec de la place
    let room = Object.keys(rooms).find(
      (roomId) => rooms[roomId].quizName === quizName && rooms[roomId].players.length < 2
    );

    // Créer une nouvelle salle si aucune n'est disponible
    if (!room) {
      room = generateRoomId();
      
      // Générer les questions pour le quiz
      const questions = await quizService.getRandomQuestions(themeQuizz, quizName, 4);
      
      if (questions.length === 0) {
        socket.emit('error', { message: 'Aucune question disponible pour ce quiz' });
        return;
      }

      rooms[room] = {
        quizName,
        themeQuizz,
        players: [],
        scores: {},
        questions: questions,
        currentQuestionIndex: 0,
        createdAt: new Date(),
      };
    }

    // Ajouter le joueur à la salle
    const player = {
      id: socket.id,
      pseudo,
      uid,
      score: 0,
      hasAnswered: false,
      joinedAt: new Date()
    };

    rooms[room].players.push(player);
    socket.join(room);

    console.log(`Joueur ${pseudo} (${socket.id}) a rejoint la salle ${room}`);

    // Notifier les autres joueurs
    io.to(room).emit('roomUpdate', { 
      roomId: room, 
      players: rooms[room].players.map(p => ({
        id: p.id,
        pseudo: p.pseudo,
        uid: p.uid,
        score: p.score
      }))
    });

    // Si on a 2 joueurs, commencer le match
    if (rooms[room].players.length === 2) {
      // Écran de confrontation
      io.to(room).emit('vsScreen', {
        roomId: room,
        players: rooms[room].players.map(player => ({
          id: player.id,
          pseudo: player.pseudo,
          uid: player.uid,
        })),
      });

      // Démarrer le quiz après 3 secondes
      setTimeout(() => {
        if (rooms[room] && rooms[room].players.length >= 2) {
          io.to(room).emit('startQuiz', {
            quizName: rooms[room].quizName,
            questions: rooms[room].questions,
            currentQuestion: rooms[room].questions[0]
          });
        } else {
          console.log(`La salle ${room} n'a pas assez de joueurs pour démarrer le quiz.`);
        }
      }, 3000);
    }
  }

  handleSubmitAnswer(socket, io, rooms, { roomId, isCorrect }) {
    console.log(`Réponse reçue : Room=${roomId}, Correct=${isCorrect}, Socket=${socket.id}`);
    
    const room = rooms[roomId];
    if (!room) {
      socket.emit('error', { message: 'Salle non trouvée' });
      return;
    }

    const player = room.players.find((player) => player.id === socket.id);
    if (!player) {
      socket.emit('error', { message: 'Joueur non trouvé dans la salle' });
      return;
    }

    // Vérifier si le joueur a déjà répondu
    if (player.hasAnswered) {
      console.log(`Le joueur ${socket.id} a déjà répondu, réponse ignorée.`);
      return;
    }

    // Mettre à jour le score si la réponse est correcte
    if (isCorrect) {
      player.score += 1;
    }

    player.hasAnswered = true;

    // Vérifier si tous les joueurs ont répondu
    if (room.players.every((player) => player.hasAnswered)) {
      // Réinitialiser pour la prochaine question
      room.players.forEach((player) => (player.hasAnswered = false));
      room.currentQuestionIndex += 1;

      // Vérifier si le quiz est terminé
      if (room.currentQuestionIndex >= room.questions.length) {
        this.endQuiz(io, roomId, room);
      } else {
        // Passer à la question suivante
        this.nextQuestion(io, roomId, room);
      }
    }
  }

  endQuiz(io, roomId, room) {
    const maxScore = Math.max(...room.players.map((player) => player.score));
    const topPlayers = room.players.filter(player => player.score === maxScore);

    const winner = topPlayers.length > 1 ? "Égalité" : topPlayers[0].pseudo;

    // Calculer les statistiques finales
    const finalStats = {
      scores: room.players.reduce((acc, player) => {
        acc[player.pseudo] = player.score;
        return acc;
      }, {}),
      winner: winner,
      uid: room.players.map(player => player.uid),
      totalQuestions: room.questions.length,
      duration: new Date() - room.createdAt
    };

    io.to(roomId).emit('quizEnded', finalStats);

    // Supprimer la salle après l'émission des événements
    setTimeout(() => {
      delete room[roomId];
      console.log(`Salle ${roomId} supprimée après la fin du quiz`);
    }, 5000); // Délai pour permettre aux clients de traiter les résultats
  }

  nextQuestion(io, roomId, room) {
    const currentQuestion = room.questions[room.currentQuestionIndex];
    
    io.to(roomId).emit('nextQuestion', {
      question: currentQuestion,
      questionIndex: room.currentQuestionIndex,
      totalQuestions: room.questions.length,
      scores: room.players.map((player) => ({
        id: player.id,
        pseudo: player.pseudo,
        score: player.score,
      })),
    });
  }
}

module.exports = new GameSocketHandlers();