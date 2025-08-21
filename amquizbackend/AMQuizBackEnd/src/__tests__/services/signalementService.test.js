const signalementService = require('../../services/signalementService');
const signalementRepository = require('../../repositories/signalementRepository');
const userRepository = require('../../repositories/userRepository');

jest.mock('../../repositories/signalementRepository');
jest.mock('../../repositories/userRepository');

describe('SignalementService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createSignalement', () => {
    it('doit lancer une erreur si reportedUid est manquant', async () => {
      await expect(
        signalementService.createSignalement('uid1', null, 'Spam')
      ).rejects.toThrow('Données de signalement incomplètes');
    });

    it('doit lancer une erreur si reason est manquant', async () => {
      await expect(
        signalementService.createSignalement('uid1', 'uid2', null)
      ).rejects.toThrow('Données de signalement incomplètes');
    });

    it('doit lancer une erreur si reporterUid === reportedUid', async () => {
      await expect(
        signalementService.createSignalement('uid1', 'uid1', 'Spam')
      ).rejects.toThrow('Vous ne pouvez pas vous signaler vous-même');
    });

    it("doit lancer une erreur si l'utilisateur signalé est introuvable", async () => {
      userRepository.getUserByUid.mockResolvedValue(null);

      await expect(
        signalementService.createSignalement('uid1', 'uid2', 'Spam')
      ).rejects.toThrow('Utilisateur signalé introuvable');
    });

    it('doit enregistrer un signalement avec succès', async () => {
      userRepository.getUserByUid.mockResolvedValue({
        pseudo: 'JohnDoe',
        biographie: 'Bio test'
      });

      signalementRepository.createSignalement.mockResolvedValue();

      const result = await signalementService.createSignalement(
        'uid1',
        'uid2',
        'Spam'
      );

      expect(userRepository.getUserByUid).toHaveBeenCalledWith('uid2');
      expect(signalementRepository.createSignalement).toHaveBeenCalledWith({
        uidJoueur: 'uid1',
        uidJoueurQuiAEteSignale: 'uid2',
        raison: 'Spam',
        pseudoJoueurQuiAEteSignaler: 'JohnDoe',
        biographieJoueurQuiAEteSignaler: 'Bio test'
      });
      expect(result).toBe('Signalement enregistré avec succès');
    });

    it("doit utiliser les valeurs par défaut si pseudo et bio n'existent pas", async () => {
      userRepository.getUserByUid.mockResolvedValue({});

      signalementRepository.createSignalement.mockResolvedValue();

      const result = await signalementService.createSignalement(
        'uid1',
        'uid2',
        'Spam'
      );

      expect(signalementRepository.createSignalement).toHaveBeenCalledWith({
        uidJoueur: 'uid1',
        uidJoueurQuiAEteSignale: 'uid2',
        raison: 'Spam',
        pseudoJoueurQuiAEteSignaler: 'Pseudo non défini',
        biographieJoueurQuiAEteSignaler: 'Biographie non définie'
      });
      expect(result).toBe('Signalement enregistré avec succès');
    });
  });

  describe('getSignalementsByUser', () => {
    it('doit retourner les signalements par utilisateur', async () => {
      signalementRepository.getSignalementsByUser.mockResolvedValue(['sig1']);
      const result = await signalementService.getSignalementsByUser('uid2');
      expect(result).toEqual(['sig1']);
    });
  });

  describe('getAllSignalements', () => {
    it('doit retourner tous les signalements', async () => {
      signalementRepository.getAllSignalements.mockResolvedValue(['sig1', 'sig2']);
      const result = await signalementService.getAllSignalements();
      expect(result).toEqual(['sig1', 'sig2']);
    });
  });

  describe('deleteSignalement', () => {
    it('doit supprimer un signalement', async () => {
      signalementRepository.deleteSignalement.mockResolvedValue();
      const result = await signalementService.deleteSignalement('sig1');
      expect(signalementRepository.deleteSignalement).toHaveBeenCalledWith('sig1');
      expect(result).toBe('Signalement supprimé avec succès');
    });
  });

  describe('getSignalementsByReporter', () => {
    it('doit retourner les signalements faits par un utilisateur', async () => {
      signalementRepository.getSignalementsByReporter.mockResolvedValue(['sig1']);
      const result = await signalementService.getSignalementsByReporter('uid1');
      expect(result).toEqual(['sig1']);
    });
  });

  describe('validateSignalementReason', () => {
    it('doit retourner true pour une raison valide', async () => {
      const result = await signalementService.validateSignalementReason('Spam');
      expect(result).toBe(true);
    });

    it('doit lancer une erreur pour une raison invalide', async () => {
      await expect(
        signalementService.validateSignalementReason('Raison bidon')
      ).rejects.toThrow('Raison de signalement invalide');
    });
  });
});
