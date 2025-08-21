// src/socket/challengeSocketHandlers.js
const quizService = require('../services/quizService');
const { generateRoomId } = require('../utils/helpers');

class ChallengeSocketHandlers {
  handleChallengeEvents(socket, io, rooms) {
    // Envoi d'un défi
    socket.on('sendChallenge', ({ senderUid, receiverUid, nomOeuvre }) => {
      try {
        this.handleSendChallenge(socket, io, { senderUid, receiverUid, nomOeuvre });
      } catch (error) {
        console.error('Erreur lors de l\'envoi de défi:', error);
        socket.emit('challengeError', 'Erreur lors de l\'envoi du défi');
      }
    });

    // Acceptation d'un défi
    socket.on('acceptChallenge', async ({ uidJoueur1, uidJoueur2, nomOeuvre, pseudoJoueur1, pseudoJoueur2 }) => {
      try {
        await this.handleAcceptChallenge(socket, io, rooms, {
          uidJoueur1,
          uidJoueur2,
          nomOeuvre,
          pseudoJoueur1,
          pseudoJoueur2
        });
      } catch (error) {
        console.error('Erreur lors de l\'acceptation de défi:', error);
        socket.emit('challengeError', 'Erreur lors de l\'acceptation du défi');
      }
    });

    // Refus d'un défi
    socket.on('declineChallenge', ({ senderUid, receiverUid }) => {
      try {
        this.handleDeclineChallenge(socket, io, { senderUid, receiverUid });
      } catch (error) {
        console.error('Erreur lors du refus de défi:', error);
      }
    });
  }

  handleSendChallenge(socket, io, { senderUid, receiverUid, nomOeuvre }) {
    console.log(`Défi reçu de ${senderUid} pour ${receiverUid} sur ${nomOeuvre}`);

    // Trouver le socket du destinataire
    const targetSocket = Array.from(io.sockets.sockets.values()).find(
      (s) => s.userUid === receiverUid
    );

    if (targetSocket) {
      targetSocket.emit('receiveChallenge', {
        senderUid,
        nomOeuvre,
        timestamp: new Date().toISOString()
      });
      
      // Confirmer l'envoi à l'expéditeur
      socket.emit('challengeSent', {
        receiverUid,
        nomOeuvre,
        message: 'Défi envoyé avec succès'
      });

      console.log(`${senderUid} a défié ${receiverUid} sur ${nomOeuvre}`);
    } else {
      socket.emit('challengeError', 'Le joueur est hors ligne ou introuvable.');
    }
  }

  async handleAcceptChallenge(socket, io, rooms, {
    uidJoueur1,
    uidJoueur2,
    nomOeuvre,
    pseudoJoueur1,
    pseudoJoueur2
  }) {
    // Trouver les sockets des deux joueurs
    const joueur1Socket = Array.from(io.sockets.sockets.values()).find(
      (s) => s.userUid === uidJoueur1
    );

    const joueur2Socket = Array.from(io.sockets.sockets.values()).find(
      (s) => s.userUid === uidJoueur2
    );

    if (!joueur1Socket || !joueur2Socket) {
      socket.emit('challengeError', 'Un ou les deux joueurs ne sont pas connectés.');
      return;
    }

    // Déterminer le nom du quiz selon l'œuvre
    const quizName = this.getQuizNameFromOeuvre(nomOeuvre);
    if (!quizName) {
      socket.emit('challengeError', 'Œuvre non supportée pour les défis.');
      return;
    }

    // Générer les questions
    const questions = await quizService.getRandomQuestions(nomOeuvre, quizName, 4);
    if (questions.length === 0) {
      socket.emit('challengeError', 'Aucune question disponible pour cette œuvre.');
      return;
    }

    // Créer la salle de défi
    const room = generateRoomId();
    rooms[room] = {
      quizName,
      nomOeuvre,
      isPrivateChallenge: true,
      players: [
        {
          id: joueur1Socket.id,
          pseudo: pseudoJoueur1,
          uid: uidJoueur1,
          score: 0,
          hasAnswered: false
        },
        {
          id: joueur2Socket.id,
          pseudo: pseudoJoueur2,
          uid: uidJoueur2,
          score: 0,
          hasAnswered: false
        },
      ],
      scores: {},
      questions,
      currentQuestionIndex: 0,
      createdAt: new Date(),
    };

    // Faire rejoindre les deux joueurs
    joueur1Socket.join(room);
    joueur2Socket.join(room);

    // Notifier le début de la partie privée
    io.to(room).emit('startPrivateGame', {
      roomId: room,
      quizName: quizName,
      nomOeuvre: nomOeuvre,
      uidJoueur1,
      uidJoueur2,
      questions,
      isPrivateChallenge: true
    });

    // Démarrer le quiz après 3 secondes
    setTimeout(() => {
      if (rooms[room] && rooms[room].players.length === 2) {
        io.to(room).emit('startQuiz', {
          quizName: quizName,
          questions: questions,
          currentQuestion: questions[0],
          isPrivateChallenge: true
        });
      } else {
        console.log(`La salle de défi ${room} n'a pas assez de joueurs pour démarrer le quiz.`);
      }
    }, 3000);

    console.log(`Partie privée entre ${uidJoueur1} et ${uidJoueur2} dans la salle ${room}`);
  }

  handleDeclineChallenge(socket, io, { senderUid, receiverUid }) {
    // Trouver le socket de l'expéditeur pour l'informer du refus
    const senderSocket = Array.from(io.sockets.sockets.values()).find(
      (s) => s.userUid === senderUid
    );

    if (senderSocket) {
      senderSocket.emit('challengeDeclined', {
        receiverUid,
        message: 'Votre défi a été refusé'
      });
    }

    console.log(`Défi de ${senderUid} refusé par ${receiverUid}`);
  }

  getQuizNameFromOeuvre(nomOeuvre) {
    const oeuvreToQuiz = {
      'onepiece': 'questionsOnePiece2',
      'naruto': 'questionsMHA-libre', // Utilise MHA car pas de quiz Naruto 
      'mha': 'questionsMHA-libre',
      'snk': 'questionsMHA-libre' // Utilise MHA car pas de quiz SNK
    };

    return oeuvreToQuiz[nomOeuvre] || null;
  }

  // Méthode pour annuler un défi en attente
  handleCancelChallenge(socket, io, { senderUid, receiverUid }) {
    const targetSocket = Array.from(io.sockets.sockets.values()).find(
      (s) => s.userUid === receiverUid
    );

    if (targetSocket) {
      targetSocket.emit('challengeCancelled', {
        senderUid,
        message: 'Le défi a été annulé'
      });
    }

    socket.emit('challengeCancelled', {
      receiverUid,
      message: 'Défi annulé'
    });
  }
}

module.exports = new ChallengeSocketHandlers();