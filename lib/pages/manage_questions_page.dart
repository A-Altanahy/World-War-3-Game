import 'package:custom_risk/services/question_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/question_category.dart';
import '../theme/app_theme.dart';
import '../utils/hex_color.dart';
import '../widgets/command_card.dart';
import 'category_details_page.dart';

class ManageQuestionsPage extends StatefulWidget {
  const ManageQuestionsPage({super.key});

  @override
  State<ManageQuestionsPage> createState() => _ManageQuestionsPageState();
}

class _ManageQuestionsPageState extends State<ManageQuestionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title:
            const Text('إدارة الأسئلة', style: TextStyle(fontFamily: 'Changa')),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Consumer<QuestionService>(
          builder: (context, service, child) {
            final categories = service.categories;

            if (categories.isEmpty) {
              return const Center(
                  child: Text('لا توجد فئات',
                      style: TextStyle(color: Colors.white)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isCustom = service.isCustomCategory(category.id);
                final isEnabled = service.isCategoryEnabled(category.id);

                return CommandCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryDetailsPage(category: category),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  glowColor: HexColor(category.color),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: HexColor(category.color),
                      child: isCustom
                          ? const Icon(Icons.person, color: Colors.white)
                          : const Icon(Icons.public, color: Colors.white),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Changa',
                      ),
                    ),
                    subtitle: Text(
                      isCustom ? 'فئة خاصة' : 'فئة أساسية',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Toggle Switch
                        Switch(
                          value: isEnabled,
                          activeColor: AppTheme.primaryNeon,
                          onChanged: (val) async {
                            await service.toggleCategoryVisibility(
                                category.id, val);
                            setState(() {});
                          },
                        ),
                        if (isCustom)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _confirmDeleteCategory(context, category),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryNeon,
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
      BuildContext context, QuestionCategory category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('حذف الفئة', style: TextStyle(color: Colors.white)),
        content: Text(
            'هل أنت متأكد من حذف فئة "${category.name}" وجميع أسئلتها؟',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final service = Provider.of<QuestionService>(context, listen: false);
      await service.deleteCategory(category.id);
      setState(() {});
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text('إضافة فئة جديدة',
                style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'اسم الفئة',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30)),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('اختر لونًا'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: selectedColor,
                            onColorChanged: (color) {
                              setState(() => selectedColor = color);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Text('لون الفئة: ',
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        color: selectedColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNeon),
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final service =
                        Provider.of<QuestionService>(context, listen: false);
                    final newCategory = QuestionCategory(
                      id: const Uuid().v4(),
                      name: nameController.text,
                      description: 'فئة خاصة',
                      color:
                          '#${selectedColor.value.toRadixString(16).substring(2)}',
                    );
                    await service.addCategory(newCategory);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child:
                    const Text('إضافة', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }
}
