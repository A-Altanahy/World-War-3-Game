import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppPaths {
  /// Returns the directory where custom user questions and media should be saved.
  /// On desktop, this will be right next to the executable in a 'custom_data' folder.
  static Future<Directory> getCustomDataDirectory() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final exeDir = p.dirname(Platform.resolvedExecutable);
      final dataDir = Directory(p.join(exeDir, 'custom_data'));
      
      if (!await dataDir.exists()) {
        await dataDir.create(recursive: true);
      }
      return dataDir;
    }
    
    // Fallback for Android/iOS
    final dir = await getApplicationDocumentsDirectory();
    final dataDir = Directory(p.join(dir.path, 'custom_data'));
    
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    return dataDir;
  }
}
