const authService = require('../services/authService');

const authMiddleware = async (req, res, next) => {
  try {
    const uid = await authService.verifyTokenFromRequest(req);
    req.uid = uid;
    next();
  } catch (error) {
    res.status(401).json({ error: error.message });
  }
};

module.exports = authMiddleware;