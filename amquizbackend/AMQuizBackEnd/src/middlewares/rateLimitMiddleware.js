const rateLimit = require('express-rate-limit');

// Limite générale : 100 requêtes par 15 minutes par IP
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limite de 100 requêtes par IP
  message: 'Trop de requêtes, veuillez réessayer plus tard.',
  standardHeaders: true, // Retourne les infos de rate limit dans les headers `RateLimit-*`
  legacyHeaders: false, // Désactive les headers `X-RateLimit-*`
  // Configuration pour proxy
  trustProxy: false, 
  skip: (req) => {
    // Skip rate limiting pour les redirections internes
    return req.originalUrl.startsWith('/api/');
  }
});

// Limite stricte pour les routes sensibles (inscription, connexion)
const strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limite de 5 requêtes par IP
  message: 'Trop de tentatives, veuillez réessayer plus tard.',
  standardHeaders: true,
  legacyHeaders: false,
  trustProxy: false,
});

// Limite pour les routes de boutique
const shopLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 10, // 10 achats par minute maximum
  message: 'Trop d\'achats, veuillez ralentir.',
  standardHeaders: true,
  legacyHeaders: false,
  trustProxy: false,
});

module.exports = {
  generalLimiter,
  strictLimiter,
  shopLimiter
};