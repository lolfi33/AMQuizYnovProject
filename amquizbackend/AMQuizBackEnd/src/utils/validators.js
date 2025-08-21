// src/utils/validators.js

const validatePseudo = (pseudo) => {
  if (!pseudo) {
    return { isValid: false, error: 'Le pseudo est requis' };
  }

  if (pseudo.length > 10) {
    return { isValid: false, error: 'Le pseudo ne doit pas faire plus de 10 caractères' };
  }

  const pseudoPattern = /^[a-zA-Z0-9_]*$/;
  if (!pseudoPattern.test(pseudo)) {
    return { isValid: false, error: 'Un ou des caractères ne sont pas valides dans le pseudo' };
  }

  return { isValid: true };
};

const validateBiography = (biographie) => {
  if (biographie.length > 40) {
    return { isValid: false, error: 'La biographie ne peut pas dépasser 40 caractères' };
  }

  return { isValid: true };
};

const validateTitle = (titre) => {
  if (titre.length > 30) {
    return { isValid: false, error: 'Le titre ne peut pas dépasser 30 caractères' };
  }

  return { isValid: true };
};

const validateEmail = (email) => {
  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailPattern.test(email)) {
    return { isValid: false, error: 'Format d\'email invalide' };
  }

  return { isValid: true };
};

const validatePassword = (password) => {
  if (!password || password.length < 6) {
    return { isValid: false, error: 'Le mot de passe doit contenir au moins 6 caractères' };
  }

  return { isValid: true };
};

module.exports = {
  validatePseudo,
  validateBiography,
  validateTitle,
  validateEmail,
  validatePassword
};