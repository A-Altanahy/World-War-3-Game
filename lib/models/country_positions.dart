import 'package:custom_risk/models/country.dart';
import 'package:flutter/material.dart';

// These positions are now normalized (0-1 range) based on SVG dimensions of 900x600
final List<Map<String, dynamic>> countryPositions = [
  {
    "id": 1,
    "position": const Offset(85.0 / 900.0, 95.0 / 600.0)
  }, // Alaska/Western North America
  {
    "id": 2,
    "position": const Offset(160.0 / 900.0, 95.0 / 600.0)
  }, // Central North America/Canada
  {
    "id": 3,
    "position": const Offset(165.0 / 900.0, 140.0 / 600.0)
  }, // Eastern North America/USA East Coast
  {
    "id": 4,
    "position": const Offset(155.0 / 900.0, 200.0 / 600.0)
  }, // Mexico/Central America
  {
    "id": 5,
    "position": const Offset(215.0 / 900.0, 155.0 / 600.0)
  }, // Greenland
  {
    "id": 6,
    "position": const Offset(273.0 / 900.0, 155.0 / 600.0)
  }, // Iceland/Northern Europe
  {
    "id": 7,
    "position": const Offset(225.0 / 900.0, 220.0 / 600.0)
  }, // Caribbean/Central America
  {
    "id": 8,
    "position": const Offset(170.0 / 900.0, 280.0 / 600.0)
  }, // Northern South America/Venezuela
  {
    "id": 9,
    "position": const Offset(325.0 / 900.0, 65.0 / 600.0)
  }, // Northern Europe/Scandinavia
  {
    "id": 10,
    "position": const Offset(220.0 / 900.0, 330.0 / 600.0)
  }, // Brazil/Central South America
  {
    "id": 11,
    "position": const Offset(390.0 / 900.0, 125.0 / 600.0)
  }, // Western Europe/France
  {
    "id": 12,
    "position": const Offset(375.0 / 900.0, 180.0 / 600.0)
  }, // Southern Europe/Italy
  {
    "id": 13,
    "position": const Offset(245.0 / 900.0, 410.0 / 600.0)
  }, // Argentina/Southern South America
  {
    "id": 14,
    "position": const Offset(465.0 / 900.0, 110.0 / 600.0)
  }, // Eastern Europe/Poland
  {
    "id": 15,
    "position": const Offset(290.0 / 900.0, 380.0 / 600.0)
  }, // West Africa
  {
    "id": 16,
    "position": const Offset(390.0 / 900.0, 280.0 / 600.0)
  }, // North Africa/Egypt
  {
    "id": 17,
    "position": const Offset(460.0 / 900.0, 245.0 / 600.0)
  }, // Middle East/Turkey
  {
    "id": 18,
    "position": const Offset(240.0 / 900.0, 480.0 / 600.0)
  }, // South Africa
  {
    "id": 19,
    "position": const Offset(520.0 / 900.0, 170.0 / 600.0)
  }, // Western Russia/Eastern Europe
  {
    "id": 20,
    "position": const Offset(420.0 / 900.0, 360.0 / 600.0)
  }, // East Africa/Ethiopia
  {
    "id": 21,
    "position": const Offset(485.0 / 900.0, 340.0 / 600.0)
  }, // Arabian Peninsula/Saudi Arabia
  {
    "id": 22,
    "position": const Offset(550.0 / 900.0, 300.0 / 600.0)
  }, // Central Asia/Iran
  {
    "id": 23,
    "position": const Offset(600.0 / 900.0, 215.0 / 600.0)
  }, // Central Russia/Siberia
  {
    "id": 24,
    "position": const Offset(620.0 / 900.0, 150.0 / 600.0)
  }, // Western Siberia
  {
    "id": 25,
    "position": const Offset(490.0 / 900.0, 430.0 / 600.0)
  }, // Madagascar
  {
    "id": 26,
    "position": const Offset(650.0 / 900.0, 100.0 / 600.0)
  }, // Northern Siberia
  {
    "id": 27,
    "position": const Offset(530.0 / 900.0, 400.0 / 600.0)
  }, // Southern India
  {
    "id": 28,
    "position": const Offset(490.0 / 900.0, 500.0 / 600.0)
  }, // Southern Ocean Islands
  {
    "id": 29,
    "position": const Offset(640.0 / 900.0, 300.0 / 600.0)
  }, // Central Asia/Afghanistan
  {
    "id": 30,
    "position": const Offset(720.0 / 900.0, 85.0 / 600.0)
  }, // Eastern Siberia/Mongolia
  {
    "id": 31,
    "position": const Offset(680.0 / 900.0, 260.0 / 600.0)
  }, // Western China
  {
    "id": 32,
    "position": const Offset(715.0 / 900.0, 145.0 / 600.0)
  }, // Northern China/Mongolia
  {
    "id": 33,
    "position": const Offset(725.0 / 900.0, 205.0 / 600.0)
  }, // Eastern China
  {
    "id": 34,
    "position": const Offset(715.0 / 900.0, 325.0 / 600.0)
  }, // Southeast Asia/Thailand
  {
    "id": 35,
    "position": const Offset(790.0 / 900.0, 85.0 / 600.0)
  }, // Eastern Russia/Far East
  {
    "id": 36,
    "position": const Offset(725.0 / 900.0, 425.0 / 600.0)
  }, // Southern Southeast Asia
  {
    "id": 37,
    "position": const Offset(805.0 / 900.0, 400.0 / 600.0)
  }, // Indonesia/Java
  {
    "id": 38,
    "position": const Offset(765.0 / 900.0, 500.0 / 600.0)
  }, // Southern Indonesia/Sumatra
  {
    "id": 39,
    "position": const Offset(820.0 / 900.0, 480.0 / 600.0)
  }, // Australia
  {
    "id": 40,
    "position": const Offset(450.0 / 900.0, 190.0 / 600.0)
  } // Ukraine/Eastern Europe
];

List<Country> getInitialCountries() {
  return countryPositions.asMap().entries.map((entry) {
    final index = entry.key;
    final countryData = entry.value;
    return Country(
      id: countryData["id"].toString(),
      name: 'Country ${index + 1}', // Default name
      normalizedPosition: countryData["position"],
    );
  }).toList();
}
