// lib/pages/setup_page.dart

import 'package:custom_risk/game_state.dart';
import 'package:custom_risk/models/country.dart';
import 'package:custom_risk/models/team.dart';
import 'package:custom_risk/services/question_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'map_page.dart';
import 'services/game_storage_service.dart';
import '../models/country_positions.dart'; // Import the country positions

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

  // List to hold initial countries
  List<Country> _initialCountries = [];

  bool _hasSaveGame = false;

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
    // Initialize countries from country_positions.dart
    _initialCountries = getInitialCountries();
    _checkForSaveGame();
  }

  Future<void> _checkForSaveGame() async {
    final storage = GameStorageService();
    final hasSave = await storage.hasSaveGame(1);
    if (mounted) {
      setState(() {
        _hasSaveGame = hasSave;
      });
    }
  }

  Future<void> _continueGame() async {
    final storage = GameStorageService();
    final json = await storage.loadGame(1);

    if (json != null && mounted) {
      // Initialize GameState with placeholders, then restore
      QuestionService questionService = QuestionService();
      await questionService.initialize();

      // We need to initialize with some empty data first
      // The restoreState method will handle clearing and repopulating
      GameState gameState = GameState(
        teams: [],
        countries: _initialCountries
            .map((c) => Country(
                id: c.id,
                name: c.name,
                normalizedPosition: c.normalizedPosition))
            .toList(),
        questionService: questionService,
      );

      gameState.restoreState(json);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: const MapPage(slotId: 1),
          ),
        ),
      );
    }
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
      // Assign the loaded countries
      List<Country> initialCountries = _initialCountries.map((country) {
        return Country(
          id: country.id,
          name: country.name,
          normalizedPosition: country.normalizedPosition,
        );
      }).toList();

      // Initialize GameState
      QuestionService questionService = QuestionService();
      await questionService.initialize();

      GameState gameState = GameState(
        teams: _teams,
        countries: initialCountries,
        questionService: questionService,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider<GameState>.value(
            value: gameState,
            child: const MapPage(),
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
                  if (_hasSaveGame) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _continueGame,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('اكمال اللعبة السابقة'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.grey),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'إعداد الفرق (لعبة جديدة)',
                      style: Theme.of(context).textTheme.headlineMedium,
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
                                  print('Team ${index + 1} name set to $value');
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
                      child: const Text('التالي'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
