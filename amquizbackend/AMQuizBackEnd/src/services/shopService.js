// src/services/shopService.js
const userRepository = require('../repositories/userRepository');
const itemRepository = require('../repositories/itemRepository');
const missionRepository = require('../repositories/missionRepository');
const { ITEM_PRICES, CHEST_PROBABILITIES } = require('../utils/constants');
const { determineRarity, getRandomItem, calculateSellValue } = require('../utils/helpers');

class ShopService {
  async buyItem(uid, itemName) {
    if (!ITEM_PRICES.hasOwnProperty(itemName)) {
      throw new Error('Item invalide');
    }

    const price = ITEM_PRICES[itemName];
    const user = await userRepository.getUserByUid(uid);
    
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    if (user.nbAmes < price) {
      throw new Error('Pas assez d\'âmes');
    }

    // Déduire le prix
    await userRepository.incrementField(uid, 'nbAmes', -price);

    // Ajouter l'item selon le type
    await this.addPurchasedItem(uid, itemName);

    // Mettre à jour la mission d'achat
    await missionRepository.updateMissionProgress(uid, 'mission16');

    return `Achat de ${itemName} réussi`;
  }

  async addPurchasedItem(uid, itemName) {
    const itemActions = {
      'profil bronze': () => userRepository.incrementField(uid, 'nbCoffreCommun'),
      'profil argent': () => userRepository.incrementField(uid, 'nbCoffreRare'),
      'profil or': () => userRepository.incrementField(uid, 'nbCoffreLegendaire'),
      'banniere bronze': () => userRepository.incrementField(uid, 'nbLettreCommun'),
      'banniere argent': () => userRepository.incrementField(uid, 'nbLettreRare'),
      'banniere or': () => userRepository.incrementField(uid, 'nbLettreLegendaire'),
      '5 vies': () => userRepository.incrementField(uid, 'nbVie', 5),
      '20 vies': () => userRepository.incrementField(uid, 'nbVie', 20),
      '50 vies': () => userRepository.incrementField(uid, 'nbVie', 50),
    };

    const action = itemActions[itemName];
    if (action) {
      await action();
    }
  }

  async openChest(uid, chestType) {
    const validChestTypes = ['commun', 'rare', 'legendaire'];
    if (!validChestTypes.includes(chestType)) {
      throw new Error('Type de coffre invalide');
    }

    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    const chestField = `nbCoffre${chestType.charAt(0).toUpperCase() + chestType.slice(1)}`;
    const chestCount = user[chestField] || 0;

    if (chestCount <= 0) {
      throw new Error('Aucun coffre disponible');
    }

    // Déterminer la rareté de l'item
    const probabilities = CHEST_PROBABILITIES[chestType];
    const roll = Math.random() * 100;
    const rarity = determineRarity(roll, probabilities);

    // Récupérer un item aléatoire de cette rareté (profil)
    const items = await itemRepository.getItemsByRarityAndType(rarity, 'profil');
    if (items.length === 0) {
      throw new Error('Aucun item disponible pour cette rareté');
    }

    const selectedItem = getRandomItem(items);

    // Mettre à jour l'inventaire de l'utilisateur
    await this.addItemToInventory(uid, selectedItem);

    // Décrémenter le nombre de coffres (avec délai pour l'UX)
    setTimeout(async () => {
      await userRepository.incrementField(uid, chestField, -1);
    }, 2000);

    return selectedItem;
  }

  async openEnvelope(uid, chestType) {
    const validChestTypes = ['commun', 'rare', 'legendaire'];
    if (!validChestTypes.includes(chestType)) {
      throw new Error('Type d\'enveloppe invalide');
    }

    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    const envelopeField = `nbLettre${chestType.charAt(0).toUpperCase() + chestType.slice(1)}`;
    const envelopeCount = user[envelopeField] || 0;

    if (envelopeCount <= 0) {
      throw new Error('Aucune enveloppe disponible');
    }

    // Déterminer la rareté de l'item
    const probabilities = CHEST_PROBABILITIES[chestType];
    const roll = Math.random() * 100;
    const rarity = determineRarity(roll, probabilities);

    // Récupérer un item aléatoire de cette rareté (bannière)
    const items = await itemRepository.getItemsByRarityAndType(rarity, 'banniere');
    if (items.length === 0) {
      throw new Error('Aucun item disponible pour cette rareté');
    }

    const selectedItem = getRandomItem(items);

    // Mettre à jour l'inventaire de l'utilisateur
    await this.addItemToInventory(uid, selectedItem);

    // Décrémenter le nombre d'enveloppes (avec délai pour l'UX)
    setTimeout(async () => {
      await userRepository.incrementField(uid, envelopeField, -1);
    }, 2000);

    return selectedItem;
  }

  async addItemToInventory(uid, item) {
    const user = await userRepository.getUserByUid(uid);
    const listeItems = user.listeItems || [];

    // Chercher si l'item existe déjà
    const existingItemIndex = listeItems.findIndex(existingItem => 
      existingItem.name === item.name
    );

    if (existingItemIndex > -1) {
      // Incrémenter la quantité
      listeItems[existingItemIndex].number = (listeItems[existingItemIndex].number || 1) + 1;
    } else {
      // Ajouter un nouvel item avec quantité 1
      listeItems.push({ ...item, number: 1 });
    }

    await userRepository.updateItemsList(uid, listeItems);
  }

  async sellItem(uid, itemId, itemType) {
    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    const listeItems = user.listeItems || [];
    const itemIndex = listeItems.findIndex(item => item.name === itemId);

    if (itemIndex === -1) {
      throw new Error('Item non trouvé');
    }

    const item = listeItems[itemIndex];
    const sellValue = calculateSellValue(item, itemType);

    if (sellValue === 0) {
      throw new Error('Impossible de vendre cet item');
    }

    // Mettre à jour la quantité ou supprimer l'item
    if (item.number > 1) {
      listeItems[itemIndex].number -= 1;
    } else {
      listeItems.splice(itemIndex, 1);
    }

    // Mettre à jour l'inventaire et les âmes
    await userRepository.updateItemsList(uid, listeItems);
    await userRepository.incrementField(uid, 'nbAmes', sellValue);

    // Mettre à jour la mission de vente
    await missionRepository.updateMissionProgress(uid, 'mission9');

    return sellValue;
  }

  getPrices() {
    return ITEM_PRICES;
  }
}

module.exports = new ShopService();