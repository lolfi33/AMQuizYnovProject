// ignore_for_file: file_names

class Oeuvre {
  final String title;

  Oeuvre({
    required this.title,
  });
}

class Indice {
  final String indice1;
  final String indice2;
  final String indice3;
  final List<String> reponsesPossibles;

  Indice({
    required this.indice1,
    required this.indice2,
    required this.indice3,
    required this.reponsesPossibles,
  });

  // Convertir un JSON en objet Indice
  factory Indice.fromJson(Map<String, dynamic> json) {
    return Indice(
      indice1: json['indice1'],
      indice2: json['indice2'],
      indice3: json['indice3'],
      reponsesPossibles: List<String>.from(json['reponsesPossibles']),
    );
  }
}
