// lib/services/question_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/question.dart';
import '../models/question_category.dart';
import '../models/question_state.dart';

class QuestionService extends ChangeNotifier {
  List<QuestionCategory> _builtinCategories = [];
  List<Question> _builtinQuestions = [];

  List<QuestionCategory> _customCategories = [];
  List<Question> _customQuestions = [];

  Set<String> _disabledCategoryIds = {};
  Set<String> _deletedBuiltinQuestionIds = {};

  List<QuestionState> _questionStates = [];

  // Combined getters
  List<QuestionCategory> get categories =>
      [..._builtinCategories, ..._customCategories];

  List<QuestionCategory> get visibleCategories =>
      categories.where((c) => !_disabledCategoryIds.contains(c.id)).toList();

  List<Question> get questions => [
        ..._builtinQuestions
            .where((q) => !_deletedBuiltinQuestionIds.contains(q.id)),
        ..._customQuestions
      ];
  List<QuestionState> get questionStates => _questionStates;

  static const String _userDataFileName = 'user_questions_v1.json';

  /// Initialize the question service by loading data from JSON files and local storage
  Future<void> initialize() async {
    await _loadBuiltinData();
    await _loadUserData();
    _initializeQuestionStates();
    notifyListeners();
  }

  /// Load built-in data from assets
  Future<void> _loadBuiltinData() async {
    try {
      // Load Categories
      final catString =
          await rootBundle.loadString('assets/questions/categories.json');
      final catJson = json.decode(catString);
      _builtinCategories = (catJson['categories'] as List)
          .map((c) => QuestionCategory.fromJson(c))
          .toList();

      // Initialize disabled categories based on hidden flag
      for (var category in _builtinCategories) {
        if (category.hidden) {
          _disabledCategoryIds.add(category.id);
        }
      }

      // Load Questions
      final qString =
          await rootBundle.loadString('assets/questions/questions.json');
      final qJson = json.decode(qString);
      _builtinQuestions = (qJson['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
    } catch (e) {
      print('Error loading built-in data: $e');
      _builtinCategories = [];
      _builtinQuestions = [];
    }
  }

  /// Load user custom data from local storage
  Future<void> _loadUserData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_userDataFileName');

      if (await file.exists()) {
        final content = await file.readAsString();
        final data = json.decode(content);

        // Load custom categories
        if (data['customCategories'] != null) {
          _customCategories = (data['customCategories'] as List)
              .map((c) => QuestionCategory.fromJson(c))
              .toList();
        }

        // Load custom questions
        if (data['customQuestions'] != null) {
          _customQuestions = (data['customQuestions'] as List)
              .map((q) => Question.fromJson(q))
              .toList();
        }

        // Load disabled categories preference
        if (data['disabledCategoryIds'] != null) {
          _disabledCategoryIds = Set<String>.from(data['disabledCategoryIds']);
        }

        // Load deleted built-in questions
        if (data['deletedBuiltinQuestionIds'] != null) {
          _deletedBuiltinQuestionIds =
              Set<String>.from(data['deletedBuiltinQuestionIds']);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      // If error, start clean
    }
  }

  /// Save user custom data to local storage
  Future<void> _saveUserData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_userDataFileName');

      final data = {
        'customCategories': _customCategories.map((c) => c.toJson()).toList(),
        'customQuestions': _customQuestions.map((q) => q.toJson()).toList(),
        'disabledCategoryIds': _disabledCategoryIds.toList(),
        'deletedBuiltinQuestionIds': _deletedBuiltinQuestionIds.toList(),
      };

      await file.writeAsString(json.encode(data));
      notifyListeners();
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // --- CRUD Operations ---

  /// Add a new custom category
  Future<void> addCategory(QuestionCategory category) async {
    _customCategories.add(category);
    await _saveUserData();
  }

  /// Update an existing custom category
  Future<void> updateCategory(QuestionCategory updatedCategory) async {
    final index =
        _customCategories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      _customCategories[index] = updatedCategory;
      await _saveUserData();
    }
  }

  /// Delete a custom category and its questions
  Future<void> deleteCategory(String categoryId) async {
    _customCategories.removeWhere((c) => c.id == categoryId);
    _customQuestions.removeWhere((q) => q.categoryId == categoryId);
    await _saveUserData();
  }

  /// Add a new custom question
  Future<void> addQuestion(Question question) async {
    _customQuestions.add(question);
    await _saveUserData();

    // Add initial state for the new question
    _questionStates.add(QuestionState(
      questionId: question.id,
      categoryId: question.categoryId,
    ));
    notifyListeners();
  }

  /// Delete a question
  Future<void> deleteQuestion(String questionId) async {
    final customIndex = _customQuestions.indexWhere((q) => q.id == questionId);
    if (customIndex != -1) {
      _customQuestions.removeAt(customIndex);
    } else {
      _deletedBuiltinQuestionIds.add(questionId);
    }

    _questionStates.removeWhere((s) => s.questionId == questionId);
    await _saveUserData();
    notifyListeners();
  }

  /// Toggle visibility of a built-in category
  Future<void> toggleCategoryVisibility(
      String categoryId, bool isVisible) async {
    if (isVisible) {
      _disabledCategoryIds.remove(categoryId);
    } else {
      _disabledCategoryIds.add(categoryId);
    }
    await _saveUserData();
  }

  bool isCategoryEnabled(String categoryId) {
    return !_disabledCategoryIds.contains(categoryId);
  }

  bool isCustomCategory(String categoryId) {
    return _customCategories.any((c) => c.id == categoryId);
  }

  // --- Existing Logic Preserved Below ---

  /// Initialize question states for all questions (unrevealed by default)
  void _initializeQuestionStates() {
    _questionStates = questions
        .map((question) => QuestionState(
              questionId: question.id,
              categoryId: question.categoryId,
            ))
        .toList();
  }

  /// Reset all question states (for new game)
  void resetQuestionStates() {
    _initializeQuestionStates();
    // No need to notify here usually, as this is game logic, but safer to do so
    notifyListeners();
  }

  /// Get all questions for a specific category
  List<Question> getQuestionsByCategory(String categoryId) {
    return questions.where((q) => q.categoryId == categoryId).toList();
  }

  /// Get all unrevealed questions for a specific category
  List<Question> getUnrevealedQuestionsByCategory(String categoryId) {
    final unrevealedIds = _questionStates
        .where((state) => state.categoryId == categoryId && !state.isRevealed)
        .map((state) => state.questionId)
        .toList();

    return questions
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
      orElse: () =>
          QuestionState(questionId: questionId, categoryId: 'unknown'),
    );
    if (questionState.categoryId != 'unknown') {
      questionState.markAsRevealed();
      notifyListeners();
    }
  }

  /// Mark a question as answered
  void markQuestionAsAnswered(String questionId) {
    final questionState = _questionStates.firstWhere(
      (state) => state.questionId == questionId,
      orElse: () =>
          QuestionState(questionId: questionId, categoryId: 'unknown'),
    );
    if (questionState.categoryId != 'unknown') {
      questionState.markAsAnswered();
      notifyListeners();
    }
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
      return categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Get question by ID
  Question? getQuestionById(String questionId) {
    try {
      return questions.firstWhere((question) => question.id == questionId);
    } catch (e) {
      return null;
    }
  }

  /// Get statistics for each category
  Map<String, Map<String, int>> getCategoryStatistics() {
    Map<String, Map<String, int>> stats = {};

    for (var category in categories) {
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

  /// Restore question states from JSON (for loading saved game)
  void restoreQuestionStates(List<dynamic> statesJson) {
    if (statesJson.isEmpty) return;

    print('QuestionService: Restoring ${statesJson.length} question states...');

    for (var json in statesJson) {
      try {
        final state = QuestionState.fromJson(json);
        final index =
            _questionStates.indexWhere((s) => s.questionId == state.questionId);

        if (index != -1) {
          _questionStates[index] = state;
        } else {
          // If for some reason the question doesn't exist in current list, add it
          _questionStates.add(state);
        }
      } catch (e) {
        print('QuestionService: Error restoring state: $e');
      }
    }
    notifyListeners();
  }
}
