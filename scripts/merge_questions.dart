import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart scripts/merge_questions.dart <path/to/source_folder>');
    return;
  }

  final sourceDir = args[0];
  final userJsonPath = p.join(sourceDir, 'user_questions_v1.json');
  final userMediaDir = Directory(p.join(sourceDir, 'custom_media'));

  final projectDir = p.dirname(Directory.current.path) == 'scripts' ? Directory.current.parent.path : Directory.current.path;
  final defaultCatPath = p.join(projectDir, 'assets', 'questions', 'categories.json');
  final defaultQPath = p.join(projectDir, 'assets', 'questions', 'questions.json');
  
  final destImagesPath = p.join(projectDir, 'assets', 'questions', 'images');
  final destAudioPath = p.join(projectDir, 'assets', 'questions', 'audio');
  final destVideoPath = p.join(projectDir, 'assets', 'questions', 'video');

  final userFile = File(userJsonPath);
  if (!userFile.existsSync()) {
    print('User questions file not found at $userJsonPath');
    return;
  }
  
  final userData = json.decode(userFile.readAsStringSync());
  final List customCategories = userData['customCategories'] ?? [];
  final List customQuestions = userData['customQuestions'] ?? [];

  final defaultCatFile = File(defaultCatPath);
  final defaultQFile = File(defaultQPath);
  
  Map<String, dynamic> defaultCategories = {'categories': []};
  Map<String, dynamic> defaultQuestions = {'questions': []};
  
  if (defaultCatFile.existsSync()) {
    defaultCategories = json.decode(defaultCatFile.readAsStringSync());
  }
  if (defaultQFile.existsSync()) {
    defaultQuestions = json.decode(defaultQFile.readAsStringSync());
  }

  // Merge Categories
  final categoryIds = (defaultCategories['categories'] as List).map((c) => c['id']).toSet();
  int addedCategories = 0;
  for (var cat in customCategories) {
    if (!categoryIds.contains(cat['id'])) {
      defaultCategories['categories'].add(cat);
      addedCategories++;
    }
  }

  String? processMedia(String? originalPath, String type) {
    if (originalPath == null || originalPath.isEmpty) return null;
    if (originalPath.startsWith('assets/')) return originalPath;
    if (originalPath.startsWith('images/') || originalPath.startsWith('audio/') || originalPath.startsWith('video/')) return originalPath;
    
    // We expect the original media to either still be an absolute path, OR be relative to the source directory's 'custom_media' folder.
    // Let's check both absolute and relative 
    File file = File(originalPath);
    if (!file.existsSync()) {
       // try resolving using custom_media dir
       final filename = p.basename(originalPath);
       file = File(p.join(userMediaDir.path, filename));
    }
    
    if (!file.existsSync()) {
      print('Warning: Media file not found: $originalPath');
      return null;
    }
    
    final filename = p.basename(file.path);
    String destDir;
    String folderName;
    if (type == 'image') { destDir = destImagesPath; folderName = 'images'; }
    else if (type == 'audio') { destDir = destAudioPath; folderName = 'audio'; }
    else if (type == 'video') { destDir = destVideoPath; folderName = 'video'; }
    else return null;
    
    Directory(destDir).createSync(recursive: true);
    final destPath = p.join(destDir, filename);
    file.copySync(destPath);
    
    return '$folderName/$filename';
  }

  // Merge Questions
  final questionIds = (defaultQuestions['questions'] as List).map((q) => q['id']).toSet();
  int addedQuestions = 0;
  for (var q in customQuestions) {
    if (!questionIds.contains(q['id'])) {
      q['imagePath'] = processMedia(q['imagePath'], 'image');
      q['audioPath'] = processMedia(q['audioPath'], 'audio');
      q['videoPath'] = processMedia(q['videoPath'], 'video');
      
      q['answerImagePath'] = processMedia(q['answerImagePath'], 'image');
      q['answerAudioPath'] = processMedia(q['answerAudioPath'], 'audio');
      q['answerVideoPath'] = processMedia(q['answerVideoPath'], 'video');
      
      defaultQuestions['questions'].add(q);
      addedQuestions++;
    }
  }

  const encoder = JsonEncoder.withIndent('  ');
  defaultCatFile.writeAsStringSync(encoder.convert(defaultCategories));
  defaultQFile.writeAsStringSync(encoder.convert(defaultQuestions));
  
  print('Successfully merged $addedCategories new categories and $addedQuestions new questions into $defaultCatPath and $defaultQPath!');
}
