const purchaseService = require('../../services/purchaseService');
const userRepository = require('../../repositories/userRepository');

jest.mock('../../repositories/userRepository');

describe('PurchaseService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getProductReward', () => {
    it('retourne la récompense correspondante au produit', () => {
      expect(purchaseService.getProductReward('ames1')).toEqual({ nbAmes: 100 });
      expect(purchaseService.getProductReward('ames2')).toEqual({ nbAmes: 500 });
      expect(purchaseService.getProductReward('ames3')).toEqual({ nbAmes: 1200 });
      expect(purchaseService.getProductReward('inconnu')).toEqual({ nbAmes: 0 });
    });
  });

  describe('grantReward', () => {
    it('accorde des âmes si reward contient nbAmes', async () => {
      userRepository.incrementField.mockResolvedValueOnce(true);

      await purchaseService.grantReward('uid1', { nbAmes: 100 });
      expect(userRepository.incrementField).toHaveBeenCalledWith('uid1', 'nbAmes', 100);
    });

    it('accorde plusieurs types de récompenses', async () => {
      userRepository.incrementField.mockResolvedValue(true);

      const reward = { nbAmes: 50, nbCoffre: 2, nbLettre: 1 };
      await purchaseService.grantReward('uid1', reward);

      expect(userRepository.incrementField).toHaveBeenCalledWith('uid1', 'nbAmes', 50);
      expect(userRepository.incrementField).toHaveBeenCalledWith('uid1', 'nbCoffre', 2);
      expect(userRepository.incrementField).toHaveBeenCalledWith('uid1', 'nbLettre', 1);
    });

    it('lève une erreur si userRepository échoue', async () => {
      userRepository.incrementField.mockRejectedValueOnce(new Error('DB Error'));

      await expect(purchaseService.grantReward('uid1', { nbAmes: 100 }))
        .rejects.toThrow('Erreur lors de l\'attribution de la récompense: DB Error');
    });
  });

  describe('validateGooglePlayReceipt', () => {
    it('valide et accorde la récompense', async () => {
      jest.spyOn(purchaseService, 'grantReward').mockResolvedValueOnce(true);

      const res = await purchaseService.validateGooglePlayReceipt('uid1', 'receipt123', 'ames2');
      expect(res).toEqual({
        productId: 'ames2',
        reward: { nbAmes: 500 },
        validated: true
      });
      expect(purchaseService.grantReward).toHaveBeenCalledWith('uid1', { nbAmes: 500 });
    });

    it('lève une erreur si grantReward échoue', async () => {
      jest.spyOn(purchaseService, 'grantReward').mockRejectedValueOnce(new Error('DB Error'));

      await expect(
        purchaseService.validateGooglePlayReceipt('uid1', 'receipt123', 'ames2')
      ).rejects.toThrow('Erreur lors de la validation Google Play: DB Error');
    });
  });

  describe('validateTransaction', () => {
    it('valide et accorde la récompense selon la plateforme', async () => {
      jest.spyOn(purchaseService, 'grantReward').mockResolvedValueOnce(true);

      const res = await purchaseService.validateTransaction('uid1', 'tx123', 'ames3', 'ios');
      expect(res).toEqual({
        productId: 'ames3',
        platform: 'ios',
        reward: { nbAmes: 1200 },
        validated: true
      });
      expect(purchaseService.grantReward).toHaveBeenCalledWith('uid1', { nbAmes: 1200 });
    });

    it('lève une erreur si grantReward échoue', async () => {
      jest.spyOn(purchaseService, 'grantReward').mockRejectedValueOnce(new Error('DB Error'));

      await expect(
        purchaseService.validateTransaction('uid1', 'tx123', 'ames3', 'android')
      ).rejects.toThrow('Erreur lors de la validation transaction: DB Error');
    });
  });
});
