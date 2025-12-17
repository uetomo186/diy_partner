import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/diary.dart';
import '../utils/database_helper.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late Future<List<Diary>> _diaryListFuture;

  @override
  void initState() {
    super.initState();
    _refreshDiaryList();
  }

  void _refreshDiaryList() {
    setState(() {
      _diaryListFuture = DatabaseHelper.instance.readAllDiaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('日記')),
      body: FutureBuilder<List<Diary>>(
        future: _diaryListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('日記はまだありません'));
          }

          final diaries = snapshot.data!;
          return ListView.builder(
            itemCount: diaries.length,
            itemBuilder: (context, index) {
              final diary = diaries[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    diary.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('yyyy/MM/dd HH:mm').format(diary.createdAt),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final result = await context.push('/diary/edit', extra: diary);
                    if (result == true) {
                      _refreshDiaryList();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/diary/edit');
          if (result == true) {
            _refreshDiaryList();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
