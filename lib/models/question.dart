// lib/models/question.dart

class Question {
  final String id;
  final String categoryId;
  final String? text;
  final String? imagePath;
  final String? answerText;
  final String? answerImagePath;
  final int difficulty; // 1-5 difficulty level

  Question({
    required this.id,
    required this.categoryId,
    this.text,
    this.imagePath,
    this.answerText,
    this.answerImagePath,
    this.difficulty = 1,
  })  : assert(text != null || imagePath != null,
            'Question must have either text or image'),
        assert(answerText != null || answerImagePath != null,
            'Answer must have either text or image');

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      text: json['text'] as String?,
      imagePath: json['imagePath'] as String?,
      answerText: json['answerText'] as String?,
      answerImagePath: json['answerImagePath'] as String?,
      difficulty: json['difficulty'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'text': text,
      'imagePath': imagePath,
      'answerText': answerText,
      'answerImagePath': answerImagePath,
      'difficulty': difficulty,
    };
  }

  bool get hasTextQuestion => text != null && text!.isNotEmpty;
  bool get hasImageQuestion => imagePath != null && imagePath!.isNotEmpty;
  bool get hasTextAnswer => answerText != null && answerText!.isNotEmpty;
  bool get hasImageAnswer =>
      answerImagePath != null && answerImagePath!.isNotEmpty;
}
