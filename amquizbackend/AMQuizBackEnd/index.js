// index.js
require('dotenv').config({ path: '.env.local' });
const http = require('http');
const App = require('./src/app');
const socketManager = require('./src/socket/socketManager');
const PORT = process.env.PORT || 3000;

// Initialiser Firebase (fait automatiquement lors de l'import des services)
console.log('🔥 Firebase initialisé');

// Créer le serveur HTTP avec l'application Express
const server = http.createServer(App.getApp());

// Initialiser Socket.IO
socketManager.initialize(server);

// Gestion propre de l'arrêt du serveur
const gracefulShutdown = () => {
  console.log('\n🛑 Arrêt du serveur en cours...');
 
  server.close(() => {
    console.log('✅ Serveur HTTP fermé');
    process.exit(0);
  });
 
  // Forcer l'arrêt après 10 secondes
  setTimeout(() => {
    console.log('⚠️  Arrêt forcé du serveur');
    process.exit(1);
  }, 10000);
};

// Écouter les signaux d'arrêt
process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// Démarrer le serveur
server.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
  console.log(`🌍 Environnement: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📡 Socket.IO initialisé`);
  console.log(`🎯 API disponible sur http://localhost:${PORT}/api`);
  console.log(`❤️  Health check: http://localhost:${PORT}/health`);
});

// Gestion des erreurs du serveur
server.on('error', (error) => {
  if (error.syscall !== 'listen') {
    throw error;
  }

  switch (error.code) {
    case 'EACCES':
      console.error(`❌ Le port ${PORT} nécessite des privilèges élevés`);
      process.exit(1);
      break;
    case 'EADDRINUSE':
      console.error(`❌ Le port ${PORT} est déjà utilisé`);
      process.exit(1);
      break;
    default:
      throw error;
  }
});