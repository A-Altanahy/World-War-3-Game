// lib/models/country.dart

import 'package:flutter/material.dart';
import 'team.dart';

class Country {
  final String id; // Changed from int to String to support custom countries
  String name; // Added name field
  final Offset
      normalizedPosition; // Normalized position (0-1 range) for consistency across different screen sizes
  Team? owner;
  bool isBase; // Whether this country is a base (1000 points instead of 200)

  int captureBonus; // Points added from captures

  Country({
    required this.id,
    required this.name,
    required this.normalizedPosition,
    this.owner,
    this.isBase = false, // Default to false (regular country)
    this.captureBonus = 0,
  });

  // Countries carry 1000 troops if base, 200 if regular, plus any capture bonuses
  int get troops => (isBase ? 1000 : 200) + captureBonus;

  // Backward compatibility: get position (deprecated, use normalizedPosition)
  @Deprecated('Use normalizedPosition instead')
  Offset get position => normalizedPosition;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedPosition': {
        'dx': normalizedPosition.dx,
        'dy': normalizedPosition.dy
      },
      'isBase': isBase,
      'captureBonus': captureBonus,
      // Note: owner is not serialized as it's assigned during game setup
      // Note: troops is calculated based on isBase and captureBonus
    };
  }

  // Create from JSON
  factory Country.fromJson(Map<String, dynamic> json) {
    // Handle both old 'position' format and new 'normalizedPosition' format
    final positionData = json['normalizedPosition'] ?? json['position'];
    return Country(
      id: json['id'],
      name: json['name'],
      normalizedPosition: Offset(positionData['dx'], positionData['dy']),
      isBase: json['isBase'] ?? false, // Default to false if not specified
      captureBonus: json['captureBonus'] ?? 0,
    );
  }

  // Create a copy with updated fields
  Country copyWith({
    String? id,
    String? name,
    Offset? normalizedPosition,
    Team? owner,
    bool? isBase,
    int? captureBonus,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedPosition: normalizedPosition ?? this.normalizedPosition,
      owner: owner ?? this.owner,
      isBase: isBase ?? this.isBase,
      captureBonus: captureBonus ?? this.captureBonus,
    );
  }
}
