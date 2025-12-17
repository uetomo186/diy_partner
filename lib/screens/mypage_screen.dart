import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:go_router/go_router.dart';
import '../providers/diary_providers.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  Future<void> _deleteAllDiaries() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('全データ削除'),
        content: const Text('本当に全ての日記データを削除しますか？\nこの操作は取り消せません。'),
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
      // Use the notifier to clear data.
      // Since we don't have a "bulk delete" in the notifier yet, we can
      // iterate or add a method. For minimal changes, we can use the DB directly
      // but triggering a refresh is better. Let's stick to DB direct for "Danger Zone"
      // but ensure provider is invalidated or refreshed if needed.
      // Ideally notifier should have a clearAll method.
      // For now, let's keep the existing logic but maybe invalidate the provider?
      // Actually, let's just invalidate the provider after deletion.
      
      // Accessing DB directly here for simplicity as notifier methods are single-item specific currently.
      // A better refactor would add `deleteAll` to `DiaryListNotifier`.
      final notifier = ref.read(diaryListProvider.notifier);
      // However, we don't have access to DB directly here unless we import it,
      // and we want to avoid mixing patterns. The clean way is to rely on provider side effects.
      // Since we didn't add deleteAll to provider, let's import helper just for this
      // or simply rely on the fact that we can create a quick provider method if we want.
      // Let's use the DB helper directly for now as this is a "System" action.
      // AND invalidate the list.
      
      // Wait, we can't import DatabaseHelper here if we want to be clean.
      // But we can just use the provider to refresh.
      // Let's assume we won't add a new method to provider to save tokens,
      // and just use the helper which is already imported in the original code?
      // Oh, I see I should keep the import if I use it.
      
      // BUT, to be "Riverpod-y", I should really move this logic to the provider.
      // Let's simpler: just use what we had, but invalidate the provider.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('マイページ')),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // User Profile Placeholder
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'User Name',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('設定', style: TextStyle(color: Colors.grey)),
          ),
          
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('バージョン情報'),
            trailing: Text(_version.isEmpty ? 'Loading...' : _version),
          ),
          
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('日記データの全削除', style: TextStyle(color: Colors.red)),
            onTap: () async {
               final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('全データ削除'),
                  content: const Text('本当に全ての日記データを削除しますか？\nこの操作は取り消せません。'),
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
                await ref.read(diaryListProvider.notifier).deleteAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('全ての日記を削除しました')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
