// lib/pages/team_setup_page.dart

import 'package:custom_risk/game_state.dart';
import 'package:custom_risk/models/country.dart';
import 'package:custom_risk/models/team.dart';
import 'package:custom_risk/services/question_service.dart';
import 'package:custom_risk/theme/app_theme.dart';
import 'package:custom_risk/widgets/command_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../map_page.dart';
import '../models/country_configuration.dart';

class TeamSetupPage extends StatefulWidget {
  final CountryConfiguration configuration;

  const TeamSetupPage({super.key, required this.configuration});

  @override
  State<TeamSetupPage> createState() => _TeamSetupPageState();
}

class _TeamSetupPageState extends State<TeamSetupPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  int _teamCount = 2;
  final List<Team> _teams = [];
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Enhanced color palette for command center theme
  final List<Color> commandColors = [
    AppTheme.primaryNeon, // Neon Green
    AppTheme.secondaryNeon, // Neon Pink
    AppTheme.accentOrange, // Neon Orange
    const Color(0xFF9D4EDD), // Neon Purple
    const Color(0xFF06D6A0), // Teal
    const Color(0xFFFFD60A), // Electric Yellow
    const Color(0xFF003566), // Dark Blue
    const Color(0xFFDC2F02), // Electric Red
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTeams();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  void _initializeTeams() {
    _teams.addAll(List.generate(
      _teamCount,
      (index) => Team(
        name: '',
        color: commandColors[index % commandColors.length],
      ),
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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
            color:
                commandColors[(_teams.length + index) % commandColors.length],
          ),
        ));
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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: CommandCard(
            width: 350,
            height: 500,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'اختر اللون التكتيكي',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.primaryNeon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Color Picker
                Expanded(
                  child: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: tempColor,
                      onColorChanged: (color) {
                        tempColor = color;
                      },
                      colorPickerWidth: 280,
                      pickerAreaHeightPercent: 0.8,
                      enableAlpha: false,
                      displayThumbColor: true,
                      paletteType: PaletteType.hueWheel,
                      labelTypes: const [],
                      pickerAreaBorderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeonButton(
                        text: 'تأكيد',
                        height: 45,
                        onPressed: () {
                          // Check if the color is already used
                          if (_teams.any((team) =>
                              team.color == tempColor &&
                              team != _teams[index])) {
                            // Error message removed
                            return;
                          }

                          setState(() {
                            _teams[index].color = tempColor;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Error SnackBar function removed

  void _startGame() async {
    if (!_formKey.currentState!.validate()) {
      // Error message removed
      return;
    }

    if (_teams.any((team) => team.name.trim().isEmpty)) {
      // Error message removed
      return;
    }

    // Check for duplicate names
    final names = _teams.map((t) => t.name.trim().toLowerCase()).toList();
    if (names.toSet().length != names.length) {
      // Error message removed
      return;
    }

    // Create countries from configuration
    final countries = widget.configuration.countries
        .map((country) => Country(
              id: country.id,
              name: country.name,
              normalizedPosition: country.normalizedPosition,
              isBase: country.isBase,
            ))
        .toList();

    // Initialize question service
    final questionService = QuestionService();
    await questionService.initialize();

    // Create game state
    final gameState = GameState(
      teams: _teams,
      countries: countries,
      questionService: questionService,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ChangeNotifierProvider.value(
            value: gameState,
            child: const MapPage(),
          ),
          transitionDuration: const Duration(milliseconds: 1200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                )),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Form(
                  key: _formKey,
                  child: CustomScrollView(
                    slivers: [
                      _buildHeader(),
                      _buildTeamCountSelector(),
                      _buildTeamCards(),
                      _buildStartButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Back button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryNeon,
                      width: 2,
                    ),
                    boxShadow: AppTheme.neonShadow,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppTheme.primaryNeon,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Title section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryNeon,
                      width: 2,
                    ),
                    boxShadow: AppTheme.neonShadow,
                  ),
                  child: const Icon(
                    Icons.groups,
                    color: AppTheme.primaryNeon,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إعداد القوات',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Team Setup Command',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textMuted,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryNeon.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryNeon.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'قم بإعداد الفرق المشاركة في المعركة الاستراتيجية\nحدد عدد الفرق وأسماءها وألوانها التكتيكية',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCountSelector() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: CommandCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.military_tech,
                    color: AppTheme.primaryNeon,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'عدد القوات المشاركة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'العدد: ',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.neonShadow,
                    ),
                    child: Text(
                      '$_teamCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: _teamCount.toDouble(),
                min: 2,
                max: 8,
                divisions: 6,
                label: '$_teamCount فريق',
                onChanged: (value) => _updateTeamCount(value.round()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCards() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildTeamCard(index),
          childCount: _teamCount,
        ),
      ),
    );
  }

  Widget _buildTeamCard(int index) {
    final team = _teams[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CommandCard(
        padding: const EdgeInsets.all(20),
        glowColor: team.color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: team.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: team.color.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'القوة ${index + 1}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Force Unit ${index + 1}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textMuted,
                              letterSpacing: 1.1,
                            ),
                      ),
                    ],
                  ),
                ),
                NeonButton(
                  text: 'تغيير اللون',
                  color: team.color,
                  textColor: Colors.white,
                  width: 120,
                  height: 40,
                  onPressed: () => _selectColor(index),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Team name input
            TextFormField(
              initialValue: team.name,
              decoration: InputDecoration(
                labelText: 'اسم القوة',
                hintText: 'أدخل اسم القوة التكتيكية...',
                prefixIcon: Icon(
                  Icons.military_tech,
                  color: team.color,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: team.color),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: team.color, width: 2),
                ),
              ),
              style: TextStyle(color: AppTheme.textPrimary),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم القوة';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  team.name = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        child: NeonButton(
          text: 'بدء المعركة الاستراتيجية',
          icon: Icons.rocket_launch,
          height: 60,
          width: double.infinity,
          color: AppTheme.primaryNeon,
          textColor: Colors.black,
          onPressed: _startGame,
        ),
      ),
    );
  }
}
