// src/services/signalementService.js
const signalementRepository = require('../repositories/signalementRepository');
const userRepository = require('../repositories/userRepository');

class SignalementService {
  async createSignalement(reporterUid, reportedUid, reason) {
    if (!reportedUid || !reason) {
      throw new Error('Données de signalement incomplètes');
    }

    if (reporterUid === reportedUid) {
      throw new Error('Vous ne pouvez pas vous signaler vous-même');
    }

    // Récupérer les informations de l'utilisateur signalé
    const reportedUser = await userRepository.getUserByUid(reportedUid);
    if (!reportedUser) {
      throw new Error('Utilisateur signalé introuvable');
    }

    const signalementData = {
      uidJoueur: reporterUid,
      uidJoueurQuiAEteSignale: reportedUid,
      raison: reason,
      pseudoJoueurQuiAEteSignaler: reportedUser.pseudo || "Pseudo non défini",
      biographieJoueurQuiAEteSignaler: reportedUser.biographie || "Biographie non définie",
    };

    await signalementRepository.createSignalement(signalementData);
    return 'Signalement enregistré avec succès';
  }

  async getSignalementsByUser(reportedUid) {
    return await signalementRepository.getSignalementsByUser(reportedUid);
  }

  async getAllSignalements() {
    return await signalementRepository.getAllSignalements();
  }

  async deleteSignalement(signalementId) {
    await signalementRepository.deleteSignalement(signalementId);
    return 'Signalement supprimé avec succès';
  }

  async getSignalementsByReporter(reporterUid) {
    return await signalementRepository.getSignalementsByReporter(reporterUid);
  }

  async validateSignalementReason(reason) {
    const validReasons = [
      'Contenu inapproprié',
      'Harcèlement',
      'Spam',
      'Pseudo offensant',
      'Biographie inappropriée',
      'Tricherie',
      'Autre'
    ];

    if (!validReasons.includes(reason)) {
      throw new Error('Raison de signalement invalide');
    }

    return true;
  }
}

module.exports = new SignalementService();