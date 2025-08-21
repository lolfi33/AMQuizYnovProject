const missionService = require('../../services/missionService');
const missionRepository = require('../../repositories/missionRepository');
const userRepository = require('../../repositories/userRepository');

jest.mock('../../repositories/missionRepository');
jest.mock('../../repositories/userRepository');

describe('MissionService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getUserMissions', () => {
    it('retourne les missions de l’utilisateur', async () => {
      const missions = { mission1: { name: 'Test', progress: 1 } };
      missionRepository.getUserMissions.mockResolvedValueOnce(missions);

      const res = await missionService.getUserMissions('uid1');
      expect(res).toEqual(missions);
    });
  });

  describe('updateMissionProgress', () => {
    it('met à jour correctement la mission', async () => {
      missionRepository.updateMissionProgress.mockResolvedValueOnce(true);

      const res = await missionService.updateMissionProgress('uid1', 'mission1', 2);
      expect(res).toBe(true);
    });

    it('log si mission non trouvée ou déjà complétée', async () => {
      missionRepository.updateMissionProgress.mockResolvedValueOnce(false);
      console.log = jest.fn();

      const res = await missionService.updateMissionProgress('uid1', 'mission1', 2);
      expect(res).toBe(false);
      expect(console.log).toHaveBeenCalledWith(
        'Mission mission1 non trouvée ou déjà complétée pour l\'utilisateur uid1'
      );
    });
  });

  describe('incrementMissionProgress', () => {
    it('incrémente la progression de la mission', async () => {
      missionRepository.incrementMissionProgress.mockResolvedValueOnce(true);

      const res = await missionService.incrementMissionProgress('uid1', 'mission1', 3);
      expect(res).toBe(true);
      expect(missionRepository.incrementMissionProgress).toHaveBeenCalledWith('uid1', 'mission1', 3);
    });
  });

  describe('claimMissionReward', () => {
    it('lève une erreur si mission non complétée', async () => {
      missionRepository.isMissionCompleted.mockResolvedValueOnce(false);
      await expect(missionService.claimMissionReward('uid1', 'mission1'))
        .rejects.toThrow('Mission non complétée');
    });

    it('réclame la récompense correctement', async () => {
      missionRepository.isMissionCompleted.mockResolvedValueOnce(true);
      missionRepository.completeMission.mockResolvedValueOnce(['recompense1']);

      const res = await missionService.claimMissionReward('uid1', 'mission1');
      expect(res).toEqual({
        message: 'Récompense réclamée avec succès',
        recompenses: ['recompense1']
      });
    });
  });

  describe('getCompletedMissions', () => {
    it('retourne les missions complétées', async () => {
      missionRepository.getCompletedMissions.mockResolvedValueOnce(['mission1']);
      const res = await missionService.getCompletedMissions('uid1');
      expect(res).toEqual(['mission1']);
    });
  });

  describe('getMissionProgress', () => {
    it('lève une erreur si mission non trouvée', async () => {
      missionRepository.getUserMissions.mockResolvedValueOnce({});
      await expect(missionService.getMissionProgress('uid1', 'mission1'))
        .rejects.toThrow('Mission non trouvée');
    });

    it('retourne l’état de la mission', async () => {
      const missions = {
        mission1: { name: 'Test', progress: 2, total: 5, nbRecompenses: 1 }
      };
      missionRepository.getUserMissions.mockResolvedValueOnce(missions);

      const res = await missionService.getMissionProgress('uid1', 'mission1');
      expect(res).toEqual({
        name: 'Test',
        progress: 2,
        total: 5,
        completed: false,
        recompenses: 1
      });
    });
  });

  describe('resetMission', () => {
    it('lève une erreur si mission non réinitialisable', async () => {
      missionRepository.resetMission.mockResolvedValueOnce(false);
      await expect(missionService.resetMission('uid1', 'mission1'))
        .rejects.toThrow('Mission non trouvée ou impossible à réinitialiser');
    });

    it('réinitialise la mission correctement', async () => {
      missionRepository.resetMission.mockResolvedValueOnce(true);
      const res = await missionService.resetMission('uid1', 'mission1');
      expect(res).toBe('Mission réinitialisée avec succès');
    });
  });

  describe('checkAllMissionsProgress', () => {
    it('retourne le progrès complet des missions', async () => {
      const missions = {
        mission1: { name: 'Test', progress: 2, total: 5, nbRecompenses: 1 },
        mission2: { name: 'Test2', progress: 5, total: 5 }
      };
      missionRepository.getUserMissions.mockResolvedValueOnce(missions);

      const res = await missionService.checkAllMissionsProgress('uid1');
      expect(res.mission1).toEqual({
        name: 'Test',
        progress: 2,
        total: 5,
        completed: false,
        percentage: 40,
        recompenses: 1
      });
      expect(res.mission2).toEqual({
        name: 'Test2',
        progress: 5,
        total: 5,
        completed: true,
        percentage: 100,
        recompenses: 0
      });
    });
  });

  describe('getAvailableRewards', () => {
    it('retourne uniquement les missions complétées', async () => {
      const missions = {
        mission1: { name: 'Test', progress: 5, total: 5, nbRecompenses: 2 },
        mission2: { name: 'Test2', progress: 3, total: 5 }
      };
      missionRepository.getUserMissions.mockResolvedValueOnce(missions);

      const res = await missionService.getAvailableRewards('uid1');
      expect(res).toEqual({
        mission1: { name: 'Test', recompenses: 2 }
      });
    });
  });

  describe('updateAdventureMission', () => {
    it('met à jour la mission correspondant à l’aventure', async () => {
      jest.spyOn(missionService, 'updateMissionProgress').mockResolvedValueOnce(true);
      await missionService.updateAdventureMission('uid1', 'onepiece');
      expect(missionService.updateMissionProgress).toHaveBeenCalledWith('uid1', 'mission1');
    });
  });

  describe('updateScoreMission', () => {
    it('met à jour les missions "whoami" selon le score', async () => {
      jest.spyOn(missionService, 'updateMissionProgress').mockResolvedValue();

      await missionService.updateScoreMission('uid1', 12, 'whoami');
      expect(missionService.updateMissionProgress).toHaveBeenCalledWith('uid1', 'mission7');

      await missionService.updateScoreMission('uid1', 16, 'whoami');
      expect(missionService.updateMissionProgress).toHaveBeenCalledWith('uid1', 'mission8');
    });
  });

  describe('updateStarMission', () => {
    it('incrémente la mission correspondant aux étoiles', async () => {
      jest.spyOn(missionService, 'incrementMissionProgress').mockResolvedValueOnce(true);

      await missionService.updateStarMission('uid1', 3, 'onepiece');
      expect(missionService.incrementMissionProgress).toHaveBeenCalledWith('uid1', 'mission17', 3);
    });

    it('ne fait rien si stars = 0', async () => {
      jest.spyOn(missionService, 'incrementMissionProgress');
      await missionService.updateStarMission('uid1', 0, 'onepiece');
      expect(missionService.incrementMissionProgress).not.toHaveBeenCalled();
    });
  });
});
