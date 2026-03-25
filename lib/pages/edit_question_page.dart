import 'dart:io';

import 'package:custom_risk/services/question_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/question_category.dart';
import '../theme/app_theme.dart';
import '../widgets/media_player_widget.dart';

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

  File? _questionImage;
  File? _questionAudio;
  File? _questionVideo;

  File? _answerImage;
  File? _answerAudio;
  File? _answerVideo;

  String? _existingQuestionImagePath;
  String? _existingQuestionAudioPath;
  String? _existingQuestionVideoPath;

  String? _existingAnswerImagePath;
  String? _existingAnswerAudioPath;
  String? _existingAnswerVideoPath;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.questionToEdit?.text ?? '');
    _answerController =
        TextEditingController(text: widget.questionToEdit?.answerText ?? '');
        
    _existingQuestionImagePath = widget.questionToEdit?.imagePath;
    _existingQuestionAudioPath = widget.questionToEdit?.audioPath;
    _existingQuestionVideoPath = widget.questionToEdit?.videoPath;

    _existingAnswerImagePath = widget.questionToEdit?.answerImagePath;
    _existingAnswerAudioPath = widget.questionToEdit?.answerAudioPath;
    _existingAnswerVideoPath = widget.questionToEdit?.answerVideoPath;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _clearQuestionMedia() {
    _questionImage = _questionAudio = _questionVideo = null;
    _existingQuestionImagePath = _existingQuestionAudioPath = _existingQuestionVideoPath = null;
  }

  void _clearAnswerMedia() {
    _answerImage = _answerAudio = _answerVideo = null;
    _existingAnswerImagePath = _existingAnswerAudioPath = _existingAnswerVideoPath = null;
  }

  void _showMediaError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Changa', color: Colors.white)),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickMedia(bool isAnswer, FileType type) async {
    try {
      List<String> allowedExtensions = [];
      FileType pickerType = type;
      int maxSizeMb = 100;

      if (type == FileType.image) {
        pickerType = FileType.custom;
        allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
        maxSizeMb = 10;
      } else if (type == FileType.audio) {
        pickerType = FileType.custom;
        allowedExtensions = ['mp3', 'wav', 'm4a', 'aac', 'flac', 'ogg'];
        maxSizeMb = 15;
      } else if (type == FileType.video) {
        pickerType = FileType.custom;
        allowedExtensions = ['mp4', 'mov', 'm4v', 'avi', 'mkv'];
        maxSizeMb = 100;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: pickerType,
        allowedExtensions: allowedExtensions.isNotEmpty ? allowedExtensions : null,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        
        // Validate Size
        final sizeInMb = platformFile.size / (1024 * 1024);
        if (sizeInMb > maxSizeMb) {
          _showMediaError('حجم الملف كبير! الحد الأقصى هو $maxSizeMb ميغابايت.');
          return;
        }

        // Validate Extension
        final ext = platformFile.extension?.toLowerCase() ?? '';
        if (allowedExtensions.isNotEmpty && !allowedExtensions.contains(ext)) {
          _showMediaError('صيغة غير مدعومة! الصيغ هي:\n${allowedExtensions.join(', ')}');
          return;
        }

        final file = File(platformFile.path!);
        setState(() {
          if (isAnswer) {
            _clearAnswerMedia();
            if (type == FileType.image) _answerImage = file;
            else if (type == FileType.audio) _answerAudio = file;
            else if (type == FileType.video) _answerVideo = file;
          } else {
            _clearQuestionMedia();
            if (type == FileType.image) _questionImage = file;
            else if (type == FileType.audio) _questionAudio = file;
            else if (type == FileType.video) _questionVideo = file;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _questionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('نص السؤال (اختياري)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildMediaSection(false),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('الإجابة'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _answerController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('نص الإجابة (اختياري)'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    _buildMediaSection(true),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNeon,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveQuestion,
                child: Text(
                  widget.questionToEdit == null ? 'إضافة السؤال' : 'حفظ التغييرات',
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
      filled: true,
      fillColor: Colors.black26,
    );
  }

  Widget _buildMediaSection(bool isAnswer) {
    File? img = isAnswer ? _answerImage : _questionImage;
    File? aud = isAnswer ? _answerAudio : _questionAudio;
    File? vid = isAnswer ? _answerVideo : _questionVideo;
    String? exImg = isAnswer ? _existingAnswerImagePath : _existingQuestionImagePath;
    String? exAud = isAnswer ? _existingAnswerAudioPath : _existingQuestionAudioPath;
    String? exVid = isAnswer ? _existingAnswerVideoPath : _existingQuestionVideoPath;

    bool hasMedia = img != null || aud != null || vid != null || 
                    (exImg != null && exImg.isNotEmpty) || 
                    (exAud != null && exAud.isNotEmpty) || 
                    (exVid != null && exVid.isNotEmpty);

    if (!hasMedia) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text('إضافة وسائط (اختياري)', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMediaTypeButton(Icons.image, 'صورة', () => _pickMedia(isAnswer, FileType.image)),
              _buildMediaTypeButton(Icons.audiotrack, 'صوت', () => _pickMedia(isAnswer, FileType.audio)),
              _buildMediaTypeButton(Icons.videocam, 'فيديو', () => _pickMedia(isAnswer, FileType.video)),
            ],
          ),
        ],
      );
    }

    Widget content = const SizedBox.shrink();
    if (img != null) {
      content = Image.file(img, height: 150, width: double.infinity, fit: BoxFit.cover);
    } else if (exImg != null && exImg.isNotEmpty) {
      content = _buildImageWidget(exImg, height: 150);
    } else if (aud != null) {
      content = AudioPlayerWidget(audioPath: aud.path);
    } else if (exAud != null && exAud.isNotEmpty) {
      content = AudioPlayerWidget(audioPath: exAud);
    } else if (vid != null) {
      content = VideoPlayerWidget(videoPath: vid.path);
    } else if (exVid != null && exVid.isNotEmpty) {
      content = VideoPlayerWidget(videoPath: exVid);
    }

    return Stack(
      alignment: Alignment.topLeft, // Changed to top-left for RTL
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: content,
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: InkWell(
            onTap: () => setState(() {
              if (isAnswer) _clearAnswerMedia();
              else _clearQuestionMedia();
            }),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4),
                ]
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTypeButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.primaryNeon.withOpacity(0.1),
          border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryNeon, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String path, {BoxFit fit = BoxFit.cover, double? height}) {
    final file = File(path);
    if (path.startsWith('/') ||
        path.startsWith('\\') ||
        (path.length > 1 && path[1] == ':')) {
      return Image.file(
        file,
        fit: fit,
        height: height,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height ?? 150,
          color: Colors.grey[900],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }

    String assetPath = path;
    if (!assetPath.startsWith('assets/')) {
      assetPath = 'assets/questions/$assetPath';
    }

    return Image.asset(
      assetPath,
      fit: fit,
      height: height,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height ?? 150,
        color: Colors.grey[900],
        child: const Icon(Icons.broken_image, color: Colors.white54),
      ),
    );
  }

  Future<String?> _saveCopyOfMedia(File mediaFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final customMediaDir = Directory('${directory.path}/custom_media');
      if (!await customMediaDir.exists()) {
        await customMediaDir.create(recursive: true);
      }
      final filename = '${const Uuid().v4()}${path.extension(mediaFile.path)}';
      final savedFile =
          await mediaFile.copy('${customMediaDir.path}/$filename');
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving media: $e');
      return null;
    }
  }

  Future<void> _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      final hasQuestionContent = _questionController.text.isNotEmpty ||
          _questionImage != null || _questionAudio != null || _questionVideo != null ||
          (_existingQuestionImagePath != null && _existingQuestionImagePath!.isNotEmpty) ||
          (_existingQuestionAudioPath != null && _existingQuestionAudioPath!.isNotEmpty) ||
          (_existingQuestionVideoPath != null && _existingQuestionVideoPath!.isNotEmpty);

      final hasAnswerContent = _answerController.text.isNotEmpty ||
          _answerImage != null || _answerAudio != null || _answerVideo != null ||
          (_existingAnswerImagePath != null && _existingAnswerImagePath!.isNotEmpty) ||
          (_existingAnswerAudioPath != null && _existingAnswerAudioPath!.isNotEmpty) ||
          (_existingAnswerVideoPath != null && _existingAnswerVideoPath!.isNotEmpty);

      if (!hasQuestionContent) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب إضافة نص السؤال أو وسائط')));
        return;
      }

      if (!hasAnswerContent) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب إضافة نص الإجابة أو وسائط')));
        return;
      }

      final service = Provider.of<QuestionService>(context, listen: false);

      String? finalQuestionImagePath = _existingQuestionImagePath;
      String? finalQuestionAudioPath = _existingQuestionAudioPath;
      String? finalQuestionVideoPath = _existingQuestionVideoPath;
      
      if (_questionImage != null) finalQuestionImagePath = await _saveCopyOfMedia(_questionImage!);
      if (_questionAudio != null) finalQuestionAudioPath = await _saveCopyOfMedia(_questionAudio!);
      if (_questionVideo != null) finalQuestionVideoPath = await _saveCopyOfMedia(_questionVideo!);

      String? finalAnswerImagePath = _existingAnswerImagePath;
      String? finalAnswerAudioPath = _existingAnswerAudioPath;
      String? finalAnswerVideoPath = _existingAnswerVideoPath;
      
      if (_answerImage != null) finalAnswerImagePath = await _saveCopyOfMedia(_answerImage!);
      if (_answerAudio != null) finalAnswerAudioPath = await _saveCopyOfMedia(_answerAudio!);
      if (_answerVideo != null) finalAnswerVideoPath = await _saveCopyOfMedia(_answerVideo!);

      final id = widget.questionToEdit?.id ?? const Uuid().v4();
      final isActive = widget.questionToEdit?.isActive ?? true;
      final difficulty = widget.questionToEdit?.difficulty ?? 1;

      final updatedQuestion = Question(
        id: id,
        categoryId: widget.category.id, // Use current category logic
        text: _questionController.text.isEmpty ? null : _questionController.text,
        imagePath: finalQuestionImagePath,
        audioPath: finalQuestionAudioPath,
        videoPath: finalQuestionVideoPath,
        answerText: _answerController.text.isEmpty ? null : _answerController.text,
        answerImagePath: finalAnswerImagePath,
        answerAudioPath: finalAnswerAudioPath,
        answerVideoPath: finalAnswerVideoPath,
        difficulty: difficulty,
        isActive: isActive,
      );

      if (widget.questionToEdit != null) {
        // Use the new proper update function!
        await service.updateQuestion(updatedQuestion);
      } else {
        await service.addQuestion(updatedQuestion);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
