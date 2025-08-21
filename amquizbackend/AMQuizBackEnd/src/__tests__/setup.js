// src/__tests__/setup.js
const admin = require('firebase-admin');

// Mock Firebase Admin
jest.mock('firebase-admin', () => ({
  apps: [],
  initializeApp: jest.fn(),
  auth: jest.fn(() => ({
    verifyIdToken: jest.fn()
  })),
  firestore: jest.fn(() => ({
    collection: jest.fn(() => ({
      doc: jest.fn(() => ({
        get: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
        set: jest.fn()
      })),
      where: jest.fn(),
      orderBy: jest.fn(),
      limit: jest.fn(),
      get: jest.fn()
    }))
  })),
  FieldValue: {
    increment: jest.fn((value) => ({ increment: value })),
    delete: jest.fn(() => ({ delete: true })),
    arrayUnion: jest.fn((value) => ({ arrayUnion: value })),
    arrayRemove: jest.fn((value) => ({ arrayRemove: value }))
  },
  credential: {
    cert: jest.fn() 
  }
}));


// Configuration globale pour les tests
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn()
};

afterEach(() => {
  jest.clearAllMocks();
});

beforeEach(() => {
  jest.clearAllMocks();
});