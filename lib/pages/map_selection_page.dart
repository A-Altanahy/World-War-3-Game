import 'package:flutter/material.dart';
import '../models/country_configuration.dart';
import '../services/configuration_service.dart';
import '../theme/app_theme.dart';
import '../widgets/command_card.dart';
import '../widgets/map_preview_card.dart';
import 'country_editor_page.dart';
import 'team_setup_page.dart';
import '../models/country_positions.dart';

class MapSelectionPage extends StatefulWidget {
  const MapSelectionPage({super.key});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage>
    with TickerProviderStateMixin {
  List<CountryConfiguration> _configurations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigurations();
  }

  Future<void> _loadConfigurations() async {
    try {
      final configurations = await ConfigurationService.getConfigurations();

      if (configurations.isEmpty) {
        // Auto-create default configuration if none exists
        await _createDefaultConfiguration();
        return; // _createDefaultConfiguration calls _loadConfigurations again
      }

      setState(() {
        _configurations = configurations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createDefaultConfiguration() async {
    setState(() => _isLoading = true);
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
      setState(() => _isLoading = false);
    }
  }

  void _navigateToEditor({CountryConfiguration? existingConfig}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CountryEditorPage(existingConfiguration: existingConfig),
      ),
    );

    if (result == true) {
      _loadConfigurations();
    }
  }

  void _selectConfiguration(CountryConfiguration config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamSetupPage(configuration: config),
      ),
    );
  }

  Future<void> _deleteConfiguration(CountryConfiguration config) async {
    try {
      await ConfigurationService.deleteConfiguration(config.id);
      _loadConfigurations();
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground, // Backup background
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryNeon))
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),
              Text(
                'اختر الخريطة',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          NeonButton(
            text: 'تصميم خريطة',
            icon: Icons.add,
            height: 40,
            width: 140,
            onPressed: () => _navigateToEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_configurations.isEmpty && !_isLoading) {
      return const Center(
        child: Text('جاري إنشاء الخريطة الافتراضية...',
            style: TextStyle(color: Colors.white)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _configurations.length,
      itemBuilder: (context, index) {
        final config = _configurations[index];
        return MapPreviewCard(
          config: config,
          onTap: () => _selectConfiguration(config),
          onEdit: () => _navigateToEditor(existingConfig: config),
          onDelete: () => _deleteConfiguration(config),
        );
      },
      // You can also add a special card for "Add New" in the grid if desired
    );
  }
}
