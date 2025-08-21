const firebaseConfig = require('../config/firebase');
const { COLLECTION_NAMES } = require('../utils/constants');

class UserRepository {
  constructor() {
    this.db = firebaseConfig.getDb();
    this.collection = this.db.collection(COLLECTION_NAMES.USERS);
  }

  async createUser(uid, userData) {
    return await this.collection.doc(uid).set(userData);
  }

  async getUserByUid(uid) {
    const doc = await this.collection.doc(uid).get();
    return doc.exists ? { id: doc.id, ...doc.data() } : null;
  }

  async getUserByPseudo(pseudo) {
    const snapshot = await this.collection.where('pseudo', '==', pseudo).get();
    return snapshot.empty ? null : { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
  }

  async updateUser(uid, updateData) {
    return await this.collection.doc(uid).update(updateData);
  }

  async deleteUser(uid) {
    return await this.collection.doc(uid).delete();
  }

  async incrementField(uid, field, value = 1) {
    return await this.collection.doc(uid).update({
      [field]: firebaseConfig.getFieldValue().increment(value)
    });
  }

  async setServerTimestamp(uid, field) {
    return await this.collection.doc(uid).update({
      [field]: firebaseConfig.getServerTimestamp()
    });
  }

  async arrayUnion(uid, field, value) {
    return await this.collection.doc(uid).update({
      [field]: firebaseConfig.getFieldValue().arrayUnion(value)
    });
  }

  async arrayRemove(uid, field, value) {
    return await this.collection.doc(uid).update({
      [field]: firebaseConfig.getFieldValue().arrayRemove(value)
    });
  }

  async updateMissions(uid, missions) {
    return await this.collection.doc(uid).update({ missions });
  }

  async updateRecords(uid, recordField, records) {
    return await this.collection.doc(uid).update({
      [recordField]: records
    });
  }

  async updateItemsList(uid, listeItems) {
    return await this.collection.doc(uid).update({ listeItems });
  }

  async checkEmailExists(email) {
    try {
      await firebaseConfig.getAuth().getUserByEmail(email);
      return true;
    } catch (error) {
      return false;
    }
  }

  async createAuthUser(email, password) {
    return await firebaseConfig.getAuth().createUser({
      email: email,
      password: password,
    });
  }

async incrementUserFields(uid, fields) {
  const increments = {};
  
  Object.entries(fields).forEach(([key, value]) => {
    increments[key] = firebaseConfig.getFieldValue().increment(value);
  });
  
  return await this.collection.doc(uid).update(increments);
}
}

module.exports = new UserRepository();