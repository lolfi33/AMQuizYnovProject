const { sanitizeInput } = require('../utils/helpers');

// Middleware pour nettoyer les inputs
const sanitizeInputs = (req, res, next) => {
  // Nettoyer le body
  if (req.body) {
    Object.keys(req.body).forEach(key => {
      if (typeof req.body[key] === 'string') {
        req.body[key] = sanitizeInput(req.body[key]);
      }
    });
  }

  // Nettoyer les paramètres de query
  if (req.query) {
    Object.keys(req.query).forEach(key => {
      if (typeof req.query[key] === 'string') {
        req.query[key] = sanitizeInput(req.query[key]);
      }
    });
  }

  next();
};

// Middleware pour valider que l'utilisateur peut modifier ses propres données
const validateUserOwnership = (req, res, next) => {
  const tokenUid = req.uid; // Défini par authMiddleware
  const targetUid = req.params.uid || req.body.uid;

  if (tokenUid !== targetUid) {
    return res.status(403).json({ error: 'Action non autorisée' });
  }

  next();
};

// Middleware pour valider les champs requis
const validateRequiredFields = (requiredFields) => {
  return (req, res, next) => {
    const missingFields = [];

    requiredFields.forEach(field => {
      if (req.body[field] === undefined || req.body[field] === null || req.body[field] === '') {
        missingFields.push(field);
      }
    });

    if (missingFields.length > 0) {
      return res.status(400).json({
        error: `Champs requis manquants: ${missingFields.join(', ')}`
      });
    }

    next();
  };
};

// Middleware pour valider les types de données
const validateDataTypes = (fieldTypes) => {
  return (req, res, next) => {
    const errors = [];

    Object.entries(fieldTypes).forEach(([field, expectedType]) => {
      if (req.body[field] !== undefined) {
        const actualType = typeof req.body[field];
        if (actualType !== expectedType) {
          errors.push(`${field} doit être de type ${expectedType}, reçu ${actualType}`);
        }
      }
    });

    if (errors.length > 0) {
      return res.status(400).json({
        error: `Erreurs de validation: ${errors.join(', ')}`
      });
    }

    next();
  };
};

module.exports = {
  sanitizeInputs,
  validateUserOwnership,
  validateRequiredFields,
  validateDataTypes
};