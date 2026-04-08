import 'dart:convert';
import 'dart:io';

void main() {
  final qFile = File('assets/questions/questions.json');
  final data = json.decode(qFile.readAsStringSync());
  
  for (var q in data['questions']) {
    final ap = q['audioPath'];
    if (ap != null) {
      final f = File('assets/questions/$ap');
      if (!f.existsSync()) {
        print('Missing audioPath: $ap');
      } else {
        print('Valid audioPath: $ap');
      }
    }
  }
}
