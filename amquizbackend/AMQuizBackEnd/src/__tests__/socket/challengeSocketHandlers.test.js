const challengeHandlers = require('../../socket/challengeSocketHandlers');
const quizService = require('../../services/quizService');
const { generateRoomId } = require('../../utils/helpers');

jest.mock('../../services/quizService');
jest.mock('../../utils/helpers');

describe('ChallengeSocketHandlers', () => {
  let socket, io, rooms, targetSocket, joueur1Socket, joueur2Socket;

  beforeEach(() => {
    rooms = {};
    socket = { emit: jest.fn(), id: 'socket1', userUid: 'user1', join: jest.fn() };
    targetSocket = { emit: jest.fn(), userUid: 'user2', id: 'socket2', join: jest.fn() };
    joueur1Socket = socket;
    joueur2Socket = targetSocket;

    io = {
      sockets: { sockets: new Map([['s1', socket], ['s2', targetSocket]]) },
      to: jest.fn().mockReturnThis(),
      emit: jest.fn()
    };

    jest.useFakeTimers();
    jest.clearAllMocks();
  });

  describe('handleSendChallenge', () => {
    it('envoie un défi si le destinataire est trouvé', () => {
      challengeHandlers.handleSendChallenge(socket, io, {
        senderUid: 'user1',
        receiverUid: 'user2',
        nomOeuvre: 'onepiece'
      });

      expect(targetSocket.emit).toHaveBeenCalledWith(
        'receiveChallenge',
        expect.objectContaining({ senderUid: 'user1', nomOeuvre: 'onepiece' })
      );
      expect(socket.emit).toHaveBeenCalledWith(
        'challengeSent',
        expect.objectContaining({ receiverUid: 'user2', nomOeuvre: 'onepiece' })
      );
    });

    it('retourne une erreur si destinataire introuvable', () => {
      io.sockets.sockets = new Map([['s1', socket]]); 

      challengeHandlers.handleSendChallenge(socket, io, {
        senderUid: 'user1',
        receiverUid: 'user2',
        nomOeuvre: 'onepiece'
      });

      expect(socket.emit).toHaveBeenCalledWith(
        'challengeError',
        'Le joueur est hors ligne ou introuvable.'
      );
    });
  });

  describe('handleAcceptChallenge', () => {
    beforeEach(() => {
      generateRoomId.mockReturnValue('room123');
    });

    it('crée une salle et démarre un défi privé', async () => {
      quizService.getRandomQuestions.mockResolvedValue([{ q: 1 }, { q: 2 }]);

      await challengeHandlers.handleAcceptChallenge(socket, io, rooms, {
        uidJoueur1: 'user1',
        uidJoueur2: 'user2',
        nomOeuvre: 'onepiece',
        pseudoJoueur1: 'Luffy',
        pseudoJoueur2: 'Zoro'
      });

      expect(rooms['room123']).toBeDefined();
      expect(io.to).toHaveBeenCalledWith('room123');
      expect(io.emit).toHaveBeenCalledWith(
        'startPrivateGame',
        expect.objectContaining({ roomId: 'room123', uidJoueur1: 'user1', uidJoueur2: 'user2' })
      );

      jest.runAllTimers();
      expect(io.emit).toHaveBeenCalledWith(
        'startQuiz',
        expect.objectContaining({ quizName: 'questionsOnePiece2' })
      );
    });

    it('retourne erreur si un joueur est manquant', async () => {
      io.sockets.sockets = new Map([['s1', socket]]); 
      await challengeHandlers.handleAcceptChallenge(socket, io, rooms, {
        uidJoueur1: 'user1',
        uidJoueur2: 'user2',
        nomOeuvre: 'onepiece',
        pseudoJoueur1: 'Luffy',
        pseudoJoueur2: 'Zoro'
      });

      expect(socket.emit).toHaveBeenCalledWith(
        'challengeError',
        'Un ou les deux joueurs ne sont pas connectés.'
      );
    });

    it('retourne erreur si oeuvre inconnue', async () => {
      await challengeHandlers.handleAcceptChallenge(socket, io, rooms, {
        uidJoueur1: 'user1',
        uidJoueur2: 'user2',
        nomOeuvre: 'unknown',
        pseudoJoueur1: 'Luffy',
        pseudoJoueur2: 'Zoro'
      });

      expect(socket.emit).toHaveBeenCalledWith(
        'challengeError',
        'Œuvre non supportée pour les défis.'
      );
    });

    it('retourne erreur si aucune question', async () => {
      quizService.getRandomQuestions.mockResolvedValue([]);

      await challengeHandlers.handleAcceptChallenge(socket, io, rooms, {
        uidJoueur1: 'user1',
        uidJoueur2: 'user2',
        nomOeuvre: 'onepiece',
        pseudoJoueur1: 'Luffy',
        pseudoJoueur2: 'Zoro'
      });

      expect(socket.emit).toHaveBeenCalledWith(
        'challengeError',
        'Aucune question disponible pour cette œuvre.'
      );
    });
  });

  describe('handleDeclineChallenge', () => {
    it('notifie expéditeur si trouvé', () => {
      challengeHandlers.handleDeclineChallenge(socket, io, {
        senderUid: 'user1',
        receiverUid: 'user2'
      });

      expect(socket.emit).toHaveBeenCalledWith(
        'challengeDeclined',
        expect.objectContaining({ receiverUid: 'user2' })
      );
    });

    it('ne fait rien si expéditeur non trouvé', () => {
      io.sockets.sockets = new Map([['sX', targetSocket]]);
      challengeHandlers.handleDeclineChallenge(socket, io, {
        senderUid: 'user1',
        receiverUid: 'user2'
      });

      expect(socket.emit).not.toHaveBeenCalledWith('challengeDeclined', expect.anything());
    });
  });

  describe('handleCancelChallenge', () => {
    it('annule et notifie destinataire + expéditeur', () => {
      challengeHandlers.handleCancelChallenge(socket, io, {
        senderUid: 'user1',
        receiverUid: 'user2'
      });

      expect(targetSocket.emit).toHaveBeenCalledWith(
        'challengeCancelled',
        expect.objectContaining({ senderUid: 'user1' })
      );
      expect(socket.emit).toHaveBeenCalledWith(
        'challengeCancelled',
        expect.objectContaining({ receiverUid: 'user2' })
      );
    });

    it('notifie uniquement expéditeur si destinataire absent', () => {
      io.sockets.sockets = new Map([['s1', socket]]);
      challengeHandlers.handleCancelChallenge(socket, io, {
        senderUid: 'user1',
        receiverUid: 'user2'
      });

      expect(socket.emit).toHaveBeenCalledWith(
        'challengeCancelled',
        expect.objectContaining({ receiverUid: 'user2' })
      );
    });
  });

  describe('getQuizNameFromOeuvre', () => {
    it('retourne le quiz attendu pour onepiece', () => {
      expect(challengeHandlers.getQuizNameFromOeuvre('onepiece')).toBe('questionsOnePiece2');
    });

    it('retourne null si oeuvre inconnue', () => {
      expect(challengeHandlers.getQuizNameFromOeuvre('dbz')).toBeNull();
    });
  });
});
