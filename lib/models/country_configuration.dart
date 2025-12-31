// lib/models/country_configuration.dart

import 'dart:convert';
import 'country.dart';

class CountryConfiguration {
  final String id;
  final String name;
  final List<Country> countries;
  final DateTime createdAt;
  final DateTime lastModified;
  final String?
      interactiveMapAsset; // Path to a custom SVG asset if this config uses interactive regions

  CountryConfiguration({
    required this.id,
    required this.name,
    required this.countries,
    required this.createdAt,
    required this.lastModified,
    this.interactiveMapAsset,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'countries': countries.map((country) => country.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'interactiveMapAsset': interactiveMapAsset,
    };
  }

  // Create from JSON
  factory CountryConfiguration.fromJson(Map<String, dynamic> json) {
    return CountryConfiguration(
      id: json['id'],
      name: json['name'],
      countries: (json['countries'] as List)
          .map((countryJson) => Country.fromJson(countryJson))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
      interactiveMapAsset: json['interactiveMapAsset'],
    );
  }

  // Convert to/from JSON string for shared preferences
  String toJsonString() => jsonEncode(toJson());

  factory CountryConfiguration.fromJsonString(String jsonString) {
    return CountryConfiguration.fromJson(jsonDecode(jsonString));
  }

  // Create a copy with updated fields
  CountryConfiguration copyWith({
    String? id,
    String? name,
    List<Country>? countries,
    DateTime? createdAt,
    DateTime? lastModified,
    String? interactiveMapAsset,
  }) {
    return CountryConfiguration(
      id: id ?? this.id,
      name: name ?? this.name,
      countries: countries ?? this.countries,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      interactiveMapAsset: interactiveMapAsset ?? this.interactiveMapAsset,
    );
  }
}
