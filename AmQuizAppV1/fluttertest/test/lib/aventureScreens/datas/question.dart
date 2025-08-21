class Question {
  final String question;
  final List<dynamic> options;
  final String reponse;

  const Question({
    required this.question,
    required this.options,
    required this.reponse,
  });

  static Question fromJson(json) => Question(
      question: json['question'],
      options: json['options'],
      reponse: json['reponse']);
}
