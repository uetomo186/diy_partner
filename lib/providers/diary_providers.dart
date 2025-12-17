import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary.dart';
import '../utils/database_helper.dart';

// AsyncNotifier to handle list of diaries
class DiaryListNotifier extends AsyncNotifier<List<Diary>> {
  @override
  Future<List<Diary>> build() async {
    return _fetchAll();
  }

  Future<List<Diary>> _fetchAll() async {
    return await DatabaseHelper.instance.readAllDiaries();
  }

  Future<void> addDiary(Diary diary) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await DatabaseHelper.instance.create(diary);
      return _fetchAll();
    });
  }

  Future<void> updateDiary(Diary diary) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await DatabaseHelper.instance.update(diary);
      return _fetchAll();
    });
  }

  Future<void> deleteDiary(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await DatabaseHelper.instance.delete(id);
      return _fetchAll();
    });
  }

  Future<void> deleteAll() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = await DatabaseHelper.instance.database;
      await db.delete('diaries');
      return [];
    });
  }
}

final diaryListProvider =
    AsyncNotifierProvider<DiaryListNotifier, List<Diary>>(DiaryListNotifier.new);
