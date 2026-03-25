// lib/models/question.dart

class Question {
  final String id;
  final String categoryId;
  final String? text;
  final String? imagePath;
  final String? audioPath;
  final String? videoPath;
  final String? answerText;
  final String? answerImagePath;
  final String? answerAudioPath;
  final String? answerVideoPath;
  final int difficulty; // 1-5 difficulty level
  final bool isActive; // Whether this question is active in gameplay

  Question({
    required this.id,
    required this.categoryId,
    this.text,
    this.imagePath,
    this.audioPath,
    this.videoPath,
    this.answerText,
    this.answerImagePath,
    this.answerAudioPath,
    this.answerVideoPath,
    this.difficulty = 1,
    this.isActive = true,
  })  : assert(
            text != null ||
                imagePath != null ||
                audioPath != null ||
                videoPath != null,
            'Question must have either text, image, audio, or video'),
        assert(
            answerText != null ||
                answerImagePath != null ||
                answerAudioPath != null ||
                answerVideoPath != null,
            'Answer must have either text, image, audio, or video');

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      text: json['text'] as String?,
      imagePath: json['imagePath'] as String?,
      audioPath: json['audioPath'] as String?,
      videoPath: json['videoPath'] as String?,
      answerText: json['answerText'] as String?,
      answerImagePath: json['answerImagePath'] as String?,
      answerAudioPath: json['answerAudioPath'] as String?,
      answerVideoPath: json['answerVideoPath'] as String?,
      difficulty: json['difficulty'] as int? ?? 1,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'text': text,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'videoPath': videoPath,
      'answerText': answerText,
      'answerImagePath': answerImagePath,
      'answerAudioPath': answerAudioPath,
      'answerVideoPath': answerVideoPath,
      'difficulty': difficulty,
      'isActive': isActive,
    };
  }

  bool get hasTextQuestion => text != null && text!.isNotEmpty;
  bool get hasImageQuestion => imagePath != null && imagePath!.isNotEmpty;
  bool get hasAudioQuestion => audioPath != null && audioPath!.isNotEmpty;
  bool get hasVideoQuestion => videoPath != null && videoPath!.isNotEmpty;
  bool get hasTextAnswer => answerText != null && answerText!.isNotEmpty;
  bool get hasImageAnswer =>
      answerImagePath != null && answerImagePath!.isNotEmpty;
  bool get hasAudioAnswer =>
      answerAudioPath != null && answerAudioPath!.isNotEmpty;
  bool get hasVideoAnswer =>
      answerVideoPath != null && answerVideoPath!.isNotEmpty;
}
