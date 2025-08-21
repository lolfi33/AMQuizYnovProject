// ignore_for_file: file_names

class CoupSpeciaux {
  final String nom;
  final String imageUrl;
  final String description;
  final int utilisationMax;
  final String type;

  CoupSpeciaux({
    required this.nom,
    required this.imageUrl,
    required this.description,
    required this.utilisationMax,
    required this.type,
  });

  // Convertir un objet CoupSpeciaux en Map
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'imageUrl': imageUrl,
      'description': description,
      'utilisationMax': utilisationMax,
      'type': type,
    };
  }

  // Créer un objet CoupSpeciaux à partir d'une Map
  static CoupSpeciaux fromMap(Map<String, dynamic> map) {
    return CoupSpeciaux(
      nom: map['nom'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      utilisationMax: map['utilisationMax'],
      type: map['type'],
    );
  }
}
