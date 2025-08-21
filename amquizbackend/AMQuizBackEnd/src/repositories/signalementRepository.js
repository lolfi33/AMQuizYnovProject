const firebaseConfig = require('../config/firebase');
const { COLLECTION_NAMES } = require('../utils/constants');

class SignalementRepository {
  constructor() {
    this.db = firebaseConfig.getDb();
    this.collection = this.db.collection(COLLECTION_NAMES.SIGNALEMENTS);
  }

  async createSignalement(signalementData) {
    return await this.collection.add({
      ...signalementData,
      date: firebaseConfig.getServerTimestamp()
    });
  }

  async getSignalementsByUser(uidJoueurQuiAEteSignale) {
    const snapshot = await this.collection
      .where('uidJoueurQuiAEteSignale', '==', uidJoueurQuiAEteSignale)
      .get();
    
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  async getAllSignalements() {
    const snapshot = await this.collection.orderBy('date', 'desc').get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  async deleteSignalement(signalementId) {
    return await this.collection.doc(signalementId).delete();
  }

  async getSignalementsByReporter(uidJoueur) {
    const snapshot = await this.collection
      .where('uidJoueur', '==', uidJoueur)
      .get();
    
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }
}

module.exports = new SignalementRepository();