import 'package:custom_risk/models/country.dart';
import 'package:flutter/material.dart';

// These positions are now normalized (0-1 range) based on SVG dimensions of 900x600
final List<Map<String, dynamic>> countryPositions = [
  {
    "id": 1,
    "position": const Offset(85.0 / 900.0, 95.0 / 600.0),
    "svgId": "NorthAmerica-1"
  }, // Alaska/Western North America
  {
    "id": 2,
    "position": const Offset(160.0 / 900.0, 95.0 / 600.0),
    "svgId": "NorthAmerica"
  }, // Central North America/Canada
  {
    "id": 3,
    "position": const Offset(165.0 / 900.0, 140.0 / 600.0),
    "svgId": "NortAmerica-1"
  }, // Eastern North America/USA East Coast
  {
    "id": 4,
    "position": const Offset(155.0 / 900.0, 200.0 / 600.0),
    "svgId": "NorthAmerica_2"
  }, // Mexico/Central America
  {
    "id": 5,
    "position": const Offset(215.0 / 900.0, 155.0 / 600.0),
    "svgId": "greenland"
  }, // Greenland
  {
    "id": 6,
    "position": const Offset(273.0 / 900.0, 155.0 / 600.0),
    "svgId": "iceland"
  }, // Iceland/Northern Europe
  {
    "id": 7,
    "position": const Offset(225.0 / 900.0, 220.0 / 600.0),
    "svgId": "NorthAmerica_2"
  }, // Caribbean/Central America - Reusing NA_2 roughly or check for specific island ID but generic works for now
  {
    "id": 8,
    "position": const Offset(170.0 / 900.0, 280.0 / 600.0),
    "svgId": "SouthAmerica"
  }, // Northern South America/Venezuela
  {
    "id": 9,
    "position": const Offset(325.0 / 900.0, 65.0 / 600.0),
    "svgId": "scandinavia"
  }, // Northern Europe/Scandinavia
  {
    "id": 10,
    "position": const Offset(220.0 / 900.0, 330.0 / 600.0),
    "svgId": "brazil"
  }, // Brazil/Central South America
  {
    "id": 11,
    "position": const Offset(390.0 / 900.0, 125.0 / 600.0),
    "svgId": "Europ"
  }, // Western Europe/France
  {
    "id": 12,
    "position": const Offset(375.0 / 900.0, 180.0 / 600.0),
    "svgId": "Europ_2"
  }, // Southern Europe/Italy
  {
    "id": 13,
    "position": const Offset(245.0 / 900.0, 410.0 / 600.0),
    "svgId": "SouthAmerica_2"
  }, // Argentina/Southern South America
  {
    "id": 14,
    "position": const Offset(465.0 / 900.0, 110.0 / 600.0),
    "svgId": "Europ-2"
  }, // Eastern Europe/Poland
  {
    "id": 15,
    "position": const Offset(290.0 / 900.0, 380.0 / 600.0),
    "svgId": "Africa"
  }, // West Africa
  {
    "id": 16,
    "position": const Offset(390.0 / 900.0, 280.0 / 600.0),
    "svgId": "north_africa"
  }, // North Africa/Egypt
  {
    "id": 17,
    "position": const Offset(460.0 / 900.0, 245.0 / 600.0),
    "svgId": "middle_east"
  }, // Middle East/Turkey
  {
    "id": 18,
    "position": const Offset(240.0 / 900.0, 480.0 / 600.0),
    "svgId": "Africa_2"
  }, // South Africa
  {
    "id": 19,
    "position": const Offset(520.0 / 900.0, 170.0 / 600.0),
    "svgId": "Asia"
  }, // Western Russia/Eastern Europe - Reusing Asia as generic if no specific Rus ID found in quick check
  {
    "id": 20,
    "position": const Offset(420.0 / 900.0, 360.0 / 600.0),
    "svgId": "Africa"
  }, // East Africa/Ethiopia - Reuse Africa
  {
    "id": 21,
    "position": const Offset(485.0 / 900.0, 340.0 / 600.0),
    "svgId": "middle_east"
  }, // Arabian Peninsula/Saudi Arabia - Reuse ME
  {
    "id": 22,
    "position": const Offset(550.0 / 900.0, 300.0 / 600.0),
    "svgId": "middle_east"
  }, // Central Asia/Iran - Reuse ME or Asia
  {
    "id": 23,
    "position": const Offset(600.0 / 900.0, 215.0 / 600.0),
    "svgId": "Asia"
  }, // Central Russia/Siberia
  {
    "id": 24,
    "position": const Offset(620.0 / 900.0, 150.0 / 600.0),
    "svgId": "yakursk"
  }, // Western Siberia - Yakursk match
  {
    "id": 25,
    "position": const Offset(490.0 / 900.0, 430.0 / 600.0),
    "svgId": "Africa_2"
  }, // Madagascar - Fallback to Africa_2
  {
    "id": 26,
    "position": const Offset(650.0 / 900.0, 100.0 / 600.0),
    "svgId": "Asia"
  }, // Northern Siberia
  {
    "id": 27,
    "position": const Offset(530.0 / 900.0, 400.0 / 600.0),
    "svgId": "india"
  }, // Southern India
  {
    "id": 28,
    "position": const Offset(490.0 / 900.0, 500.0 / 600.0),
    "svgId": "Australia"
  }, // Southern Ocean Islands - Likely part of Aus or Antartica, using Aus placeholder
  {
    "id": 29,
    "position": const Offset(640.0 / 900.0, 300.0 / 600.0),
    "svgId": "Asia"
  }, // Central Asia/Afghanistan
  {
    "id": 30,
    "position": const Offset(720.0 / 900.0, 85.0 / 600.0),
    "svgId": "Asia"
  }, // Eastern Siberia/Mongolia
  {
    "id": 31,
    "position": const Offset(680.0 / 900.0, 260.0 / 600.0),
    "svgId": "Asia_2"
  }, // Western China
  {
    "id": 32,
    "position": const Offset(715.0 / 900.0, 145.0 / 600.0),
    "svgId": "Asia"
  }, // Northern China/Mongolia
  {
    "id": 33,
    "position": const Offset(725.0 / 900.0, 205.0 / 600.0),
    "svgId": "Asia_2"
  }, // Eastern China
  {
    "id": 34,
    "position": const Offset(715.0 / 900.0, 325.0 / 600.0),
    "svgId": "Asia_2"
  }, // Southeast Asia/Thailand
  {
    "id": 35,
    "position": const Offset(790.0 / 900.0, 85.0 / 600.0),
    "svgId": "Asia"
  }, // Eastern Russia/Far East
  {
    "id": 36,
    "position": const Offset(725.0 / 900.0, 425.0 / 600.0),
    "svgId": "Asia_2"
  }, // Southern Southeast Asia
  {
    "id": 37,
    "position": const Offset(805.0 / 900.0, 400.0 / 600.0),
    "svgId": "indonesia"
  }, // Indonesia/Java
  {
    "id": 38,
    "position": const Offset(765.0 / 900.0, 500.0 / 600.0),
    "svgId": "new_guinea"
  }, // Southern Indonesia/Sumatra -> Using New Guinea ID since it's nearby and distinct
  {
    "id": 39,
    "position": const Offset(820.0 / 900.0, 480.0 / 600.0),
    "svgId": "Australia"
  }, // Australia
  // Ukraine/Eastern Europe
  {
    "id": 40,
    "position": const Offset(450.0 / 900.0, 190.0 / 600.0),
    "svgId": "ukraine"
  },
  // Added Countries 41 & 42 mapped to Vector IDs as requested
  {
    "id": 41,
    "position":
        const Offset(500.0 / 900.0, 500.0 / 600.0), // Placeholder position
    "svgId": "Vector_60"
  },
  {
    "id": 42,
    "position":
        const Offset(550.0 / 900.0, 500.0 / 600.0), // Placeholder position
    "svgId": "Vector_63"
  }
];

List<Country> getInitialCountries() {
  return countryPositions.asMap().entries.map((entry) {
    final index = entry.key;
    final countryData = entry.value;
    return Country(
      id: countryData["id"].toString(),
      name: 'Country ${index + 1}', // Default name
      normalizedPosition: countryData["position"],
      svgId:
          'Country${countryData["id"]}', // Updated to match Figma naming: Country1, Country2...
    );
  }).toList();
}

List<Country> getQuickMapCountries() {
  final List<Map<String, dynamic>> quickMapData = [
    {
      "id": "NorthAmerica",
      "name": "North America",
      "pos": const Offset(0.2, 0.2)
    },
    {
      "id": "SouthAmerica",
      "name": "South America",
      "pos": const Offset(0.2, 0.6)
    },
    {"id": "Europ", "name": "Europe", "pos": const Offset(0.45, 0.3)},
    {"id": "Africa", "name": "Africa", "pos": const Offset(0.45, 0.5)},
    {"id": "Asia", "name": "Asia", "pos": const Offset(0.7, 0.3)},
    {"id": "Australia", "name": "Australia", "pos": const Offset(0.8, 0.7)},
    {"id": "indonesia", "name": "Indonesia", "pos": const Offset(0.75, 0.6)},
    {"id": "new_guinea", "name": "New Guinea", "pos": const Offset(0.85, 0.6)},
    {"id": "greenland", "name": "Greenland", "pos": const Offset(0.35, 0.1)},
    {"id": "iceland", "name": "Iceland", "pos": const Offset(0.40, 0.15)},
    {
      "id": "scandinavia",
      "name": "Scandinavia",
      "pos": const Offset(0.45, 0.15)
    },
    {"id": "ukraine", "name": "Ukraine", "pos": const Offset(0.5, 0.25)},
    {
      "id": "middle_east",
      "name": "Middle East",
      "pos": const Offset(0.55, 0.4)
    },
    {
      "id": "north_africa",
      "name": "North Africa",
      "pos": const Offset(0.45, 0.45)
    },
    {"id": "brazil", "name": "Brazil", "pos": const Offset(0.25, 0.65)},
    {"id": "india", "name": "India", "pos": const Offset(0.65, 0.45)},
  ];

  return quickMapData.asMap().entries.map((entry) {
    var data = entry.value;
    return Country(
      id: (entry.key + 100).toString(),
      name: data['name'],
      normalizedPosition: data['pos'],
      svgId: 'Country${entry.key + 1}',
    );
  }).toList();
}
