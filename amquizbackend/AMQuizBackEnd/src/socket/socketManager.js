// src/socket/socketManager.js
const socketIo = require('socket.io');
const gameSocketHandlers = require('./gameSocketHandlers');
const challengeSocketHandlers = require('./challengeSocketHandlers');

class SocketManager {
  constructor() {
    this.io = null;
    this.rooms = {}; // Gestion des salles et des joueurs
  }

  initialize(server) {
    this.io = socketIo(server, {
      cors: {
        origin: "*", // À restreindre en production
        methods: ["GET", "POST"]
      },
      transports: ['websocket', 'polling']
    });

    this.setupConnectionHandlers();
    console.log('Socket.IO initialisé');
  }

  setupConnectionHandlers() {
    this.io.on('connection', (socket) => {
      console.log(`Utilisateur connecté : ${socket.id}`);

      // Authentification du socket
      this.handleAuthentication(socket);

      // Gestionnaires de jeu
      gameSocketHandlers.handleGameEvents(socket, this.io, this.rooms);

      // Gestionnaires de défis
      challengeSocketHandlers.handleChallengeEvents(socket, this.io, this.rooms);

      // Déconnexion
      this.handleDisconnection(socket);
    });
  }

  handleAuthentication(socket) {
    socket.on('authenticate', (uid) => {
      // Déconnecter les anciennes sessions du même utilisateur
      Array.from(this.io.sockets.sockets.values()).forEach((s) => {
        if (s.userUid === uid && s.id !== socket.id) {
          console.log(`Déconnexion de l'ancien socket ${s.id} pour UID ${uid}`);
          s.disconnect();
        }
      });

      socket.userUid = uid;
      console.log(`Utilisateur authentifié : UID=${uid}, Socket ID=${socket.id}`);
    });
  }

  handleDisconnection(socket) {
    socket.on('disconnect', () => {
      console.log(`Socket déconnecté : ${socket.id}`);

      // Nettoyer les salles où le joueur était présent
      Object.keys(this.rooms).forEach((roomId) => {
        const room = this.rooms[roomId];
        if (room && room.players) {
          const playerIndex = room.players.findIndex(
            (player) => player.id === socket.id
          );

          if (playerIndex !== -1) {
            room.players.splice(playerIndex, 1);
            console.log(`Joueur ${socket.id} retiré de la salle ${roomId}`);

            // Si la salle devient vide ou n'a plus assez de joueurs
            if (room.players.length === 0) {
              delete this.rooms[roomId];
              console.log(`Salle ${roomId} supprimée car vide`);
            } else if (room.players.length < 2) {
              // Notifier les joueurs restants
              this.io.to(roomId).emit('playerLeft');
              this.io.to(roomId).emit('playerLeft2');
              delete this.rooms[roomId];
              console.log(`Salle ${roomId} supprimée car moins de 2 joueurs`);
            }
          }
        }
      });
    });

    socket.on('leaveRoom', () => {
      this.handleLeaveRoom(socket);
    });
  }

  handleLeaveRoom(socket) {
    Object.keys(this.rooms).forEach((roomId) => {
      const room = this.rooms[roomId];
      if (room && room.players) {
        const playerIndex = room.players.findIndex(
          (player) => player.id === socket.id
        );

        if (playerIndex !== -1) {
          room.players.splice(playerIndex, 1);
          console.log(`Joueur ${socket.id} a quitté la salle ${roomId}`);

          if (room.players.length === 0) {
            delete this.rooms[roomId];
            console.log(`Salle ${roomId} supprimée car vide`);
          } else {
            this.io.to(roomId).emit('roomUpdate', { roomId, ...room });
          }
        }
      }
    });
  }

  // Méthodes utilitaires
  getRoomById(roomId) {
    return this.rooms[roomId];
  }

  createRoom(roomId, roomData) {
    this.rooms[roomId] = roomData;
    return this.rooms[roomId];
  }

  deleteRoom(roomId) {
    delete this.rooms[roomId];
  }

  getSocketByUid(uid) {
    return Array.from(this.io.sockets.sockets.values()).find(
      (socket) => socket.userUid === uid
    );
  }

  emitToRoom(roomId, event, data) {
    this.io.to(roomId).emit(event, data);
  }

  emitToUser(uid, event, data) {
    const socket = this.getSocketByUid(uid);
    if (socket) {
      socket.emit(event, data);
    }
  }

  getIO() {
    return this.io;
  }

  getRooms() {
    return this.rooms;
  }
}

module.exports = new SocketManager();