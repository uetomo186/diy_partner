import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diaries.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE diaries ADD COLUMN color INTEGER NOT NULL DEFAULT 4294967295',
      ); // 0xFFFFFFFF
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE diaries ADD COLUMN aiComment TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE diaries ADD COLUMN imagePath TEXT');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE diaries ( 
  id $idType, 
  title $textType,
  content $textType,
  createdAt $textType,
  color INTEGER NOT NULL,
  aiComment TEXT,
  imagePath TEXT
  )
''');
  }

  Future<Diary> create(Diary diary) async {
    final db = await instance.database;
    final id = await db.insert('diaries', diary.toMap());
    return Diary(
      id: id,
      title: diary.title,
      content: diary.content,
      createdAt: diary.createdAt,
      color: diary.color,
      imagePath: diary.imagePath,
      aiComment: diary.aiComment,
    );
  }

  Future<Diary> readDiary(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'diaries',
      columns: [
        'id',
        'title',
        'content',
        'createdAt',
        'color',
        'aiComment',
        'imagePath',
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Diary.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Diary>> readAllDiaries() async {
    final db = await instance.database;
    const orderBy = 'createdAt DESC';
    final result = await db.query('diaries', orderBy: orderBy);

    return result.map((json) => Diary.fromMap(json)).toList();
  }

  Future<int> update(Diary diary) async {
    final db = await instance.database;

    return db.update(
      'diaries',
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
