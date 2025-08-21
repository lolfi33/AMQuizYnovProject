const missionController = require('../../controllers/missionController');
const missionService = require('../../services/missionService');
const authService = require('../../services/authService');

jest.mock('../../services/missionService');
jest.mock('../../services/authService');

describe('MissionController', () => {
  let req, res;

  beforeEach(() => {
    req = { body: {}, params: {}, headers: {} };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    jest.clearAllMocks();
  });

  describe('getUserMissions', () => {
    it('should return 200 with missions', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      missionService.getUserMissions.mockResolvedValue(['mission1', 'mission2']);

      await missionController.getUserMissions(req, res);

      expect(missionService.getUserMissions).toHaveBeenCalledWith('uidUser');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(['mission1', 'mission2']);
    });

    it('should return 400 if service throws', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      missionService.getUserMissions.mockRejectedValue(new Error('Erreur'));

      await missionController.getUserMissions(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Erreur' });
    });
  });

  describe('getMissionProgress', () => {
    it('should return 400 if missionKey is missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');

      await missionController.getMissionProgress(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Clé de mission requise' });
    });

    it('should return 200 with progress', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.params.missionKey = 'mission1';
      missionService.getMissionProgress.mockResolvedValue({ progress: 3 });

      await missionController.getMissionProgress(req, res);

      expect(missionService.getMissionProgress).toHaveBeenCalledWith('uidUser','mission1');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ progress: 3 });
    });
  });

  describe('claimReward', () => {
    it('should return 400 if missionKey missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');

      await missionController.claimReward(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Clé de mission requise' });
    });

    it('should call claimMissionReward and return 200', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.body.missionKey = 'mission1';
      missionService.claimMissionReward.mockResolvedValue({ reward: 100 });

      await missionController.claimReward(req, res);

      expect(missionService.claimMissionReward).toHaveBeenCalledWith('uidUser','mission1');
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ reward: 100 });
    });
  });

  describe('updateMissionProgress', () => {
    it('should return 400 if missionKey missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      await missionController.updateMissionProgress(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Clé de mission requise' });
    });

    it('should return success true if updated', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.body = { missionKey:'mission1', progress:1 };
      missionService.updateMissionProgress.mockResolvedValue(true);

      await missionController.updateMissionProgress(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: true, message:'Progression de mission mise à jour' });
    });

    it('should return success false if not updated', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.body = { missionKey:'mission1', progress:1 };
      missionService.updateMissionProgress.mockResolvedValue(false);

      await missionController.updateMissionProgress(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({ success: false, message:'Mission non trouvée ou déjà complétée' });
    });
  });

  // Tests génériques pour toutes les méthodes "updateMissionX" sans paramètre obligatoire
  const simpleUpdates = [
    ['updateQuizOnlineProgress','mission6','Mission quiz en ligne mise à jour'],
    ['updateQuiSuisJe10Points','mission7','Mission "Qui suis-je 10 points" mise à jour'],
    ['updateQuiSuisJe15Points','mission8','Mission "Qui suis-je 15 points" mise à jour'],
    ['updateQuizWithFriend','mission20','Mission "Quiz avec ami" mise à jour'],
    ['updateMultiQuizWithFriend','mission21','Mission "Quiz multi avec ami" mise à jour'],
    ['updateQuiSuisJePlay','mission23','Mission "Jouer qui suis-je" mise à jour']
  ];

  describe('updateAdventureMission', () => {
    it('should return 400 if adventureType missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      await missionController.updateAdventureMission(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should update adventure mission', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.body.adventureType = 'forest';
      missionService.updateAdventureMission.mockResolvedValue(true);

      await missionController.updateAdventureMission(req, res);
      expect(missionService.updateAdventureMission).toHaveBeenCalledWith('uidUser','forest');
      expect(res.status).toHaveBeenCalledWith(200);
    });
  });

  describe('updateScoreMission', () => {
    it('should return 400 if score or gameType missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      await missionController.updateScoreMission(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should update score mission', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.body = { score: 10, gameType: 'puzzle' };
      missionService.updateScoreMission.mockResolvedValue(true);

      await missionController.updateScoreMission(req, res);
      expect(missionService.updateScoreMission).toHaveBeenCalledWith('uidUser', 10, 'puzzle');
      expect(res.status).toHaveBeenCalledWith(200);
    });
  });

  describe('updateStarMission', () => {
    it('should return 400 if stars or adventureType missing', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      await missionController.updateStarMission(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it('should update star mission', async () => {
      authService.verifyTokenFromRequest.mockResolvedValue('uidUser');
      req.body = { stars: 5, adventureType: 'forest' };
      missionService.updateStarMission.mockResolvedValue(true);

      await missionController.updateStarMission(req, res);
      expect(missionService.updateStarMission).toHaveBeenCalledWith('uidUser', 5, 'forest');
      expect(res.status).toHaveBeenCalledWith(200);
    });
  });
});
