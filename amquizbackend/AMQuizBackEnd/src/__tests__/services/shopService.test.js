const shopService = require('../../services/shopService');
const userRepository = require('../../repositories/userRepository');
const itemRepository = require('../../repositories/itemRepository');
const missionRepository = require('../../repositories/missionRepository');
const helpers = require('../../utils/helpers');
const constants = require('../../utils/constants');

jest.mock('../../repositories/userRepository');
jest.mock('../../repositories/itemRepository');
jest.mock('../../repositories/missionRepository');

jest.mock('../../utils/helpers', () => ({
  determineRarity: jest.fn(),
  getRandomItem: jest.fn(),
  calculateSellValue: jest.fn(),
}));

describe('ShopService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.useFakeTimers();
    constants.ITEM_PRICES = {
      'profil bronze': 100,
      '5 vies': 50,
    };
    constants.CHEST_PROBABILITIES = {
      commun: { commun: 100 },
      rare: { rare: 100 },
      legendaire: { legendaire: 100 },
    };
  });

  describe('buyItem', () => {
    it('doit lancer une erreur si item invalide', async () => {
      await expect(shopService.buyItem('uid1', 'fakeItem'))
        .rejects.toThrow('Item invalide');
    });

    it('doit lancer une erreur si utilisateur introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValue(null);
      await expect(shopService.buyItem('uid1', 'profil bronze'))
        .rejects.toThrow('Utilisateur non trouvé');
    });

    it('doit lancer une erreur si pas assez d’âmes', async () => {
      userRepository.getUserByUid.mockResolvedValue({ nbAmes: 50 });
      await expect(shopService.buyItem('uid1', 'profil bronze'))
        .rejects.toThrow('Pas assez d\'âmes');
    });

    it('doit réussir un achat', async () => {
      userRepository.getUserByUid.mockResolvedValue({ nbAmes: 200 });
      userRepository.incrementField.mockResolvedValue();
      missionRepository.updateMissionProgress.mockResolvedValue();

      const result = await shopService.buyItem('uid1', 'profil bronze');

      expect(userRepository.incrementField).toHaveBeenCalledWith('uid1', 'nbAmes', -100);
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid1', 'mission16');
      expect(result).toBe('Achat de profil bronze réussi');
    });
  });

  describe('openChest', () => {
    it('doit lancer une erreur si type de coffre invalide', async () => {
      await expect(shopService.openChest('uid1', 'fake'))
        .rejects.toThrow('Type de coffre invalide');
    });

    it('doit lancer une erreur si utilisateur introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValue(null);
      await expect(shopService.openChest('uid1', 'commun'))
        .rejects.toThrow('Utilisateur non trouvé');
    });

    it('doit lancer une erreur si aucun coffre dispo', async () => {
      userRepository.getUserByUid.mockResolvedValue({ nbCoffreCommun: 0 });
      await expect(shopService.openChest('uid1', 'commun'))
        .rejects.toThrow('Aucun coffre disponible');
    });

    it('doit ouvrir un coffre et retourner un item', async () => {
      userRepository.getUserByUid.mockResolvedValue({ nbCoffreCommun: 1, listeItems: [] });
      helpers.determineRarity.mockReturnValue('commun');
      itemRepository.getItemsByRarityAndType.mockResolvedValue([{ name: 'item1' }]);
      helpers.getRandomItem.mockReturnValue({ name: 'item1' });
      userRepository.updateItemsList.mockResolvedValue();

      const result = await shopService.openChest('uid1', 'commun');

      expect(itemRepository.getItemsByRarityAndType).toHaveBeenCalledWith('commun', 'profil');
      expect(userRepository.updateItemsList).toHaveBeenCalled();
      expect(result).toEqual({ name: 'item1' });

      // Vérif du décrément async
      jest.runAllTimers();
      expect(userRepository.incrementField).toHaveBeenCalledWith('uid1', 'nbCoffreCommun', -1);
    });
  });

  describe('openEnvelope', () => {
    it('doit lancer une erreur si type invalide', async () => {
      await expect(shopService.openEnvelope('uid1', 'fake'))
        .rejects.toThrow('Type d\'enveloppe invalide');
    });

    it('doit ouvrir une enveloppe et retourner un item', async () => {
      userRepository.getUserByUid.mockResolvedValue({ nbLettreRare: 1, listeItems: [] });
      helpers.determineRarity.mockReturnValue('rare');
      itemRepository.getItemsByRarityAndType.mockResolvedValue([{ name: 'banner1' }]);
      helpers.getRandomItem.mockReturnValue({ name: 'banner1' });
      userRepository.updateItemsList.mockResolvedValue();

      const result = await shopService.openEnvelope('uid1', 'rare');
      expect(itemRepository.getItemsByRarityAndType).toHaveBeenCalledWith('rare', 'banniere');
      expect(result).toEqual({ name: 'banner1' });
    });
  });

  describe('addItemToInventory', () => {
    it('ajoute un item s’il n’existe pas', async () => {
      userRepository.getUserByUid.mockResolvedValue({ listeItems: [] });
      userRepository.updateItemsList.mockResolvedValue();

      await shopService.addItemToInventory('uid1', { name: 'item1' });
      expect(userRepository.updateItemsList).toHaveBeenCalledWith('uid1', [{ name: 'item1', number: 1 }]);
    });

    it('incrémente un item existant', async () => {
      userRepository.getUserByUid.mockResolvedValue({ listeItems: [{ name: 'item1', number: 1 }] });
      userRepository.updateItemsList.mockResolvedValue();

      await shopService.addItemToInventory('uid1', { name: 'item1' });
      expect(userRepository.updateItemsList).toHaveBeenCalledWith('uid1', [{ name: 'item1', number: 2 }]);
    });
  });

  describe('sellItem', () => {
    it('doit lancer une erreur si utilisateur introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValue(null);
      await expect(shopService.sellItem('uid1', 'item1', 'profil'))
        .rejects.toThrow('Utilisateur non trouvé');
    });

    it('doit lancer une erreur si item introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValue({ listeItems: [] });
      await expect(shopService.sellItem('uid1', 'item1', 'profil'))
        .rejects.toThrow('Item non trouvé');
    });

    it('doit lancer une erreur si sellValue = 0', async () => {
      userRepository.getUserByUid.mockResolvedValue({ listeItems: [{ name: 'item1', number: 1 }] });
      helpers.calculateSellValue.mockReturnValue(0);

      await expect(shopService.sellItem('uid1', 'item1', 'profil'))
        .rejects.toThrow('Impossible de vendre cet item');
    });

    it('doit vendre un item et incrémenter les âmes', async () => {
      userRepository.getUserByUid.mockResolvedValue({ listeItems: [{ name: 'item1', number: 1 }] });
      helpers.calculateSellValue.mockReturnValue(20);
      userRepository.updateItemsList.mockResolvedValue();
      userRepository.incrementField.mockResolvedValue();
      missionRepository.updateMissionProgress.mockResolvedValue();

      const result = await shopService.sellItem('uid1', 'item1', 'profil');

      expect(userRepository.updateItemsList).toHaveBeenCalledWith('uid1', []);
      expect(userRepository.incrementField).toHaveBeenCalledWith('uid1', 'nbAmes', 20);
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid1', 'mission9');
      expect(result).toBe(20);
    });
  });
});
