import 'dart:convert';
import 'dart:io';

void main() {
  final qFile = File('user_questions_v1.json');
  if (!qFile.existsSync()) return;
  final data = json.decode(qFile.readAsStringSync());
  
  for (var q in data['customQuestions'] ?? []) {
    final ap = q['audioPath'];
    if (ap != null) {
      final f = File(ap);
      if (!f.existsSync()) {
        print('Missing custom audio: \$ap');
      } else {
        print('Valid custom audio: \$ap');
      }
    }
  }
}
