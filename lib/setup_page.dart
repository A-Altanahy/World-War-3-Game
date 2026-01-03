// lib/pages/setup_page.dart

import 'package:custom_risk/game_state.dart';
import 'package:custom_risk/models/country.dart';
import 'package:custom_risk/models/country_configuration.dart';
import 'package:custom_risk/models/team.dart';
import 'package:custom_risk/services/question_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'map_page.dart';
import '../models/country_positions.dart'; // Import the country positions
import '../widgets/vector_map.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  int _teamCount = 2;
  final List<Team> _teams = [];

  // Define default colors to ensure unique initial colors
  final List<Color> defaultColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.cyan,
  ];

  // List to hold available maps
  List<CountryConfiguration> _availableMaps = [];
  int _selectedMapIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with default teams and unique colors
    _teams.addAll(List.generate(
        _teamCount,
        (index) => Team(
              name: '',
              color: defaultColors[index % defaultColors.length],
            )));

    // Initialize available maps
    _initializeMaps();
  }

  void _initializeMaps() {
    // Map 1: Full World (42 Countries)
    final fullMapCountries = getInitialCountries(count: 42);
    final fullMap = CountryConfiguration(
      id: 'full_map_42',
      name: 'العالم الكامل (42 دولة)',
      countries: fullMapCountries,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      interactiveMapAsset: 'assets/original_full_map(42).svg',
    );

    // Map 2: Quick World (20 Countries)
    // Note: ensure getQuickMapCountries returns correct IDs matching the SVG
    final quickMapCountries = getQuickMapCountries();
    final quickMap = CountryConfiguration(
      id: 'quick_map_20',
      name: 'معركة سريعة (20 دولة)',
      countries: quickMapCountries,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      interactiveMapAsset: 'assets/original_map(20).svg',
    );

    _availableMaps = [fullMap, quickMap];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateTeamCount(int count) {
    setState(() {
      _teamCount = count;
      if (_teams.length < count) {
        _teams.addAll(List.generate(
            count - _teams.length,
            (index) => Team(
                  name: '',
                  color: defaultColors[
                      (_teams.length + index) % defaultColors.length],
                )));
      } else if (_teams.length > count) {
        _teams.removeRange(count, _teams.length);
      }
    });
  }

  void _selectColor(int index) {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = _teams[index].color;
        return AlertDialog(
          title: const Text('اختر اللون'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Check if the color is already used by another team
                if (_teams.any((team) =>
                    team.color == tempColor && team != _teams[index])) {
                  // SnackBar message removed - color already used
                  return;
                }
                setState(() {
                  _teams[index].color = tempColor;
                  print('Team ${index + 1} color updated to $tempColor');
                });
                Navigator.of(context).pop();
              },
              child: const Text('تم'),
            ),
          ],
        );
      },
    );
  }

  void _proceedToMap() async {
    if (_formKey.currentState!.validate()) {
      // Assign the selected map's countries
      final selectedMap = _availableMaps[_selectedMapIndex];
      // Create fresh copies of countries to avoid state pollution between games
      List<Country> initialCountries = selectedMap.countries.map((country) {
        return Country(
          id: country.id,
          name: country.name,
          normalizedPosition: country.normalizedPosition,
          svgId: country.svgId, // Ensure SVG ID is passed
        );
      }).toList();

      // Initialize GameState
      QuestionService questionService = QuestionService();
      await questionService.initialize();

      GameState gameState = GameState(
        teams: _teams,
        countries: initialCountries,
        questionService: questionService,
        mapAsset: selectedMap.interactiveMapAsset ??
            'assets/original_full_map(42).svg',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: MapPage(mapAsset: gameState.mapAsset),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar to maximize content area
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl, // Ensure RTL layout
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  Center(
                    child: Text(
                      'إعداد لعبة جديدة',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 1. Map Selection
                  Text(
                    'اختر الخريطة:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate card size based on available width
                      final cardWidth = (constraints.maxWidth - 16) / 2;
                      final cardHeight =
                          cardWidth * 0.8; // Slightly shorter than square

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: _availableMaps.asMap().entries.map((entry) {
                          final index = entry.key;
                          final map = entry.value;
                          final isSelected = _selectedMapIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMapIndex = index;
                              });
                            },
                            child: Container(
                              width: cardWidth,
                              height: cardHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.white24,
                                  width: isSelected ? 2 : 1,
                                ),
                                color: Colors.black26,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Map Preview using VectorMap
                                    if (map.interactiveMapAsset != null)
                                      Positioned.fill(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 50),
                                          child: VectorMap(
                                            mapAsset: map.interactiveMapAsset!,
                                            countries: map.countries,
                                            onCountryTap:
                                                (_) {}, // No-op for preview
                                          ),
                                        ),
                                      ),
                                    // Info overlay at bottom
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.8),
                                            ],
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Country count badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${map.countries.length}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.location_on,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            // Map name
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                map.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                textAlign: TextAlign.end,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Selection indicator
                                    if (isSelected)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),

                  // 2. Team Setup
                  Center(
                    child: Text(
                      'إعداد الفرق',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Team Count Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'عدد الفرق:',
                        style: TextStyle(fontSize: 18),
                      ),
                      DropdownButton<int>(
                        value: _teamCount,
                        items: List.generate(6, (index) => index + 2)
                            .map(
                              (count) => DropdownMenuItem(
                                value: count,
                                child: Text('$count'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _updateTeamCount(value);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Team Details
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _teamCount,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الفريق ${index + 1}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              // Team Name
                              TextFormField(
                                initialValue: _teams[index]
                                    .name, // Preserve value on rebuilds
                                decoration: const InputDecoration(
                                  labelText: 'اسم الفريق',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال اسم الفريق';
                                  }
                                  if (_teams
                                          .where((team) => team.name == value)
                                          .length >
                                      1) {
                                    return 'اسم الفريق يجب أن يكون فريدًا';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _teams[index].name = value;
                                },
                              ),
                              const SizedBox(height: 10),
                              // Team Color
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'لون الفريق:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  GestureDetector(
                                    onTap: () => _selectColor(index),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: _teams[index].color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Next Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _proceedToMap,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('بداية اللعبة'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
