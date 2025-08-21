// ignore_for_file: file_names

enum ItemType { profil, banniere }

enum ItemRarity { commun, rare, legendaire }

// ignore: constant_identifier_names
enum ItemOeuvre { onePiece, SNK, MHA }

class Item {
  final String name;
  int number;
  final ItemType type;
  final ItemRarity rarity;
  final String imageUrl;
  final ItemOeuvre oeuvre;

  Item({
    required this.name,
    required this.number,
    required this.type,
    required this.rarity,
    required this.imageUrl,
    required this.oeuvre,
  });

  // Convertir un objet Item en Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'number': number,
      'type': type.toString(),
      'rarity': rarity.toString(),
      'imageUrl': imageUrl,
      'oeuvre': oeuvre.toString(),
    };
  }

  // Méthode pour créer un objet Item à partir d'un JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'] as String,
      number: json['number'] as int,
      type: _stringToItemType(json['type'] as String),
      rarity: _stringToItemRarity(json['rarity'] as String),
      imageUrl: json['imageUrl'] as String,
      oeuvre: _stringToItemOeuvre(json['oeuvre'] as String),
    );
  }

  // Créer un objet Item à partir d'une Map
  static Item fromMap(Map<String, dynamic> map) {
    return Item(
      name: map['name'],
      number: int.tryParse(map['number'].toString()) ?? 0,
      type: _parseItemType(map['type']),
      rarity: _parseItemRarity(map['rarity']),
      imageUrl: map['imageUrl'],
      oeuvre: _parseItemOeuvre(map['oeuvre']),
    );
  }

  // Fonction pour convertir la chaîne 'type' en énumération ItemType
  static ItemType _parseItemType(String type) {
    switch (type) {
      case 'profil':
        return ItemType.profil;
      case 'banniere':
        return ItemType.banniere;
      default:
        throw Exception("Type d'Item inconnu : $type");
    }
  }

  // Fonction pour convertir la chaîne 'rarity' en énumération ItemRarity
  static ItemRarity _parseItemRarity(String rarity) {
    switch (rarity) {
      case 'commun':
        return ItemRarity.commun;
      case 'rare':
        return ItemRarity.rare;
      case 'legendaire':
        return ItemRarity.legendaire;
      default:
        throw Exception("Rareté d'Item inconnue : $rarity");
    }
  }

  // Fonction pour convertir la chaîne 'oeuvre' en énumération ItemOeuvre
  static ItemOeuvre _parseItemOeuvre(String oeuvre) {
    switch (oeuvre) {
      case 'onePiece':
        return ItemOeuvre.onePiece;
      case 'SNK':
        return ItemOeuvre.SNK;
      case 'MHA':
        return ItemOeuvre.MHA;
      default:
        throw Exception("Oeuvre d'Item inconnue : $oeuvre");
    }
  }
}

// Convertir une chaîne en ItemType
ItemType _stringToItemType(String type) {
  switch (type) {
    case 'profil':
      return ItemType.profil;
    case 'banniere':
      return ItemType.banniere;
    default:
      throw Exception('Type inconnu: $type');
  }
}

// Convertir une chaîne en ItemRarity
ItemRarity _stringToItemRarity(String rarity) {
  switch (rarity) {
    case 'commun':
      return ItemRarity.commun;
    case 'rare':
      return ItemRarity.rare;
    case 'legendaire':
      return ItemRarity.legendaire;
    default:
      throw Exception('Rareté inconnue: $rarity');
  }
}

// Convertir une chaîne en ItemOeuvre
ItemOeuvre _stringToItemOeuvre(String oeuvre) {
  switch (oeuvre) {
    case 'onePiece':
      return ItemOeuvre.onePiece;
    case 'SNK':
      return ItemOeuvre.SNK;
    case 'MHA':
      return ItemOeuvre.MHA;
    default:
      throw Exception('Oeuvre inconnue: $oeuvre');
  }
}
