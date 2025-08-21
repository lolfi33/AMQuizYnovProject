// src/services/friendService.js
const userRepository = require('../repositories/userRepository');
const missionRepository = require('../repositories/missionRepository');

class FriendService {
  async sendInvitation(senderUid, receiverUid) {
    if (senderUid === receiverUid) {
      throw new Error('Vous ne pouvez pas vous ajouter vous-même');
    }

    // Récupérer les utilisateurs
    const sender = await userRepository.getUserByUid(senderUid);
    const receiver = await userRepository.getUserByUid(receiverUid);

    if (!sender || !receiver) {
      throw new Error('Utilisateur non trouvé');
    }

    // Vérifier si déjà amis
    const receiverFriends = receiver.amis || [];
    if (receiverFriends.includes(sender.pseudo)) {
      throw new Error(`Vous êtes déjà amis avec ${receiver.pseudo}`);
    }

    // Vérifier si invitation déjà envoyée
    const receiverInvitations = receiver.invitations || [];
    if (receiverInvitations.includes(sender.pseudo)) {
      throw new Error(`Invitation déjà envoyée à ${receiver.pseudo}`);
    }

    // Ajouter l'invitation
    await userRepository.arrayUnion(receiverUid, 'invitations', sender.pseudo);
    await userRepository.arrayUnion(receiverUid, 'uidInvitations', senderUid);

    return `Invitation envoyée à ${receiver.pseudo}`;
  }

  async sendInvitationByPseudo(senderUid, receiverPseudo) {
    // Vérifier si le pseudo existe
    const receiver = await userRepository.getUserByPseudo(receiverPseudo);
    if (!receiver) {
      throw new Error('Le pseudo n\'existe pas');
    }

    return await this.sendInvitation(senderUid, receiver.uidUser);
  }

  async acceptInvitation(currentUserUid, senderUid, senderPseudo) {
    const currentUser = await userRepository.getUserByUid(currentUserUid);
    const sender = await userRepository.getUserByUid(senderUid);

    if (!currentUser || !sender) {
      throw new Error('Utilisateur non trouvé');
    }

    // Ajouter aux listes d'amis mutuellement
    await userRepository.arrayUnion(currentUserUid, 'amis', senderPseudo);
    await userRepository.arrayUnion(senderUid, 'amis', currentUser.pseudo);

    // Supprimer l'invitation
    await userRepository.arrayRemove(currentUserUid, 'invitations', senderPseudo);
    await userRepository.arrayRemove(currentUserUid, 'uidInvitations', senderUid);

    // Mettre à jour les missions pour les deux utilisateurs
    await missionRepository.updateMissionProgress(currentUserUid, 'mission4');
    await missionRepository.updateMissionProgress(senderUid, 'mission4');

    return 'Ami ajouté avec succès';
  }

  async deleteInvitation(uid, indexInvitation) {
    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    const invitations = user.invitations || [];
    const uidInvitations = user.uidInvitations || [];

    if (indexInvitation < 0 || indexInvitation >= invitations.length) {
      throw new Error('Index invalide');
    }

    // Supprimer aux index spécifiés
    invitations.splice(indexInvitation, 1);
    uidInvitations.splice(indexInvitation, 1);

    await userRepository.updateUser(uid, {
      invitations: invitations,
      uidInvitations: uidInvitations,
    });

    return 'Invitation supprimée avec succès';
  }

  async verifyInvitation(senderUid, receiverPseudo) {
    const sender = await userRepository.getUserByUid(senderUid);
    if (!sender) {
      throw new Error('Utilisateur expéditeur non trouvé');
    }

    // Vérifier si le pseudo existe
    const receiver = await userRepository.getUserByPseudo(receiverPseudo);
    if (!receiver) {
      throw new Error('Le pseudo n\'existe pas');
    }

    const receiverUid = receiver.uidUser;

    // Vérifier que l'utilisateur ne s'ajoute pas lui-même
    if (receiverUid === senderUid) {
      throw new Error('Vous ne pouvez pas vous ajouter vous-même');
    }

    // Vérifier si déjà amis
    const senderFriends = sender.amis || [];
    if (senderFriends.includes(receiverPseudo)) {
      throw new Error('Vous êtes déjà amis');
    }

    // Vérifier si invitation déjà envoyée
    const receiverInvitations = receiver.invitations || [];
    if (receiverInvitations.includes(sender.pseudo)) {
      throw new Error('Invitation déjà envoyée');
    }

    return { 
      message: 'Tout est OK', 
      uidAmi: receiverUid 
    };
  }

  async deleteFriend(currentUserUid, friendUid) {
    const currentUser = await userRepository.getUserByUid(currentUserUid);
    const friend = await userRepository.getUserByUid(friendUid);

    if (!currentUser || !friend) {
      throw new Error('Utilisateur introuvable');
    }

    // Supprimer de la liste d'amis de l'utilisateur courant
    await userRepository.arrayRemove(currentUserUid, 'amis', friend.pseudo);
    
    // Supprimer de la liste d'amis de l'ami
    await userRepository.arrayRemove(friendUid, 'amis', currentUser.pseudo);

    return 'Ami supprimé avec succès des deux listes';
  }

  async getFriendsList(uid) {
    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    return user.amis || [];
  }

  async getPendingInvitations(uid) {
    const user = await userRepository.getUserByUid(uid);
    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    return {
      invitations: user.invitations || [],
      uidInvitations: user.uidInvitations || []
    };
  }
}

module.exports = new FriendService();