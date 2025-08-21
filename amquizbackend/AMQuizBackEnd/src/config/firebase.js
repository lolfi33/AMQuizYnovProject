const admin = require('firebase-admin');
const serviceAccount = require('../../config/serviceAccountKey.json');

class FirebaseConfig {
  constructor() {
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }
    this.db = admin.firestore();
    this.auth = admin.auth();
  }

  getDb() {
    return this.db;
  }

  getAuth() {
    return this.auth;
  }

  getFieldValue() {
    return admin.firestore.FieldValue;
  }

  getServerTimestamp() {
    return admin.firestore.FieldValue.serverTimestamp();
  }
}

module.exports = new FirebaseConfig();