import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../utils/database_helper.dart';
import 'package:go_router/go_router.dart';

class DiaryEditScreen extends StatefulWidget {
  final Diary? diary;

  const DiaryEditScreen({super.key, this.diary});

  @override
  State<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.diary?.title ?? '');
    _contentController = TextEditingController(text: widget.diary?.content ?? '');
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
      final diary = Diary(
        id: widget.diary?.id,
        title: title,
        content: content,
        createdAt: widget.diary?.createdAt ?? DateTime.now(),
      );

      if (widget.diary == null) {
        await DatabaseHelper.instance.create(diary);
      } else {
        await DatabaseHelper.instance.update(diary);
      }

      if (mounted) {
        context.pop(true); // Return true to indicate refresh needed
      }
    }
  }

  Future<void> _deleteDiary() async {
    if (widget.diary != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('削除確認'),
          content: const Text('この日記を削除にしてもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await DatabaseHelper.instance.delete(widget.diary!.id!);
        if (mounted) {
          context.pop(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diary == null ? '日記を書く' : '日記の編集'),
        actions: [
          if (widget.diary != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteDiary,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveDiary,
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
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '本文',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '本文を入力してください';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
