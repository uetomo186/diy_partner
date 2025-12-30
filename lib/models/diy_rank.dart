import 'package:flutter/material.dart';

class DiyRank {
  final int level;
  final String name;
  final int minCount;
  final String description;
  final Color color;

  const DiyRank({
    required this.level,
    required this.name,
    required this.minCount,
    required this.description,
    required this.color,
  });

  static const List<DiyRank> ranks = [
    DiyRank(
      level: 1,
      name: "ビギナー",
      minCount: 0,
      description: "初めての第一歩。道具を揃え始める段階。",
      color: Colors.lightGreen,
    ),
    DiyRank(
      level: 2,
      name: "ルーキー",
      minCount: 3,
      description: "3日坊主を乗り越え、少し慣れてきた状態。",
      color: Colors.cyan,
    ),
    DiyRank(
      level: 3,
      name: "アマチュア",
      minCount: 10,
      description: "定期的にDIYを楽しむ習慣がついた証。",
      color: Colors.blue,
    ),
    DiyRank(
      level: 4,
      name: "ホビイスト",
      minCount: 25,
      description: "自分のスタイルや好みが分かってくる頃。",
      color: Colors.indigo,
    ),
    DiyRank(
      level: 5,
      name: "クラフトマン",
      minCount: 50,
      description: "周囲からも「DIYが趣味」と認められるレベル。",
      color: Colors.purple,
    ),
    DiyRank(
      level: 6,
      name: "エキスパート",
      minCount: 100,
      description: "複雑な工程もこなし、知識も豊富な状態。",
      color: Colors.orange,
    ),
    DiyRank(
      level: 7,
      name: "マエストロ",
      minCount: 200,
      description: "作品にオリジナリティと高い完成度が宿る。",
      color: Colors.deepOrange,
    ),
    DiyRank(
      level: 8,
      name: "レジェンド",
      minCount: 500,
      description: "DIYの域を超え、もはや創造主の領域。",
      color: Colors.red,
    ),
  ];

  static DiyRank getRank(int postCount) {
    for (var i = ranks.length - 1; i >= 0; i--) {
      if (postCount >= ranks[i].minCount) {
        return ranks[i];
      }
    }
    return ranks[0];
  }

  static DiyRank? getNextRank(int postCount) {
    for (var i = 0; i < ranks.length; i++) {
      if (postCount < ranks[i].minCount) {
        return ranks[i];
      }
    }
    return null; // Already max rank
  }
}
