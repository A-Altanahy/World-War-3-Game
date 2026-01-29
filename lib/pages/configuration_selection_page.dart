import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/command_card.dart';
import 'manage_questions_page.dart';
import 'map_selection_page.dart';
import 'save_slots_page.dart';

class ConfigurationSelectionPage extends StatefulWidget {
  const ConfigurationSelectionPage({super.key});

  @override
  State<ConfigurationSelectionPage> createState() =>
      _ConfigurationSelectionPageState();
}

class _ConfigurationSelectionPageState extends State<ConfigurationSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Background handled by main wrapper if any
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildHeroHeader(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // NEW WAR BUTTON
                            Expanded(
                              child: _buildWarButton(
                                title: 'معركة جديدة',
                                subtitle: 'START NEW WAR',
                                icon: Icons.add_moderator,
                                color: AppTheme.primaryNeon,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MapSelectionPage()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),

                            // CONTINUE WAR BUTTON
                            Expanded(
                              child: _buildWarButton(
                                title: 'استكمال المعركة',
                                subtitle: 'CONTINUE WAR',
                                icon: Icons.history_edu,
                                color: AppTheme.accentOrange,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SaveSlotsPage()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Settings/Manage Questions Button
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white70),
                  tooltip: 'إدارة الأسئلة',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageQuestionsPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          const Icon(
            Icons.shield, // War / Defense theme
            size: 48,
            color: AppTheme.primaryNeon,
          ),
          const SizedBox(height: 16),
          Text(
            'غرفة العمليات',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontFamily: 'Changa',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: AppTheme.primaryNeon.withOpacity(0.5),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          Text(
            'WAR ROOM',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryNeon.withOpacity(0.7),
                  letterSpacing: 4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CommandCard(
      onTap: onTap,
      glowColor: color,
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              Colors.transparent,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Icon Faded
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 150,
                color: color.withOpacity(0.05),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Changa', // Ensure valid font
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: color.withOpacity(0.5), blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 3,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Corner Accents
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: color, width: 2),
                    left: BorderSide(color: color, width: 2),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: color, width: 2),
                    right: BorderSide(color: color, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
