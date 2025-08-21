const friendService = require('../../services/friendService');
const userRepository = require('../../repositories/userRepository');
const missionRepository = require('../../repositories/missionRepository');

jest.mock('../../repositories/userRepository');
jest.mock('../../repositories/missionRepository');

describe('FriendService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('sendInvitation', () => {
    it('ne peut pas envoyer une invitation à soi-même', async () => {
      await expect(friendService.sendInvitation('uid1', 'uid1'))
        .rejects.toThrow('Vous ne pouvez pas vous ajouter vous-même');
    });

    it('lève une erreur si un utilisateur est introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce(null);
      await expect(friendService.sendInvitation('uid1', 'uid2'))
        .rejects.toThrow('Utilisateur non trouvé');
    });

    it('envoie une invitation correctement', async () => {
      userRepository.getUserByUid
        .mockResolvedValueOnce({ uidUser: 'uid1', pseudo: 'Alice' })
        .mockResolvedValueOnce({ uidUser: 'uid2', pseudo: 'Bob', amis: [], invitations: [] });

      userRepository.arrayUnion.mockResolvedValue();

      const res = await friendService.sendInvitation('uid1', 'uid2');
      expect(res).toBe('Invitation envoyée à Bob');
      expect(userRepository.arrayUnion).toHaveBeenCalledWith('uid2', 'invitations', 'Alice');
      expect(userRepository.arrayUnion).toHaveBeenCalledWith('uid2', 'uidInvitations', 'uid1');
    });
  });

  describe('sendInvitationByPseudo', () => {
    it('lève une erreur si pseudo inexistant', async () => {
      userRepository.getUserByPseudo.mockResolvedValueOnce(null);
      await expect(friendService.sendInvitationByPseudo('uid1', 'Bob'))
        .rejects.toThrow('Le pseudo n\'existe pas');
    });

    it('envoie une invitation par pseudo', async () => {
      userRepository.getUserByPseudo.mockResolvedValueOnce({ uidUser: 'uid2', pseudo: 'Bob' });
      jest.spyOn(friendService, 'sendInvitation').mockResolvedValueOnce('Invitation envoyée à Bob');

      const res = await friendService.sendInvitationByPseudo('uid1', 'Bob');
      expect(res).toBe('Invitation envoyée à Bob');
      expect(friendService.sendInvitation).toHaveBeenCalledWith('uid1', 'uid2');
    });
  });

  describe('acceptInvitation', () => {
    it('lève une erreur si utilisateur introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce(null);
      await expect(friendService.acceptInvitation('uid1', 'uid2', 'Alice'))
        .rejects.toThrow('Utilisateur non trouvé');
    });

    it('accepte une invitation correctement', async () => {
      userRepository.getUserByUid
        .mockResolvedValueOnce({ uidUser: 'uid1', pseudo: 'Alice' })
        .mockResolvedValueOnce({ uidUser: 'uid2', pseudo: 'Bob' });

      userRepository.arrayUnion.mockResolvedValue();
      userRepository.arrayRemove.mockResolvedValue();
      missionRepository.updateMissionProgress.mockResolvedValue();

      const res = await friendService.acceptInvitation('uid1', 'uid2', 'Bob');
      expect(res).toBe('Ami ajouté avec succès');
      expect(userRepository.arrayUnion).toHaveBeenCalledTimes(2);
      expect(userRepository.arrayRemove).toHaveBeenCalledTimes(2);
      expect(missionRepository.updateMissionProgress).toHaveBeenCalledTimes(2);
    });
  });

  describe('deleteInvitation', () => {
    it('lève une erreur si utilisateur introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce(null);
      await expect(friendService.deleteInvitation('uid1', 0))
        .rejects.toThrow('Utilisateur non trouvé');
    });

    it('lève une erreur si index invalide', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce({ invitations: [], uidInvitations: [] });
      await expect(friendService.deleteInvitation('uid1', 1))
        .rejects.toThrow('Index invalide');
    });

    it('supprime une invitation correctement', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce({
        invitations: ['Bob'],
        uidInvitations: ['uid2'],
      });

      userRepository.updateUser.mockResolvedValue();

      const res = await friendService.deleteInvitation('uid1', 0);
      expect(res).toBe('Invitation supprimée avec succès');
      expect(userRepository.updateUser).toHaveBeenCalledWith('uid1', {
        invitations: [],
        uidInvitations: [],
      });
    });
  });

  describe('verifyInvitation', () => {
    it('lève une erreur si sender introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce(null);
      await expect(friendService.verifyInvitation('uid1', 'Bob'))
        .rejects.toThrow('Utilisateur expéditeur non trouvé');
    });

    it('lève une erreur si receiver introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce({ pseudo: 'Alice' });
      userRepository.getUserByPseudo.mockResolvedValueOnce(null);
      await expect(friendService.verifyInvitation('uid1', 'Bob'))
        .rejects.toThrow('Le pseudo n\'existe pas');
    });

    it('lève une erreur si auto-ajout', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce({ uidUser: 'uid1', pseudo: 'Alice' });
      userRepository.getUserByPseudo.mockResolvedValueOnce({ uidUser: 'uid1', pseudo: 'Alice' });
      await expect(friendService.verifyInvitation('uid1', 'Alice'))
        .rejects.toThrow('Vous ne pouvez pas vous ajouter vous-même');
    });

    it('vérifie correctement une invitation', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce({ uidUser: 'uid1', pseudo: 'Alice', amis: [] });
      userRepository.getUserByPseudo.mockResolvedValueOnce({ uidUser: 'uid2', pseudo: 'Bob', invitations: [] });

      const res = await friendService.verifyInvitation('uid1', 'Bob');
      expect(res).toEqual({ message: 'Tout est OK', uidAmi: 'uid2' });
    });
  });

  describe('deleteFriend', () => {
    it('lève une erreur si utilisateur introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce(null);
      await expect(friendService.deleteFriend('uid1', 'uid2'))
        .rejects.toThrow('Utilisateur introuvable');
    });

    it('supprime un ami des deux listes', async () => {
      userRepository.getUserByUid
        .mockResolvedValueOnce({ uidUser: 'uid1', pseudo: 'Alice' })
        .mockResolvedValueOnce({ uidUser: 'uid2', pseudo: 'Bob' });

      userRepository.arrayRemove.mockResolvedValue();

      const res = await friendService.deleteFriend('uid1', 'uid2');
      expect(res).toBe('Ami supprimé avec succès des deux listes');
      expect(userRepository.arrayRemove).toHaveBeenCalledWith('uid1', 'amis', 'Bob');
      expect(userRepository.arrayRemove).toHaveBeenCalledWith('uid2', 'amis', 'Alice');
    });
  });

  describe('getFriendsList', () => {
    it('lève une erreur si utilisateur introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce(null);
      await expect(friendService.getFriendsList('uid1'))
        .rejects.toThrow('Utilisateur non trouvé');
    });

    it('retourne la liste des amis', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce({ amis: ['Bob', 'Charlie'] });
      const res = await friendService.getFriendsList('uid1');
      expect(res).toEqual(['Bob', 'Charlie']);
    });
  });

  describe('getPendingInvitations', () => {
    it('lève une erreur si utilisateur introuvable', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce(null);
      await expect(friendService.getPendingInvitations('uid1'))
        .rejects.toThrow('Utilisateur non trouvé');
    });

    it('retourne les invitations en attente', async () => {
      userRepository.getUserByUid.mockResolvedValueOnce({
        invitations: ['Bob'],
        uidInvitations: ['uid2'],
      });
      const res = await friendService.getPendingInvitations('uid1');
      expect(res).toEqual({ invitations: ['Bob'], uidInvitations: ['uid2'] });
    });
  });
});
