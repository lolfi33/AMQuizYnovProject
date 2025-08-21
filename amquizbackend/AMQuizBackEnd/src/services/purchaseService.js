// src/services/purchaseService.js
const userRepository = require('../repositories/userRepository');

class PurchaseService {
  async validateGooglePlayReceipt(uid, receiptData, productId) {
    try {
      // TODO: Intégrer la validation réelle avec Google Play API
      // Pour l'instant, simulation d'une validation réussie
      console.log('Validation Google Play Receipt:', {
        uid,
        productId,
        receiptLength: receiptData.length
      });

      // Déterminer la récompense selon le produit
      const reward = this.getProductReward(productId);
      
      // Mettre à jour le compte utilisateur
      await this.grantReward(uid, reward);

      return {
        productId,
        reward,
        validated: true
      };
    } catch (error) {
      throw new Error(`Erreur lors de la validation Google Play: ${error.message}`);
    }
  }

  async validateTransaction(uid, transactionId, productId, platform) {
    try {
      console.log('Validation Transaction:', {
        uid,
        transactionId,
        productId,
        platform
      });

      // Déterminer la récompense selon le produit
      const reward = this.getProductReward(productId);
      
      // Mettre à jour le compte utilisateur
      await this.grantReward(uid, reward);

      return {
        productId,
        platform,
        reward,
        validated: true
      };
    } catch (error) {
      throw new Error(`Erreur lors de la validation transaction: ${error.message}`);
    }
  }

  getProductReward(productId) {
    const products = {
    'ames1': { nbAmes: 100 }, 
    'ames2': { nbAmes: 500 },  
    'ames3': { nbAmes: 1200 }, 
    };

    return products[productId] || { nbAmes: 0 };
  }


async grantReward(uid, reward) {
  try {
    if (reward.nbAmes) {
      await userRepository.incrementField(uid, 'nbAmes', reward.nbAmes);
    }
    
    if (reward.nbCoffre) {
      await userRepository.incrementField(uid, 'nbCoffre', reward.nbCoffre);
    }
    
    if (reward.nbLettre) {
      await userRepository.incrementField(uid, 'nbLettre', reward.nbLettre);
    }
    
    console.log(`Récompense accordée à ${uid}:`, reward);
  } catch (error) {
    throw new Error(`Erreur lors de l'attribution de la récompense: ${error.message}`);
  }
}
}

module.exports = new PurchaseService();