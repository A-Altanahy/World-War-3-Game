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
  int currentTeamIndex = 0;

  // Persist the map asset used for this game
  final String mapAsset;

  GameState({
    required this.teams,
    required this.countries,
    required this.questionService,
    this.mapAsset =
        'assets/original_full_map(42).svg', // Default for backward compatibility
  });

  // Method to select a team
  void selectTeam(Team team) {
    selectedTeam = team;
    notifyListeners();
  }

  // Game Phases
  GamePhase _phase = GamePhase.distribution;
  GamePhase get phase => _phase;

  void startWar() {
    _phase = GamePhase.war;
    notifyListeners();
  }

  // Method to assign a country to a team
  void assignCountryToTeam(Country country, Team? team) {
    Team? previousOwner = country.owner;

    if (_phase == GamePhase.war) {
      if (previousOwner != null && previousOwner != team) {
        // Country captured from another team in war phase

        // Check for Base Cascade: If a base is captured, all other lands of the previous owner
        // are transferred to the new owner (without bonus).
        if (country.isBase && team != null) {
          // Check if the previous owner has any OTHER bases remaining
          bool hasOtherBases = countries.any((c) =>
              c.owner == previousOwner && c.isBase && c.id != country.id);

          // Only trigger cascade if this was their LAST/ONLY base
          if (!hasOtherBases) {
            // Transfer all other countries
            final cascadingCountries = countries
                .where((c) => c.owner == previousOwner && c.id != country.id)
                .toList();

            for (var c in cascadingCountries) {
              c.owner = team;
              // Note: No capture bonus for cascaded captures as per rules
            }
          }
        }

        // Increase value by 50 points for the captured land itself
        // BASES do not get the +50 bonus
        if (!country.isBase) {
          country.captureBonus += 50;
        }
      }
    }

    country.owner = team;
    notifyListeners();
  }

  // Manually update points for a country (Correction mode)
  void updateCountryPoints(Country country, int newTotalPoints) {
    int baseValue = country.isBase ? 1000 : 200;
    // Calculate required bonus to hit the target total
    country.captureBonus = newTotalPoints - baseValue;
    notifyListeners();
  }

  // Calculate total points for each team
  // Sum of all owned countries' troops + permanent defense points
  Map<Team, int> get teamPoints {
    Map<Team, int> points = {};
    for (var team in teams) {
      int landPoints = countries
          .where((country) => country.owner == team)
          .fold(0, (sum, country) => sum + country.troops);
      points[team] = landPoints + team.defensePoints;
    }
    return points;
  }

  // Defend a country: adds 50 permanent points to the owner team
  void defendCountry(Country country) {
    if (country.owner != null) {
      country.owner!.defensePoints += 50;
      notifyListeners();
    }
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

  // Serialize GameState to JSON
  Map<String, dynamic> toJson() {
    return {
      'teams': teams.map((t) => t.toJson()).toList(),
      'countries': countries.map((c) {
        // We need to store who owns it by team name (assuming unique names) or index
        // Since we restore teams first, we can match by name
        var json = c.toJson();
        if (c.owner != null) {
          json['ownerName'] = c.owner!.name;
        }
        return json;
      }).toList(),
      'phase': _phase.index,
      'mapAsset': mapAsset,
      'questionStates':
          questionService.questionStates.map((s) => s.toJson()).toList(),
    };
  }

  // Restore state from JSON
  void restoreState(Map<String, dynamic> json) {
    // 1. Restore Teams
    final teamsList =
        (json['teams'] as List).map((t) => Team.fromJson(t)).toList();
    teams.clear();
    teams.addAll(teamsList);

    // 2. Restore Countries
    final countriesList = (json['countries'] as List);
    print('RestoreState: Processing ${countriesList.length} saved countries');

    int matchedCount = 0;
    for (var countryJson in countriesList) {
      final countryId = countryJson['id'];

      // Try to find the country
      Country? country;
      try {
        country = countries.firstWhere((c) => c.id == countryId.toString());
      } catch (e) {
        country = null;
      }

      if (country != null) {
        matchedCount++;
        // Update stats
        country.isBase = countryJson['isBase'] ?? false;

        // Restore troops count logic
        // Troops are calculated as (isBase ? 1000 : 200) + captureBonus
        // So we need to reverse calculate the captureBonus to match the saved troops
        int savedTroops = countryJson['troops'] ?? 0;
        int baseValue = country.isBase ? 1000 : 200;
        if (savedTroops > 0) {
          country.captureBonus = savedTroops - baseValue;
        } else {
          country.captureBonus = countryJson['captureBonus'] ?? 0;
        }

        // Restore owner
        final ownerName = countryJson['ownerName'];
        if (ownerName != null) {
          try {
            country.owner = teams.firstWhere((t) => t.name == ownerName);
          } catch (e) {
            print(
                'RestoreState: Warning - Team $ownerName not found for country $countryId');
            country.owner = null;
          }
        } else {
          country.owner = null;
        }
      } else {
        // Debug log for first few mismatches?
        // print('RestoreState: Could not find country with ID: $countryId in current map');
      }
    }
    print(
        'RestoreState: Successfully matched $matchedCount out of ${countriesList.length} saved records against ${countries.length} game countries.');

    // 3. Restore Phase
    final phaseIndex = json['phase'] ?? 0;
    _phase = GamePhase.values[phaseIndex];

    // 4. Restore Question States
    if (json.containsKey('questionStates')) {
      final questionStates = json['questionStates'] as List;
      questionService.restoreQuestionStates(questionStates);
    }

    notifyListeners();
  }
}

enum GamePhase {
  distribution,
  war,
}
