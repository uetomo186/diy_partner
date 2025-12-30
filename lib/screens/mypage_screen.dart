import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:go_router/go_router.dart';
import '../models/diy_rank.dart';
import '../providers/diary_providers.dart';
import '../providers/user_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final userStateAsync = ref.watch(userProvider);
    final diaryListAsync = ref.watch(diaryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('マイページ')),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // User Profile Placeholder
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    userStateAsync.when(
                      data: (user) {
                        return GestureDetector(
                          onTap: () {
                            if (user.profileImagePath != null) {
                              context.push(
                                '/mypage/preview',
                                extra: user.profileImagePath,
                              );
                            }
                          },
                          child: Hero(
                            tag: 'profile_image',
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey,
                              backgroundImage: user.profileImagePath != null
                                  ? FileImage(File(user.profileImagePath!))
                                  : null,
                              child: user.profileImagePath == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                      loading: () => const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: (_, __) => const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, size: 20, color: Colors.black),
                      ),
                      onPressed: () {
                        ref.read(userProvider.notifier).pickImage();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                userStateAsync.when(
                  data: (user) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final textController = TextEditingController(
                                text: user.userName,
                              );
                              return AlertDialog(
                                title: const Text('ユーザー名の変更'),
                                content: TextField(
                                  controller: textController,
                                  decoration: const InputDecoration(
                                    hintText: '新しいユーザー名を入力',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('キャンセル'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (textController.text.isNotEmpty) {
                                        ref
                                            .read(userProvider.notifier)
                                            .updateUserName(
                                              textController.text,
                                            );
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Text('保存'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  loading: () => const Text('Loading...'),
                  error: (_, __) => const Text('Error'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // DIY Rank Card
          if (diaryListAsync.hasValue)
            Builder(
              builder: (context) {
                final diaries = diaryListAsync.value!;
                final postCount = diaries.length;
                final currentRank = DiyRank.getRank(postCount);
                final nextRank = DiyRank.getNextRank(postCount);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        currentRank.color.withOpacity(0.8),
                        currentRank.color,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: currentRank.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '現在のDIYランク',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lv.${currentRank.level} ${currentRank.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentRank.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (nextRank != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '次のランクまであと ${nextRank.minCount - postCount} 投稿',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '最高ランク到達！',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
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
                      child: const Text(
                        '削除',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(diaryListProvider.notifier).deleteAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('全ての日記を削除しました')));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
