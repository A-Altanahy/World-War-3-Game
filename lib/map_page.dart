// lib/map_page.dart

import 'package:custom_risk/game_state.dart';
import 'package:custom_risk/theme/app_theme.dart';
import 'package:custom_risk/utils/fullscreen_helper.dart';
import 'package:custom_risk/widgets/command_card.dart';
import 'package:custom_risk/widgets/vector_map.dart';
import 'package:custom_risk/widgets/question_dialog.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'services/game_storage_service.dart';

class MapPage extends StatefulWidget {
  final int slotId;
  final String mapAsset;

  const MapPage({
    super.key,
    this.slotId = 1,
    required this.mapAsset, // Now required to support different maps
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _statsController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _statsAnimation;

  bool _showStats = true;

  void _onFullscreenChanged() {
    setState(() {
      // This will trigger a rebuild when fullscreen state changes
    });
  }

  @override
  void initState() {
    super.initState();
    FullscreenHelper.addListener(_onFullscreenChanged);
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    // Disable pulse animation to reduce noise
    // _pulseController.repeat(reverse: true);
    _statsController.forward();
  }

  @override
  void dispose() {
    FullscreenHelper.removeListener(_onFullscreenChanged);
    _fadeController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  void _onCountryTap(BuildContext context, country) {
    final gameState = Provider.of<GameState>(context, listen: false);
    _showCommandDialog(context, gameState, country);
  }

  void _showCommandDialog(BuildContext context, GameState gameState, country) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: CommandCard(
            width: 400,
            height: 500,
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'عمليات تكتيكية',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'المنطقة: ${country.name}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.primaryNeon,
                                  ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryNeon),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppTheme.primaryNeon,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Base status toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentOrange.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentOrange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            country.isBase ? Icons.star : Icons.star_border,
                            color: country.isBase
                                ? AppTheme.accentOrange
                                : AppTheme.textMuted,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  country.isBase
                                      ? 'قاعدة استراتيجية'
                                      : 'منطقة عادية',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${country.troops} نقطة قتالية',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppTheme.primaryNeon
                                                .withOpacity(0.5)),
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          await _showEditPointsDialog(
                                              context, gameState, country);
                                          // Rebuild dialog to show new points
                                          setState(() {});
                                        },
                                        customBorder: const CircleBorder(),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: AppTheme.primaryNeon,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: country.isBase,
                            activeColor: AppTheme.accentOrange,
                            onChanged: (value) {
                              setState(() {
                                gameState.toggleCountryBase(country.id);
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Defend Button (Only for owner in War Phase)
                    if (gameState.phase == GamePhase.war &&
                        country.owner != null &&
                        country.owner!.name.isNotEmpty) ...[
                      // We check name.isNotEmpty as a proxy for valid team logic,
                      // simpler check is just owner != null.
                      // Ideally checking if owner is the "current player" but we simulate hotseat
                      // so we show it if the country is owned.
                      NeonButton(
                        text: 'دفاع (+50 للفريق)',
                        icon: Icons.shield,
                        color: AppTheme.primaryNeon,
                        textColor: Colors.black,
                        height: 45,
                        width: double.infinity,
                        onPressed: () {
                          gameState.defendCountry(country);
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Team assignment section
                    Text(
                      'تعيين القوة المسيطرة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: ListView.builder(
                        itemCount: gameState.teams.length,
                        itemBuilder: (context, index) {
                          final team = gameState.teams[index];

                          // In war phase, don't show the current owner in the list
                          // This forces the user to choose a different team (attacker)
                          if (gameState.phase == GamePhase.war &&
                              country.owner == team) {
                            return const SizedBox.shrink();
                          }

                          final isSelected = country.owner == team;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: NeonButton(
                              text: team.name,
                              icon: Icons.military_tech,
                              color: isSelected
                                  ? team.color
                                  : team.color.withOpacity(0.3),
                              textColor: isSelected ? Colors.black : team.color,
                              height: 50,
                              width: double.infinity,
                              onPressed: () {
                                gameState.assignCountryToTeam(country, team);
                                Navigator.pop(context);

                                // Success message removed
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Remove assignment button
                    NeonButton(
                      text: 'إلغاء السيطرة',
                      icon: Icons.remove_circle_outline,
                      color: AppTheme.warningRed,
                      textColor: Colors.white,
                      height: 45,
                      width: double.infinity,
                      enabled: country.owner != null,
                      onPressed: country.owner != null
                          ? () {
                              gameState.assignCountryToTeam(country, null);
                              Navigator.pop(context);
                              // Success message removed
                            }
                          : null,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditPointsDialog(
      BuildContext context, GameState gameState, country) async {
    final controller = TextEditingController(text: country.troops.toString());
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text('تعديل النقاط',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'النقاط الجديدة',
              labelStyle: TextStyle(color: AppTheme.textMuted),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.textMuted)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryNeon)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                final newPoints = int.tryParse(controller.text);
                if (newPoints != null) {
                  gameState.updateCountryPoints(country, newPoints);
                }
                Navigator.pop(context);
              },
              child: const Text('حفظ',
                  style: TextStyle(color: AppTheme.primaryNeon)),
            ),
          ],
        );
      },
    );
  }

  void _showQuestionDialog(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => QuestionDialog(
        questionService: gameState.questionService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer<GameState>(
              builder: (context, gameState, child) {
                return Stack(
                  children: [
                    // Main map area
                    _buildMapArea(gameState),

                    // Command HUD overlay
                    _buildCommandHUD(gameState),

                    // Stats panel
                    if (_showStats) _buildStatsPanel(gameState),

                    // Control buttons
                    _buildControlButtons(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapArea(GameState gameState) {
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(
            right: _showStats ? 312 : 0,
            top: 90,
          ),
          child: CommandCard(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Interactive Map with Dynamic Coloring
                    // Using 'original_full_map(42).svg' as default based on updated data
                    Positioned.fill(
                      child: VectorMap(
                        mapAsset: gameState.countries.length == 20
                            ? 'assets/original_map(20).svg'
                            : 'assets/original_full_map(42).svg',
                        countries: gameState.countries,
                        onCountryTap: (country) =>
                            _onCountryTap(context, country),
                      ),
                    ),

                    // Country overlays (Markers) - REMOVED as per request
                    // We now rely on clicking the land vectors in InteractiveMap
                    // ...gameState.countries.map((country) { ... })
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommandHUD(GameState gameState) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _fadeController,
          curve: Curves.easeOutBack,
        )),
        child: CommandCard(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Mission status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    gameState.phase == GamePhase.war
                        ? 'مسرح العمليات'
                        : 'مرحلة التوزيع',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    gameState.phase == GamePhase.war
                        ? 'Command Theater'
                        : 'Deployment Phase',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                          letterSpacing: 1.1,
                        ),
                  ),
                ],
              ),

              const Spacer(),

              // Action buttons
              if (gameState.phase == GamePhase.distribution)
                NeonButton(
                  text: 'بدء الحرب',
                  icon: Icons.flash_on, // Changed icon for war start
                  color: AppTheme.warningRed,
                  textColor: Colors.white,
                  height: 40,
                  width: 140,
                  onPressed: () {
                    setState(() {
                      gameState.startWar();
                    });
                  },
                ),

              if (gameState.phase == GamePhase.war)
                NeonButton(
                  text: 'الأسئلة',
                  icon: Icons.quiz,
                  height: 40,
                  width: 100,
                  onPressed: () => _showQuestionDialog(context),
                ),

              const SizedBox(width: 12),

              IconButton(
                onPressed: () {
                  setState(() {
                    _showStats = !_showStats;
                  });
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryNeon),
                    color: _showStats
                        ? AppTheme.primaryNeon.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: AppTheme.primaryNeon,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              IconButton(
                onPressed: () async {
                  await FullscreenHelper.toggleFullscreen();
                },
                tooltip: 'Toggle Fullscreen',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryNeon),
                    color: FullscreenHelper.isFullscreen
                        ? AppTheme.primaryNeon.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    FullscreenHelper.isFullscreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    color: AppTheme.primaryNeon,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsPanel(GameState gameState) {
    return Positioned(
      top: 110,
      right: 16,
      width: 280,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(_statsAnimation),
        child: CommandCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart,
                    color: AppTheme.primaryNeon,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'إحصائيات القوات',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...gameState.teams.map((team) {
                final teamPoints = gameState.teamPoints[team] ?? 0;
                final maxPoints = gameState.teamPoints.values.isEmpty
                    ? 1
                    : gameState.teamPoints.values
                        .reduce((a, b) => a > b ? a : b);
                final percentage = maxPoints > 0 ? teamPoints / maxPoints : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            team.name,
                            style: TextStyle(
                              color: team.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$teamPoints',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppTheme.surfaceDark,
                        valueColor: AlwaysStoppedAnimation<Color>(team.color),
                        minHeight: 6,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // FloatingActionButton(
          //   heroTag: "settings",
          //   onPressed: () {
          //     // Settings dialog
          //   },
          //   backgroundColor: AppTheme.surfaceDark,
          //   child: const Icon(
          //     Icons.settings,
          //     color: AppTheme.primaryNeon,
          //   ),
          // ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "save",
            onPressed: () async {
              final gameState = Provider.of<GameState>(context, listen: false);
              final storage = GameStorageService();
              await storage.saveGame(gameState, widget.slotId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حفظ اللعبة بنجاح!'),
                    backgroundColor: AppTheme.primaryNeon,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            backgroundColor: AppTheme.surfaceDark,
            child: const Icon(
              Icons.save,
              color: AppTheme.primaryNeon,
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "exit",
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundColor: AppTheme.warningRed,
            child: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
