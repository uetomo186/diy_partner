
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.diary?.title ?? '');
    _contentController =
        TextEditingController(text: widget.diary?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveDiary() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final content = _contentController.text;
      
      final notifier = ref.read(diaryListProvider.notifier);

      if (widget.diary == null) {
        // Create
        final newDiary = Diary(
          title: title,
          content: content,
          createdAt: DateTime.now(),
        );
        await notifier.addDiary(newDiary);
      } else {
        // Update
        final updatedDiary = widget.diary!.copyWith(
          title: title,
          content: content,
        );
        await notifier.updateDiary(updatedDiary);
      }

      if (mounted) {
        context.pop(); // No need to return result, provider handles update
      }
    }
  }

  Future<void> _deleteDiary() async {
    if (widget.diary != null) {
        final notifier = ref.read(diaryListProvider.notifier);
        await notifier.deleteDiary(widget.diary!.id!);
        if (mounted) {
            context.pop();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diary == null ? '日記作成' : '日記編集'),
        actions: [
          if (widget.diary != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('削除確認'),
                    content: const Text('この日記を削除してもよろしいですか？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          _deleteDiary();
                        },
                        child: const Text('削除',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'タイトル'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '内容'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '内容を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveDiary,
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
