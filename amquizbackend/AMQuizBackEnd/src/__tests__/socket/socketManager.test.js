const socketIo = require('socket.io');
const manager = require('../../socket/socketManager');
const gameSocketHandlers = require('../../socket/gameSocketHandlers');
const challengeSocketHandlers = require('../../socket/challengeSocketHandlers');

jest.mock('../../socket/gameSocketHandlers', () => ({
  handleGameEvents: jest.fn(),
}));
jest.mock('../../socket/challengeSocketHandlers', () => ({
  handleChallengeEvents: jest.fn(),
}));

jest.mock('socket.io', () => {
  const onMock = jest.fn();
  const toMock = jest.fn(() => ({ emit: jest.fn() }));
  const socketsMock = new Map();
  return jest.fn(() => ({
    on: onMock,
    to: toMock,
    sockets: { sockets: socketsMock },
  }));
});

describe('SocketManager', () => {
  let serverMock;
  let socketMock;

  beforeEach(() => {
    serverMock = {};
    socketMock = {
      id: 'socket1',
      on: jest.fn(),
      emit: jest.fn(),
      disconnect: jest.fn(),
    };

    socketIo.mockClear();
    gameSocketHandlers.handleGameEvents.mockClear();
    challengeSocketHandlers.handleChallengeEvents.mockClear();
  });

  it('should authenticate a socket and disconnect old sessions', () => {
    manager.io = {
      sockets: {
        sockets: new Map([
          ['oldSocket', { id: 'oldSocket', userUid: 'user1', disconnect: jest.fn() }],
        ]),
      },
    };

    manager.handleAuthentication(socketMock);
    const authCallback = socketMock.on.mock.calls.find(c => c[0] === 'authenticate')[1];

    authCallback('user1'); // authentifie le socket

    expect(socketMock.userUid).toBe('user1');
    const oldSocket = manager.io.sockets.sockets.get('oldSocket');
    expect(oldSocket.disconnect).toHaveBeenCalled();
  });

  it('should remove player from room on leaveRoom', () => {
    const roomId = 'room1';
    manager.rooms[roomId] = { players: [{ id: socketMock.id }] };
    manager.io = { to: jest.fn(() => ({ emit: jest.fn() })) };

    manager.handleLeaveRoom(socketMock);

    expect(manager.rooms[roomId]).toBeUndefined();
  });

  it('should create, get, and delete room', () => {
    const roomData = { players: [] };
    manager.createRoom('room1', roomData);

    expect(manager.getRoomById('room1')).toEqual(roomData);

    manager.deleteRoom('room1');
    expect(manager.getRoomById('room1')).toBeUndefined();
  });

  it('should emit events to a room', () => {
    const emitMock = jest.fn();
    manager.io = { to: jest.fn(() => ({ emit: emitMock })) };

    manager.emitToRoom('room1', 'testEvent', { data: 123 });
    expect(manager.io.to).toHaveBeenCalledWith('room1');
    expect(emitMock).toHaveBeenCalledWith('testEvent', { data: 123 });
  });

  it('should emit events to a user by UID', () => {
    socketMock.userUid = 'user1';
    const emitMock = jest.fn();
    socketMock.emit = emitMock;
    manager.io = { sockets: { sockets: new Map([['s1', socketMock]]) } };

    manager.emitToUser('user1', 'event', { foo: 'bar' });
    expect(emitMock).toHaveBeenCalledWith('event', { foo: 'bar' });
  });
});
