class Diary {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int color;

  Diary({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.color = 0xFFFFFFFF,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
    };
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      color: map['color'] ?? 0xFFFFFFFF,
    );
  }

  Diary copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    int? color,
  }) {
    return Diary(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
    );
  }
}
