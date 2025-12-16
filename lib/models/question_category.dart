// lib/models/question_category.dart

class QuestionCategory {
  final String id;
  final String name;
  final String description;
  final String? iconPath;
  final String color; // Hex color string

  QuestionCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconPath,
    this.color = '#2196F3', // Default blue color
  });

  factory QuestionCategory.fromJson(Map<String, dynamic> json) {
    return QuestionCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String?,
      color: json['color'] as String? ?? '#2196F3',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'color': color,
    };
  }
}
