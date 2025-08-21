const firebaseConfig = require('../config/firebase');
const { COLLECTION_NAMES } = require('../utils/constants');

class ItemRepository {
  constructor() {
    this.db = firebaseConfig.getDb();
    this.collection = this.db.collection(COLLECTION_NAMES.ITEMS);
  }

  async getItemById(itemId) {
    const doc = await this.collection.doc(itemId).get();
    return doc.exists ? doc.data() : null;
  }

  async getItemsByFilter(filters) {
    let query = this.collection;
    
    Object.entries(filters).forEach(([key, value]) => {
      query = query.where(key, '==', value);
    });

    const snapshot = await query.get();
    return snapshot.docs.map(doc => doc.data());
  }

  async getItemsByRarityAndType(rarity, type) {
    const snapshot = await this.collection
      .where('rarity', '==', rarity)
      .where('type', '==', type)
      .get();
    
    return snapshot.docs.map(doc => doc.data());
  }

  async getAllItems() {
    const snapshot = await this.collection.get();
    return snapshot.docs.map(doc => doc.data());
  }

  async getItemsByOeuvreAndType(oeuvre, type) {
    const snapshot = await this.collection
      .where('oeuvre', '==', oeuvre)
      .where('type', '==', type)
      .get();
    
    return snapshot.docs.map(doc => doc.data());
  }

  async getMultipleItemsById(itemIds) {
    const items = [];
    for (const itemId of itemIds) {
      const item = await this.getItemById(itemId);
      if (item) {
        items.push(item);
      }
    }
    return items;
  }
}

module.exports = new ItemRepository();