import 'dart:io';

import 'package:custom_risk/services/question_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/question_category.dart';
import '../theme/app_theme.dart';

class EditQuestionPage extends StatefulWidget {
  final QuestionCategory category;
  final Question? questionToEdit;

  const EditQuestionPage({
    super.key,
    required this.category,
    this.questionToEdit,
  });

  @override
  State<EditQuestionPage> createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _questionImage;
  File? _answerImage;
  String? _existingQuestionImagePath;
  String? _existingAnswerImagePath;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.questionToEdit?.text ?? '');
    _answerController =
        TextEditingController(text: widget.questionToEdit?.answerText ?? '');
    _existingQuestionImagePath = widget.questionToEdit?.imagePath;
    _existingAnswerImagePath = widget.questionToEdit?.answerImagePath;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isAnswer) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isAnswer) {
            _answerImage = File(image.path);
          } else {
            _questionImage = File(image.path);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
            widget.questionToEdit == null ? 'إضافة سؤال' : 'تعديل السؤال',
            style: const TextStyle(fontFamily: 'Changa')),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('السؤال'),
              const SizedBox(height: 10),
              _buildImagePicker(
                  false, _questionImage, _existingQuestionImagePath),
              const SizedBox(height: 10),
              TextFormField(
                controller: _questionController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('نص السؤال (اختياري)'),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('الإجابة'),
              const SizedBox(height: 10),
              _buildImagePicker(true, _answerImage, _existingAnswerImagePath),
              const SizedBox(height: 10),
              TextFormField(
                controller: _answerController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('نص الإجابة (اختياري)'),
                maxLines: 2,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNeon,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveQuestion,
                child: Text(
                  widget.questionToEdit == null ? 'إضافة' : 'حفظ التغييرات',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.primaryNeon,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Changa',
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30)),
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryNeon)),
    );
  }

  Widget _buildImagePicker(
      bool isAnswer, File? newImage, String? existingPath) {
    return Column(
      children: [
        if (newImage != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(newImage,
                    height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => setState(() {
                  if (isAnswer) {
                    _answerImage = null;
                  } else {
                    _questionImage = null;
                  }
                }),
              ),
            ],
          )
        else if (existingPath != null && existingPath.isNotEmpty)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(existingPath),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => setState(() {
                  if (isAnswer) {
                    _existingAnswerImagePath = null;
                  } else {
                    _existingQuestionImagePath = null;
                  }
                }),
              ),
            ],
          ),
        if (newImage == null && (existingPath == null || existingPath.isEmpty))
          OutlinedButton.icon(
            onPressed: () => _pickImage(isAnswer),
            icon: const Icon(Icons.image, color: AppTheme.primaryNeon),
            label:
                const Text('إضافة صورة', style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
          ),
      ],
    );
  }

  Widget _buildImageWidget(String path, {BoxFit fit = BoxFit.cover}) {
    // Check if it's an absolute path (custom image)
    final file = File(path);
    if (path.startsWith('/') ||
        path.startsWith('\\') ||
        (path.length > 1 && path[1] == ':')) {
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[900],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }

    // Otherwise treat as asset (built-in)
    // Ensure we have the correct prefix if missing
    String assetPath = path;
    if (!assetPath.startsWith('assets/')) {
      assetPath = 'assets/questions/$assetPath';
    }

    return Image.asset(
      assetPath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[900],
        child: const Icon(Icons.broken_image, color: Colors.white54),
      ),
    );
  }

  Future<String?> _saveCopyOfImage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final customImagesDir = Directory('${directory.path}/custom_images');
      if (!await customImagesDir.exists()) {
        await customImagesDir.create(recursive: true);
      }
      final filename = '${const Uuid().v4()}${path.extension(imageFile.path)}';
      final savedImage =
          await imageFile.copy('${customImagesDir.path}/$filename');
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  Future<void> _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      // Validate: Must have either text or image
      final hasQuestionContent = _questionController.text.isNotEmpty ||
          _questionImage != null ||
          (_existingQuestionImagePath != null &&
              _existingQuestionImagePath!.isNotEmpty);

      final hasAnswerContent = _answerController.text.isNotEmpty ||
          _answerImage != null ||
          (_existingAnswerImagePath != null &&
              _existingAnswerImagePath!.isNotEmpty);

      if (!hasQuestionContent) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب إضافة نص السؤال أو صورة')));
        return;
      }

      if (!hasAnswerContent) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب إضافة نص الإجابة أو صورة')));
        return;
      }

      final service = Provider.of<QuestionService>(context, listen: false);

      String? finalQuestionImagePath = _existingQuestionImagePath;
      if (_questionImage != null) {
        final savedPath = await _saveCopyOfImage(_questionImage!);
        if (savedPath != null) finalQuestionImagePath = savedPath;
      }

      String? finalAnswerImagePath = _existingAnswerImagePath;
      if (_answerImage != null) {
        final savedPath = await _saveCopyOfImage(_answerImage!);
        if (savedPath != null) finalAnswerImagePath = savedPath;
      }

      if (widget.questionToEdit != null) {
        await service.deleteQuestion(widget.questionToEdit!.id);

        final updatedQuestion = Question(
          id: widget.questionToEdit!.id,
          categoryId: widget.category.id, // Use current category logic
          text: _questionController.text.isEmpty
              ? null
              : _questionController.text,
          imagePath: finalQuestionImagePath,
          answerText:
              _answerController.text.isEmpty ? null : _answerController.text,
          answerImagePath: finalAnswerImagePath,
          difficulty: widget.questionToEdit!.difficulty,
        );
        await service.addQuestion(updatedQuestion);
      } else {
        final newQuestion = Question(
          id: const Uuid().v4(),
          categoryId: widget.category.id,
          text: _questionController.text.isEmpty
              ? null
              : _questionController.text,
          imagePath: finalQuestionImagePath,
          answerText:
              _answerController.text.isEmpty ? null : _answerController.text,
          answerImagePath: finalAnswerImagePath,
          difficulty: 1,
        );
        await service.addQuestion(newQuestion);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
