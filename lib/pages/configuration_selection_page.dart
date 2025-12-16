// lib/pages/configuration_selection_page.dart

import 'package:flutter/material.dart';
import '../models/country_configuration.dart';
import '../services/configuration_service.dart';
import '../theme/app_theme.dart';
import '../widgets/command_card.dart';
import 'country_editor_page.dart';
import 'team_setup_page.dart';
import '../models/country_positions.dart';

class ConfigurationSelectionPage extends StatefulWidget {
  const ConfigurationSelectionPage({super.key});

  @override
  State<ConfigurationSelectionPage> createState() =>
      _ConfigurationSelectionPageState();
}

class _ConfigurationSelectionPageState extends State<ConfigurationSelectionPage>
    with TickerProviderStateMixin {
  List<CountryConfiguration> _configurations = [];
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadConfigurations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigurations() async {
    try {
      final configurations = await ConfigurationService.getConfigurations();
      setState(() {
        _configurations = configurations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        // Error message removed
      }
    }
  }

  // Error SnackBar function removed

  Future<void> _createDefaultConfiguration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final defaultCountries = getInitialCountries();
      final defaultConfig = CountryConfiguration(
        id: 'default',
        name: 'الخريطة الافتراضية',
        countries: defaultCountries,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      await ConfigurationService.saveConfiguration(defaultConfig);
      await _loadConfigurations();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Error message removed
    }
  }

  void _navigateToEditor({CountryConfiguration? existingConfig}) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CountryEditorPage(existingConfiguration: existingConfig),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );

    if (result == true) {
      _loadConfigurations();
    }
  }

  void _selectConfiguration(CountryConfiguration config) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TeamSetupPage(configuration: config),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  Future<void> _deleteConfiguration(CountryConfiguration config) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${config.name}"؟',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          NeonButton(
            text: 'حذف',
            color: AppTheme.warningRed,
            textColor: Colors.white,
            width: 80,
            height: 40,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ConfigurationService.deleteConfiguration(config.id);
        _loadConfigurations();
      } catch (e) {
        // Error message removed
      }
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
                child: _isLoading ? _buildLoadingScreen() : _buildMainContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: CommandCard(
        width: 300,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تحميل التكوينات...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        _buildHeader(),
        _buildActionButtons(),
        _buildConfigurationGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Command Center Title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
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
                      Icons.map,
                      color: AppTheme.primaryNeon,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مركز إدارة الخرائط',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Map Configuration Center',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textMuted,
                                  letterSpacing: 1.2,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
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
                'اختر تكوين خريطة موجود أو قم بإنشاء تكوين جديد لبدء المعركة الاستراتيجية',
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

  Widget _buildActionButtons() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: NeonButton(
                text: 'إنشاء خريطة جديدة',
                icon: Icons.add_circle_outline,
                color: AppTheme.successGreen,
                textColor: Colors.white,
                height: 60,
                onPressed: () => _navigateToEditor(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: NeonButton(
                text: 'الخريطة الافتراضية',
                icon: Icons.map_outlined,
                color: AppTheme.accentOrange,
                textColor: Colors.white,
                height: 60,
                enabled: _configurations.isEmpty,
                onPressed: _configurations.isEmpty
                    ? _createDefaultConfiguration
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationGrid() {
    if (_configurations.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(24),
          height: 300,
          child: CommandCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.textMuted.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: AppTheme.textMuted.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'لا توجد خرائط محفوظة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'أنشئ خريطة جديدة أو استخدم الخريطة الافتراضية للبدء',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final config = _configurations[index];
            return _buildConfigurationCard(config);
          },
          childCount: _configurations.length,
        ),
      ),
    );
  }

  Widget _buildConfigurationCard(CountryConfiguration config) {
    return CommandCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _selectConfiguration(config),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with country count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNeon.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.black,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${config.countries.length}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppTheme.primaryNeon,
                ),
                color: AppTheme.cardDark,
                elevation: 8,
                shadowColor: AppTheme.primaryNeon.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppTheme.primaryNeon.withOpacity(0.3),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEditor(existingConfig: config);
                  } else if (value == 'delete') {
                    _deleteConfiguration(config);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, color: AppTheme.primaryNeon),
                        const SizedBox(width: 8),
                        const Text('تعديل',
                            style: TextStyle(color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: AppTheme.warningRed),
                        const SizedBox(width: 8),
                        const Text('حذف',
                            style: TextStyle(color: AppTheme.warningRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Configuration name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'تم الإنشاء: ${_formatDate(config.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'آخر تعديل: ${_formatDate(config.lastModified)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
              ],
            ),
          ),

          // Launch button
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: NeonButton(
              text: 'بدء المعركة',
              icon: Icons.play_arrow,
              height: 40,
              onPressed: () => _selectConfiguration(config),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
