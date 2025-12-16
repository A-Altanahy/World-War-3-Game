// lib/game_state.dart

import 'package:flutter/material.dart';
import 'models/country.dart';
import 'models/team.dart';
import 'services/question_service.dart';

class GameState with ChangeNotifier {
  final List<Team> teams;
  final List<Country> countries;
  final QuestionService questionService;
  Team? selectedTeam; // Currently selected team

  GameState({
    required this.teams,
    required this.countries,
    required this.questionService,
  });

  // Method to select a team
  void selectTeam(Team team) {
    selectedTeam = team;
    notifyListeners();
  }

  // Method to assign a country to a team
  void assignCountryToTeam(Country country, Team? team) {
    country.owner = team;
    notifyListeners();
  }

  // Calculate total points for each team (sum of all owned countries' troops)
  Map<Team, int> get teamPoints {
    Map<Team, int> points = {};
    for (var team in teams) {
      int totalPoints = countries
          .where((country) => country.owner == team)
          .fold(0, (sum, country) => sum + country.troops);
      points[team] = totalPoints;
    }
    return points;
  }

  // Toggle base status for a country
  void toggleCountryBase(String countryId) {
    final country = countries.firstWhere((c) => c.id == countryId);
    country.isBase = !country.isBase;
    notifyListeners();
  }

  // Set base status for a country
  void setCountryBase(String countryId, bool isBase) {
    final country = countries.firstWhere((c) => c.id == countryId);
    country.isBase = isBase;
    notifyListeners();
  }
}
