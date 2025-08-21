// src/utils/helpers.js
const sanitizeHtml = require('sanitize-html');

const sanitizeInput = (input) => {
  return sanitizeHtml(input, {
    allowedTags: [],
    allowedAttributes: {},
  });
};

const compareMaps = (map1, map2) => {
  if (!map1 || !map2) return false;
  
  const map1Keys = Object.keys(map1);
  const map2Keys = Object.keys(map2);

  if (map1Keys.length !== map2Keys.length) {
    return false;
  }

  for (let key of map1Keys) {
    if (map1[key] !== map2[key]) {
      return false;
    }
  }

  return true;
};

const generateRoomId = () => {
  return `room-${Date.now()}`;
};

const shuffleArray = (array) => {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
};

const getRandomItem = (array) => {
  if (!array || array.length === 0) return null;
  return array[Math.floor(Math.random() * array.length)];
};

const calculateSellValue = (item, itemType) => {
  const { SELL_VALUES } = require('./constants');
  
  if (!SELL_VALUES[itemType] || !SELL_VALUES[itemType][item.rarity]) {
    return 0;
  }
  
  return SELL_VALUES[itemType][item.rarity];
};

const determineRarity = (roll, probabilities) => {
  if (roll < probabilities.commun) {
    return 'commun';
  } else if (roll < probabilities.commun + probabilities.rare) {
    return 'rare';
  } else {
    return 'legendaire';
  }
};

module.exports = {
  sanitizeInput,
  compareMaps,
  generateRoomId,
  shuffleArray,
  getRandomItem,
  calculateSellValue,
  determineRarity
};