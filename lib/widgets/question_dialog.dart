// lib/widgets/question_dialog.dart

import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/question_category.dart';
import '../services/question_service.dart';
import '../theme/app_theme.dart';
import 'command_card.dart';

class QuestionDialog extends StatefulWidget {
  final QuestionService questionService;

  const QuestionDialog({
    super.key,
    required this.questionService,
  });

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog>
    with TickerProviderStateMixin {
  QuestionCategory? selectedCategory;
  Question? currentQuestion;
  bool showAnswer = false;
  bool isLoading = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _flipController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _showImageZoom(String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: false,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black87,
          child: Stack(
            children: [
              // Full screen image with zoom capability
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryNeon.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.surfaceDark,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: AppTheme.textMuted,
                              size: 64,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 40,
                right: 40,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                    border: Border.all(
                      color: AppTheme.primaryNeon.withOpacity(0.7),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNeon.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              // Instructions text
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryNeon.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'اضغط واسحب للتحريك • اقرص للتكبير والتصغير • اضغط للإغلاق',
                      style: TextStyle(
                        color: AppTheme.primaryNeon,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CommandCard(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(
                  child: currentQuestion == null
                      ? _buildCategorySelection()
                      : _buildQuestionDisplay(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryNeon, width: 2),
            boxShadow: AppTheme.neonShadow,
          ),
          child: const Icon(
            Icons.quiz,
            color: AppTheme.primaryNeon,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentQuestion == null
                    ? 'بنك الأسئلة'
                    : selectedCategory?.name ?? '',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                currentQuestion == null
                    ? 'Intelligence Database'
                    : 'Category Challenge',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMuted,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
        ),
        if (currentQuestion != null)
          NeonButton(
            text: 'العودة',
            icon: Icons.arrow_back,
            height: 40,
            width: 100,
            onPressed: _backToCategories,
          ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.warningRed),
            ),
            child: const Icon(
              Icons.close,
              color: AppTheme.warningRed,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.psychology,
                color: AppTheme.primaryNeon,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'اختر فئة الاستخبارات التكتيكية لاختبار معرفة القوات',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: widget.questionService.categories.length,
            itemBuilder: (context, index) {
              final category = widget.questionService.categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(QuestionCategory category) {
    final stats =
        widget.questionService.getCategoryStatistics()[category.id] ?? {};
    final total = stats['total'] ?? 0;
    final revealed = stats['revealed'] ?? 0;
    final remaining = stats['remaining'] ?? 0;
    final percentage = total > 0 ? revealed / total : 0.0;

    return CommandCard(
      padding: const EdgeInsets.all(16),
      glowColor: remaining > 0 ? AppTheme.primaryNeon : AppTheme.textMuted,
      onTap: remaining > 0 ? () => _selectCategory(category) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: remaining > 0
                      ? AppTheme.primaryNeon.withOpacity(0.2)
                      : AppTheme.textMuted.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: remaining > 0
                        ? AppTheme.primaryNeon
                        : AppTheme.textMuted,
                  ),
                ),
                child: Text(
                  '$remaining',
                  style: TextStyle(
                    color: remaining > 0
                        ? AppTheme.primaryNeon
                        : AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مكتمل: $revealed/$total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  Text(
                    '${(percentage * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryNeon,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppTheme.surfaceDark,
                valueColor: AlwaysStoppedAnimation<Color>(
                  remaining > 0 ? AppTheme.primaryNeon : AppTheme.textMuted,
                ),
                minHeight: 6,
              ),
            ],
          ),

          const Spacer(),

          // Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: remaining > 0
                  ? AppTheme.primaryGradient
                  : LinearGradient(
                      colors: [
                        AppTheme.textMuted,
                        AppTheme.textMuted.withOpacity(0.7)
                      ],
                    ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              remaining > 0 ? 'جاهز للاستخدام' : 'مكتمل',
              style: TextStyle(
                color: remaining > 0 ? Colors.black : AppTheme.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionDisplay() {
    if (isLoading) {
      return Center(
        child: CommandCard(
          width: 200,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تحضير السؤال...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (currentQuestion == null) {
      return Center(
        child: CommandCard(
          width: 300,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppTheme.warningRed,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد أسئلة متاحة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'جميع الأسئلة في هذه الفئة تم استخدامها',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        if (_flipAnimation.value < 0.5) {
          return _buildQuestionSide();
        } else {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(3.14159),
            child: _buildAnswerSide(),
          );
        }
      },
    );
  }

  Widget _buildQuestionSide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.neonShadow,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.quiz,
                color: Colors.black,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مهمة استخباراتية',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'صعوبة: ${_getDifficultyText(currentQuestion!.difficulty)}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentQuestion!.difficulty}/5',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Question content
        Expanded(
          child: CommandCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentQuestion!.hasImageQuestion) ...[
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => _showImageZoom(
                          'assets/questions/${currentQuestion!.imagePath!}'),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryNeon.withOpacity(0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/questions/${currentQuestion!.imagePath!}',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.surfaceDark,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: AppTheme.textMuted,
                                    size: 64,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (currentQuestion!.hasTextQuestion) ...[
                  Expanded(
                    flex: currentQuestion!.hasImageQuestion ? 2 : 1,
                    child: Center(
                      child: Text(
                        currentQuestion!.text!,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Show answer button
        NeonButton(
          text: 'كشف الإجابة',
          icon: Icons.visibility,
          height: 50,
          width: double.infinity,
          onPressed: _showAnswer,
        ),
      ],
    );
  }

  Widget _buildAnswerSide() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Answer header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.redNeonShadow,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'الإجابة الصحيحة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Answer content
          Expanded(
            child: CommandCard(
              padding: const EdgeInsets.all(24),
              glowColor: AppTheme.successGreen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (currentQuestion!.answerImagePath != null) ...[
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => _showImageZoom(
                            'assets/questions/${currentQuestion!.answerImagePath!}'),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.successGreen.withOpacity(0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/questions/${currentQuestion!.answerImagePath!}',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.surfaceDark,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: AppTheme.textMuted,
                                      size: 64,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (currentQuestion!.answerText != null) ...[
                    Expanded(
                      flex: currentQuestion!.answerImagePath != null ? 2 : 1,
                      child: Center(
                        child: Text(
                          currentQuestion!.answerText!,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: NeonButton(
                  text: 'سؤال آخر',
                  icon: Icons.refresh,
                  color: AppTheme.primaryNeon,
                  textColor: Colors.black,
                  height: 50,
                  onPressed: _getNextQuestion,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonButton(
                  text: 'إنهاء',
                  icon: Icons.done,
                  color: AppTheme.warningRed,
                  textColor: Colors.white,
                  height: 50,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'سهل';
      case 2:
        return 'متوسط';
      case 3:
        return 'صعب';
      case 4:
        return 'صعب جداً';
      case 5:
        return 'خبير';
      default:
        return 'غير محدد';
    }
  }

  void _selectCategory(QuestionCategory category) {
    setState(() {
      selectedCategory = category;
      isLoading = true;
    });

    // Simulate loading delay for dramatic effect
    Future.delayed(const Duration(milliseconds: 800), () {
      final question =
          widget.questionService.getNextQuestionForCategory(category.id);
      if (question != null) {
        widget.questionService.markQuestionAsRevealed(question.id);
      }
      if (mounted) {
        setState(() {
          currentQuestion = question;
          isLoading = false;
          showAnswer = false;
        });
      }
    });
  }

  void _showAnswer() {
    _flipController.forward();
    setState(() {
      showAnswer = true;
    });
  }

  void _getNextQuestion() {
    if (selectedCategory != null) {
      _flipController.reset();
      setState(() {
        showAnswer = false;
        isLoading = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        final question = widget.questionService
            .getNextQuestionForCategory(selectedCategory!.id);
        if (question != null) {
          widget.questionService.markQuestionAsRevealed(question.id);
        }
        if (mounted) {
          setState(() {
            currentQuestion = question;
            isLoading = false;
          });
        }
      });
    }
  }

  void _backToCategories() {
    setState(() {
      selectedCategory = null;
      currentQuestion = null;
      showAnswer = false;
      isLoading = false;
    });
    _flipController.reset();
  }
}
