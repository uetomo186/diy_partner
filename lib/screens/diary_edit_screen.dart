import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/diary.dart';
import '../providers/diary_providers.dart';

class DiaryEditScreen extends ConsumerStatefulWidget {
  final Diary? diary;
  const DiaryEditScreen({super.key, this.diary});

  @override
  ConsumerState<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends ConsumerState<DiaryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _selectedColor;
  String? _imagePath;

  final List<int> _colors = [
    0xFFFFFFFF, // White
    0xFFE3F2FD, // Light Blue
    0xFFE8F5E9, // Mint
    0xFFFFF9C4, // Lemon
    0xFFFCE4EC, // Pink
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.diary?.title ?? '');
    _contentController = TextEditingController(
      text: widget.diary?.content ?? '',
    );
    _selectedColor = widget.diary?.color ?? 0xFFFFFFFF;
    _imagePath = widget.diary?.imagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(pickedFile.path)}';
      final savedImage = await File(
        pickedFile.path,
      ).copy('${directory.path}/$fileName');

      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  Future<void> _saveDiary() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      if (mounted) context.pop();
      return;
    }

    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final content = _contentController.text;
      final notifier = ref.read(diaryListProvider.notifier);

      if (widget.diary == null) {
        final newDiary = Diary(
          title: title,
          content: content,
          createdAt: DateTime.now(),
          color: _selectedColor,
          imagePath: _imagePath,
        );
        await notifier.addDiary(newDiary);
      } else {
        final updatedDiary = widget.diary!.copyWith(
          title: title,
          content: content,
          color: _selectedColor,
          imagePath: _imagePath,
        );
        await notifier.updateDiary(updatedDiary);
      }
      if (mounted) context.pop();
    }
  }

  Future<void> _deleteDiary() async {
    if (widget.diary != null) {
      final notifier = ref.read(diaryListProvider.notifier);
      await notifier.deleteDiary(widget.diary!.id!);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'yyyy年MM月dd日 (E)',
      'ja',
    ).format(widget.diary?.createdAt ?? DateTime.now());

    final bgColor = Color(_selectedColor);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'DIY日記を作成',
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black87),
            onPressed: _saveDiary,
            tooltip: '保存',
          ),
          if (widget.diary != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black54),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('削除'),
                    content: const Text('この日記を削除しますか？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteDiary();
                        },
                        child: const Text(
                          '削除',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Color Palette
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final color = _colors[index];
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black87 : Colors.black12,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.black54,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // The "Paper" / Text Field Range
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black12, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Image Attachment Area
                          if (_imagePath != null)
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_imagePath!),
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _imagePath = null;
                                    });
                                  },
                                ),
                              ],
                            )
                          else
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: double.infinity,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '画像を追加',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'タイトル',
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'タイトルを入力してください' : null,
                          ),
                          const Divider(height: 32, color: Colors.black12),
                          TextFormField(
                            controller: _contentController,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              hintText: '本文を入力...',
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: null,
                            maxLength: 10000,
                            validator: (v) => v!.isEmpty ? '内容を入力してください' : null,
                          ),
                          // const SizedBox(height: 24),

                          // AI Comment Section
                          // const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
