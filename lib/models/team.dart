// lib/models/team.dart

import 'package:flutter/material.dart';

class Team {
  String name;
  Color color;
  int defensePoints; // Permanent points earned from defending

  Team({required this.name, required this.color, this.defensePoints = 0});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.value,
      'defensePoints': defensePoints,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'],
      color: Color(json['color']),
      defensePoints: json['defensePoints'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          color == other.color;

  @override
  int get hashCode => name.hashCode ^ color.hashCode;
}
