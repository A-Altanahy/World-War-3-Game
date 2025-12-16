// lib/models/question_state.dart

class QuestionState {
  final String questionId;
  final String categoryId;
  bool isRevealed;
  bool isAnswered;
  DateTime? revealedAt;
  DateTime? answeredAt;

  QuestionState({
    required this.questionId,
    required this.categoryId,
    this.isRevealed = false,
    this.isAnswered = false,
    this.revealedAt,
    this.answeredAt,
  });

  factory QuestionState.fromJson(Map<String, dynamic> json) {
    return QuestionState(
      questionId: json['questionId'] as String,
      categoryId: json['categoryId'] as String,
      isRevealed: json['isRevealed'] as bool? ?? false,
      isAnswered: json['isAnswered'] as bool? ?? false,
      revealedAt: json['revealedAt'] != null
          ? DateTime.parse(json['revealedAt'] as String)
          : null,
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'categoryId': categoryId,
      'isRevealed': isRevealed,
      'isAnswered': isAnswered,
      'revealedAt': revealedAt?.toIso8601String(),
      'answeredAt': answeredAt?.toIso8601String(),
    };
  }

  void markAsRevealed() {
    isRevealed = true;
    revealedAt = DateTime.now();
  }

  void markAsAnswered() {
    isAnswered = true;
    answeredAt = DateTime.now();
  }
}
