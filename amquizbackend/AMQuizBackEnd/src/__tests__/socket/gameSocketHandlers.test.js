const gameSocketHandlers = require('../../socket/gameSocketHandlers');
const quizService = require('../../services/quizService');
const { generateRoomId } = require('../../utils/helpers');

jest.mock('../../services/quizService');
jest.mock('../../utils/helpers', () => ({
  generateRoomId: jest.fn(),
}));

describe('GameSocketHandlers', () => {
  let socketMock;
  let ioMock;
  let rooms;

  beforeEach(() => {
    socketMock = {
      id: 'socket1',
      on: jest.fn(),
      emit: jest.fn(),
      join: jest.fn(),
    };

    ioMock = {
      to: jest.fn(() => ({
        emit: jest.fn(),
      })),
    };

    rooms = {};
    jest.clearAllMocks();
  });

  describe('handleGameEvents', () => {
    it('should register joinRoom and submitAnswer handlers', () => {
      gameSocketHandlers.handleGameEvents(socketMock, ioMock, rooms);

      expect(socketMock.on).toHaveBeenCalledWith(
        'joinRoom',
        expect.any(Function)
      );
      expect(socketMock.on).toHaveBeenCalledWith(
        'submitAnswer',
        expect.any(Function)
      );
    });
  });

  describe('handleJoinRoom', () => {
    it('should create a new room if none exists', async () => {
      generateRoomId.mockReturnValue('room1');
      quizService.getRandomQuestions.mockResolvedValue([{ q: 1 }, { q: 2 }]);

      await gameSocketHandlers.handleJoinRoom(socketMock, ioMock, rooms, {
        quizName: 'quiz',
        pseudo: 'Alice',
        themeQuizz: 'math',
        uid: 'u1',
      });

      expect(rooms['room1']).toBeDefined();
      expect(socketMock.join).toHaveBeenCalledWith('room1');
      expect(ioMock.to).toHaveBeenCalledWith('room1');
    });

    it('should emit error if no questions are returned', async () => {
      generateRoomId.mockReturnValue('room1');
      quizService.getRandomQuestions.mockResolvedValue([]);

      await gameSocketHandlers.handleJoinRoom(socketMock, ioMock, rooms, {
        quizName: 'quiz',
        pseudo: 'Alice',
        themeQuizz: 'math',
        uid: 'u1',
      });

      expect(socketMock.emit).toHaveBeenCalledWith('error', {
        message: 'Aucune question disponible pour ce quiz',
      });
    });

    it('should emit vsScreen and startQuiz when 2 players join', async () => {
      generateRoomId.mockReturnValue('room1');
      quizService.getRandomQuestions.mockResolvedValue([{ q: 1 }]);

      // Premier joueur
      await gameSocketHandlers.handleJoinRoom(socketMock, ioMock, rooms, {
        quizName: 'quiz',
        pseudo: 'Alice',
        themeQuizz: 'math',
        uid: 'u1',
      });

      // Deuxième joueur
      const socket2 = { ...socketMock, id: 'socket2', join: jest.fn(), emit: jest.fn() };
      await gameSocketHandlers.handleJoinRoom(socket2, ioMock, rooms, {
        quizName: 'quiz',
        pseudo: 'Bob',
        themeQuizz: 'math',
        uid: 'u2',
      });
    });
  });

  describe('handleSubmitAnswer', () => {
    it('should emit error if room does not exist', () => {
      gameSocketHandlers.handleSubmitAnswer(socketMock, ioMock, rooms, {
        roomId: 'roomX',
        isCorrect: true,
      });

      expect(socketMock.emit).toHaveBeenCalledWith('error', {
        message: 'Salle non trouvée',
      });
    });

    it('should emit error if player not in room', () => {
      rooms['room1'] = { players: [], questions: [{}], currentQuestionIndex: 0 };
      gameSocketHandlers.handleSubmitAnswer(socketMock, ioMock, rooms, {
        roomId: 'room1',
        isCorrect: true,
      });

      expect(socketMock.emit).toHaveBeenCalledWith('error', {
        message: 'Joueur non trouvé dans la salle',
      });
    });

    it('should update score and call nextQuestion', () => {
      const player = { id: 'socket1', score: 0, hasAnswered: false };
      rooms['room1'] = {
        players: [player],
        questions: [{}, {}],
        currentQuestionIndex: 0,
      };

      const spyNext = jest.spyOn(gameSocketHandlers, 'nextQuestion');

      gameSocketHandlers.handleSubmitAnswer(socketMock, ioMock, rooms, {
        roomId: 'room1',
        isCorrect: true,
      });

      expect(player.score).toBe(1);
      expect(spyNext).toHaveBeenCalled();
    });

    it('should call endQuiz when last question answered', () => {
      const player = { id: 'socket1', score: 0, hasAnswered: false };
      rooms['room1'] = {
        players: [player],
        questions: [{}],
        currentQuestionIndex: 0,
      };

      const spyEnd = jest.spyOn(gameSocketHandlers, 'endQuiz');

      gameSocketHandlers.handleSubmitAnswer(socketMock, ioMock, rooms, {
        roomId: 'room1',
        isCorrect: true,
      });

      expect(spyEnd).toHaveBeenCalled();
    });
  });

  describe('endQuiz', () => {
    it('should emit quizEnded with final stats', () => {
      const player = { pseudo: 'Alice', id: 's1', uid: 'u1', score: 2 };
      const room = {
        players: [player],
        questions: [{}, {}],
        createdAt: new Date(Date.now() - 1000),
      };

      gameSocketHandlers.endQuiz(ioMock, 'room1', room);

      expect(ioMock.to).toHaveBeenCalledWith('room1');
      const emitArgs = ioMock.to('room1').emit.mock.calls[0];
    });
  });
});
