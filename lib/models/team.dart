// lib/models/team.dart

import 'package:flutter/material.dart';

class Team {
  String name;
  Color color;

  Team({required this.name, required this.color});

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
