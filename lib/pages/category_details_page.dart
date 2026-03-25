import 'dart:io';

import 'package:custom_risk/services/question_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/question_category.dart';
import '../theme/app_theme.dart';
import '../widgets/command_card.dart';
import 'edit_question_page.dart';

class CategoryDetailsPage extends StatefulWidget {
  final QuestionCategory category;

  const CategoryDetailsPage({super.key, required this.category});

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.category.name,
            style: const TextStyle(fontFamily: 'Changa')),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<QuestionService>(
          builder: (context, service, child) {
            final questions =
                service.getQuestionsByCategory(widget.category.id);

            return Column(
              children: [
                if (questions.isEmpty)
                  const Expanded(
                      child: Center(
                          child: Text('لا توجد أسئلة بعد',
                              style: TextStyle(color: Colors.white70)))),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return CommandCard(
                        onTap: () {
                          // Allow editing/viewing all questions
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditQuestionPage(
                                          category: widget.category,
                                          questionToEdit: question)))
                              .then((_) => setState(() {}));
                        },
                        child: ListTile(
                          leading: _buildLeadingWidget(question),
                          title: Text(
                            question.text ?? 'سؤال صورة',
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Changa'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            question.answerText ?? 'إجابة صورة',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.7)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: question.isActive,
                                activeColor: AppTheme.primaryNeon,
                                onChanged: (bool value) async {
                                  await service.toggleQuestionActiveStatus(
                                      question.id, value);
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFF1A1A2E),
                                      title: const Text('حذف السؤال',
                                          style: TextStyle(color: Colors.white)),
                                      content: const Text(
                                          'هل أنت متأكد من حذف هذا السؤال؟',
                                          style: TextStyle(color: Colors.white70)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('إلغاء'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('حذف',
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await service.deleteQuestion(question.id);
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryNeon,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditQuestionPage(category: widget.category)))
              .then((_) => setState(() {}));
        },
      ),
    );
  }

  Widget _buildLeadingWidget(Question question) {
    if (question.hasImageQuestion) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 60,
          height: 60,
          child: _buildThumbnail(question.imagePath!),
        ),
      );
    } else if (question.hasVideoQuestion) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.videocam, color: AppTheme.primaryNeon),
      );
    } else if (question.hasAudioQuestion) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.audiotrack, color: AppTheme.primaryNeon),
      );
    }
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.short_text, color: Colors.white54),
    );
  }

  Widget _buildThumbnail(String path) {
    // Check if it's an absolute path (custom image)
    final file = File(path);
    if (path.startsWith('/') ||
        path.startsWith('\\') ||
        (path.length > 1 && path[1] == ':')) {
      return Image.file(file, fit: BoxFit.cover);
    }

    // Otherwise treat as asset (built-in)
    String assetPath = path;
    if (!assetPath.startsWith('assets/')) {
      assetPath = 'assets/questions/$assetPath';
    }
    return Image.asset(assetPath, fit: BoxFit.cover);
  }
}
