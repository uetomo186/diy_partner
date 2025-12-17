import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/diary.dart';
import '../providers/diary_providers.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryListAsync = ref.watch(diaryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('DIY日記')),
      body: diaryListAsync.when(
        data: (diaryList) {
          if (diaryList.isEmpty) {
            return const Center(child: Text('日記はまだありません'));
          }
          return ListView.builder(
            itemCount: diaryList.length,
            itemBuilder: (context, index) {
              final diary = diaryList[index];
              return Card(
                child: ListTile(
                  title: Text(diary.title),
                  subtitle: Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(diary.createdAt)),
                  onTap: () {
                    context.push('/diary/edit', extra: diary);
                  },
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/diary/edit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
