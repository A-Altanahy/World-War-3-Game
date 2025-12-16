// lib/services/question_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../models/question_category.dart';
import '../models/question_state.dart';

class QuestionService {
  List<QuestionCategory> _categories = [];
  List<Question> _questions = [];
  List<QuestionState> _questionStates = [];

  List<QuestionCategory> get categories => _categories;
  List<Question> get questions => _questions;
  List<QuestionState> get questionStates => _questionStates;

  /// Initialize the question service by loading data from JSON files
  Future<void> initialize() async {
    await _loadCategories();
    await _loadQuestions();
    _initializeQuestionStates();
  }

  /// Load categories from JSON file
  Future<void> _loadCategories() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/questions/categories.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _categories = (jsonData['categories'] as List)
          .map((categoryJson) => QuestionCategory.fromJson(categoryJson))
          .toList();
    } catch (e) {
      print('Error loading categories: $e');
      _categories = [];
    }
  }

  /// Load questions from JSON file
  Future<void> _loadQuestions() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/questions/questions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _questions = (jsonData['questions'] as List)
          .map((questionJson) => Question.fromJson(questionJson))
          .toList();
    } catch (e) {
      print('Error loading questions: $e');
      _questions = [];
    }
  }

  /// Initialize question states for all questions (unrevealed by default)
  void _initializeQuestionStates() {
    _questionStates = _questions
        .map((question) => QuestionState(
              questionId: question.id,
              categoryId: question.categoryId,
            ))
        .toList();
  }

  /// Reset all question states (for new game)
  void resetQuestionStates() {
    _initializeQuestionStates();
  }

  /// Get all questions for a specific category
  List<Question> getQuestionsByCategory(String categoryId) {
    return _questions.where((q) => q.categoryId == categoryId).toList();
  }

  /// Get all unrevealed questions for a specific category
  List<Question> getUnrevealedQuestionsByCategory(String categoryId) {
    final unrevealedIds = _questionStates
        .where((state) => state.categoryId == categoryId && !state.isRevealed)
        .map((state) => state.questionId)
        .toList();

    return _questions
        .where((question) => unrevealedIds.contains(question.id))
        .toList();
  }

  /// Get the first unrevealed question for a category (random from unrevealed)
  Question? getNextQuestionForCategory(String categoryId) {
    final unrevealedQuestions = getUnrevealedQuestionsByCategory(categoryId);

    if (unrevealedQuestions.isEmpty) {
      return null; // No more unrevealed questions in this category
    }

    // Return a random unrevealed question
    final random = Random();
    return unrevealedQuestions[random.nextInt(unrevealedQuestions.length)];
  }

  /// Mark a question as revealed
  void markQuestionAsRevealed(String questionId) {
    final questionState = _questionStates.firstWhere(
      (state) => state.questionId == questionId,
    );
    questionState.markAsRevealed();
  }

  /// Mark a question as answered
  void markQuestionAsAnswered(String questionId) {
    final questionState = _questionStates.firstWhere(
      (state) => state.questionId == questionId,
    );
    questionState.markAsAnswered();
  }

  /// Get question state by question ID
  QuestionState? getQuestionState(String questionId) {
    try {
      return _questionStates.firstWhere(
        (state) => state.questionId == questionId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if a question is revealed
  bool isQuestionRevealed(String questionId) {
    final state = getQuestionState(questionId);
    return state?.isRevealed ?? false;
  }

  /// Check if a question is answered
  bool isQuestionAnswered(String questionId) {
    final state = getQuestionState(questionId);
    return state?.isAnswered ?? false;
  }

  /// Get category by ID
  QuestionCategory? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Get question by ID
  Question? getQuestionById(String questionId) {
    try {
      return _questions.firstWhere((question) => question.id == questionId);
    } catch (e) {
      return null;
    }
  }

  /// Get statistics for each category
  Map<String, Map<String, int>> getCategoryStatistics() {
    Map<String, Map<String, int>> stats = {};

    for (var category in _categories) {
      final categoryQuestions = getQuestionsByCategory(category.id);
      final revealedQuestions = categoryQuestions
          .where(
            (q) => isQuestionRevealed(q.id),
          )
          .length;

      stats[category.id] = {
        'total': categoryQuestions.length,
        'revealed': revealedQuestions,
        'remaining': categoryQuestions.length - revealedQuestions,
      };
    }

    return stats;
  }
}
