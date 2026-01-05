import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/diary.dart';
import '../providers/diary_providers.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryListAsync = ref.watch(diaryListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Lighter background
      appBar: AppBar(
        title: const Text(
          'DIY Diary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: diaryListAsync.when(
        data: (diaryList) {
          if (diaryList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    '新しい日記を作成しましょう',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: diaryList.length,
              itemBuilder: (context, index) {
                final diary = diaryList[index];
                return _buildDiaryCard(context, diary);
              },
            ),
          );
        },
        error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/diary/edit');
        },
        backgroundColor: Colors.black87,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDiaryCard(BuildContext context, Diary diary) {
    final bgColor = Color(diary.color);

    // Determine text colors
    final isDark = bgColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;
    final contentColor = isDark ? Colors.white70 : Colors.black54;

    return GestureDetector(
      onTap: () {
        context.push('/diary/edit', extra: diary);
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ), // Added border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diary.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              diary.content,
              style: TextStyle(fontSize: 13, color: contentColor, height: 1.4),
              maxLines: 6, // Show more content in masonry
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('MM/dd').format(diary.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: contentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
