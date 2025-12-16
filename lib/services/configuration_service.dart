// lib/services/configuration_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/country_configuration.dart';

class ConfigurationService {
  static const String _configurationsKey = 'country_configurations';
  static const String _defaultConfigKey = 'default_configuration';

  // Get all saved configurations
  static Future<List<CountryConfiguration>> getConfigurations() async {
    final prefs = await SharedPreferences.getInstance();
    final configStrings = prefs.getStringList(_configurationsKey) ?? [];

    return configStrings
        .map(
            (configString) => CountryConfiguration.fromJsonString(configString))
        .toList();
  }

  // Save a configuration
  static Future<void> saveConfiguration(CountryConfiguration config) async {
    final prefs = await SharedPreferences.getInstance();
    final configurations = await getConfigurations();

    // Check if configuration with same ID exists and replace it
    final existingIndex = configurations.indexWhere((c) => c.id == config.id);
    if (existingIndex != -1) {
      configurations[existingIndex] = config;
    } else {
      configurations.add(config);
    }

    // Save back to preferences
    final configStrings =
        configurations.map((config) => config.toJsonString()).toList();

    await prefs.setStringList(_configurationsKey, configStrings);
  }

  // Delete a configuration
  static Future<void> deleteConfiguration(String configId) async {
    final prefs = await SharedPreferences.getInstance();
    final configurations = await getConfigurations();

    configurations.removeWhere((config) => config.id == configId);

    final configStrings =
        configurations.map((config) => config.toJsonString()).toList();

    await prefs.setStringList(_configurationsKey, configStrings);
  }

  // Get a specific configuration by ID
  static Future<CountryConfiguration?> getConfiguration(String configId) async {
    final configurations = await getConfigurations();
    try {
      return configurations.firstWhere((config) => config.id == configId);
    } catch (e) {
      return null;
    }
  }

  // Set default configuration for quick access
  static Future<void> setDefaultConfiguration(String configId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultConfigKey, configId);
  }

  // Get default configuration ID
  static Future<String?> getDefaultConfigurationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultConfigKey);
  }

  // Check if any configurations exist
  static Future<bool> hasConfigurations() async {
    final configurations = await getConfigurations();
    return configurations.isNotEmpty;
  }

  // Clear all configurations (for testing/reset)
  static Future<void> clearAllConfigurations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configurationsKey);
    await prefs.remove(_defaultConfigKey);
  }
}
