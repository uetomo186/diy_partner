class Diary {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int color;
  final String? aiComment;
  final String? imagePath;

  Diary({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.color = 0xFFFFFFFF,
    this.aiComment,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
      'aiComment': aiComment,
      'imagePath': imagePath,
    };
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      color: map['color'] ?? 0xFFFFFFFF,
      aiComment: map['aiComment'],
      imagePath: map['imagePath'],
    );
  }

  Diary copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    int? color,
    String? aiComment,
    String? imagePath,
  }) {
    return Diary(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      aiComment: aiComment ?? this.aiComment,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
