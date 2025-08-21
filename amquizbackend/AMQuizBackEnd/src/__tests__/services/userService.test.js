const userService = require('../../services/userService');
const userRepository = require('../../repositories/userRepository');
const itemRepository = require('../../repositories/itemRepository');
const missionRepository = require('../../repositories/missionRepository');
const { validateBiography, validateTitle } = require('../../utils/validators');
const { sanitizeInput, compareMaps } = require('../../utils/helpers');
const { INITIAL_MISSIONS } = require('../../utils/constants');

jest.mock('../../repositories/userRepository');
jest.mock('../../repositories/itemRepository');
jest.mock('../../repositories/missionRepository');
jest.mock('../../utils/validators');
jest.mock('../../utils/helpers');

describe('UserService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    sanitizeInput.mockImplementation((x) => x);
    compareMaps.mockReturnValue(false);
    validateBiography.mockReturnValue({ isValid: true });
    validateTitle.mockReturnValue({ isValid: true });
  });

  describe('createUserProfile', () => {
    it('should create user profile with default data', async () => {
      itemRepository.getMultipleItemsById.mockResolvedValue(['item1', 'item2']);
      itemRepository.getItemById.mockResolvedValue('banner');

      await userService.createUserProfile('uid123', 'yoann');

      expect(itemRepository.getMultipleItemsById).toHaveBeenCalled();
      expect(itemRepository.getItemById).toHaveBeenCalled();
      expect(userRepository.createUser).toHaveBeenCalledWith(
        'uid123',
        expect.objectContaining({
          pseudo: 'yoann',
          biographie: 'Je suis nouveau !',
          missions: INITIAL_MISSIONS,
        })
      );
    });
  });

  describe('updateBiography', () => {
    it('should update biography and mission', async () => {
      userRepository.getUserByUid.mockResolvedValue({ biographie: 'old' });

      await userService.updateBiography('uid123', 'new bio');

      expect(userRepository.updateUser).toHaveBeenCalledWith('uid123', { biographie: 'new bio' });
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid123', 'mission10');
    });

    it('should throw if biography invalid', async () => {
      validateBiography.mockReturnValue({ isValid: false, error: 'invalid' });

      await expect(userService.updateBiography('uid', 'bad')).rejects.toThrow('invalid');
    });

    it('should throw if user not found', async () => {
      userRepository.getUserByUid.mockResolvedValue(null);

      await expect(userService.updateBiography('uid', 'bio')).rejects.toThrow('Utilisateur non trouvé');
    });
  });

  describe('updateTitle', () => {
    it('should update title', async () => {
      userRepository.getUserByUid.mockResolvedValue({ titre: 'old' });

      await userService.updateTitle('uid123', 'new title');

      expect(userRepository.updateUser).toHaveBeenCalledWith('uid123', { titre: 'new title' });
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid123', 'mission11');
    });
  });

  describe('updateProfilePicture', () => {
    it('should update picture', async () => {
      userRepository.getUserByUid.mockResolvedValue({ urlImgProfil: 'old.png' });

      await userService.updateProfilePicture('uid', 'new.png');

      expect(userRepository.updateUser).toHaveBeenCalledWith('uid', { urlImgProfil: 'new.png' });
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid', 'mission14');
    });
  });

  describe('updateBanner', () => {
    it('should update banner if different', async () => {
      userRepository.getUserByUid.mockResolvedValue({ banniereProfil: {} });
      compareMaps.mockReturnValue(false);

      await userService.updateBanner('uid', { foo: 'bar' });

      expect(userRepository.updateUser).toHaveBeenCalledWith('uid', { banniereProfil: { foo: 'bar' } });
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid', 'mission15');
    });

    it('should throw if banner identical', async () => {
      userRepository.getUserByUid.mockResolvedValue({ banniereProfil: {} });
      compareMaps.mockReturnValue(true);

      await expect(userService.updateBanner('uid', {})).rejects.toThrow('Aucune modification détectée');
    });
  });

  describe('updatePresence', () => {
    it('should update presence if valid', async () => {
      await userService.updatePresence('uid', true);

      expect(userRepository.updateUser).toHaveBeenCalledWith('uid', { presence: true });
    });

    it('should throw if invalid type', async () => {
      await expect(userService.updatePresence('uid', 'yes')).rejects.toThrow('Statut de présence non valide');
    });
  });

  describe('deleteUser', () => {
    it('should delete user if exists', async () => {
      userRepository.getUserByUid.mockResolvedValue({ uid: 'uid' });

      await userService.deleteUser('uid');

      expect(userRepository.deleteUser).toHaveBeenCalledWith('uid');
    });

    it('should throw if not found', async () => {
      userRepository.getUserByUid.mockResolvedValue(null);

      await expect(userService.deleteUser('uid')).rejects.toThrow('Utilisateur non trouvé');
    });
  });

  describe('loseLife', () => {
    it('should decrement life', async () => {
      userRepository.getUserByUid.mockResolvedValue({ nbVie: 3 });

      await userService.loseLife('uid');

      expect(userRepository.incrementField).toHaveBeenCalledWith('uid', 'nbVie', -1);
    });

    it('should throw if no lives left', async () => {
      userRepository.getUserByUid.mockResolvedValue({ nbVie: 0 });

      await expect(userService.loseLife('uid')).rejects.toThrow('Aucune vie restante');
    });
  });

  describe('updateRecords', () => {
    it('should update record and missions thresholds', async () => {
      userRepository.getUserByUid.mockResolvedValue({ recordsOnePiece: [0, 0, 0] });

      await userService.updateRecords('uid', 'recordsOnePiece', 0, 100);

      expect(userRepository.updateRecords).toHaveBeenCalledWith('uid', 'recordsOnePiece', [100, 0, 0]);
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid', 'mission17');
    });

    it('should throw if invalid type', async () => {
      await expect(userService.updateRecords('uid', 'badType', 0, 10)).rejects.toThrow('Type de record invalide');
    });
  });

  describe('unlockNextLevel', () => {
    it('should unlock next level if locked', async () => {
      userRepository.getUserByUid.mockResolvedValue({ recordsOnePiece: [1, 0] });

      const result = await userService.unlockNextLevel('uid', 'recordsOnePiece', 0);

      expect(result).toBe(true);
      expect(userRepository.updateRecords).toHaveBeenCalled();
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid', 'mission1');
    });

    it('should return false if already unlocked', async () => {
      userRepository.getUserByUid.mockResolvedValue({ recordsOnePiece: [1, 1] });

      const result = await userService.unlockNextLevel('uid', 'recordsOnePiece', 0);

      expect(result).toBe(false);
    });
  });

  describe('simple mission methods', () => {
    it('completeOnlineQuiz calls mission update', async () => {
      await userService.completeOnlineQuiz('uid');
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid', 'mission6');
    });

    it('completeWhoAmI10Points calls mission update', async () => {
      await userService.completeWhoAmI10Points('uid');
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid', 'mission7');
    });

    it('completeWhoAmI15Points calls mission update', async () => {
      await userService.completeWhoAmI15Points('uid');
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledWith('uid', 'mission8');
    });
  });
});
