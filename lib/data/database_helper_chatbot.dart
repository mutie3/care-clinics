import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('messages.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // جدول المحادثات
    await db.execute('''
      CREATE TABLE conversations (
        id $idType,
        title $textType,
        timestamp $integerType
      )
    ''');

    // جدول الرسائل
    await db.execute('''
      CREATE TABLE messages (
        id $idType,
        conversation_id $integerType,
        message $textType,
        sender $textType,
        timestamp $integerType,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id)
      )
    ''');
  }

  // إضافة محادثة جديدة
  Future<int> insertConversation(Map<String, dynamic> conversation) async {
    final db = await instance.database;
    return db.insert('conversations', conversation);
  }

  // إضافة رسالة إلى محادثة معينة
  Future<int> insertMessage(Map<String, dynamic> message) async {
    final db = await instance.database;
    return db.insert('messages', message);
  }

  // جلب كل المحادثات
  Future<List<Map<String, dynamic>>> getConversations() async {
    final db = await instance.database;
    return db.query('conversations', orderBy: 'timestamp DESC');
  }

  // جلب الرسائل الخاصة بمحادثة معينة
  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    final db = await instance.database;
    return db.query('messages',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
        orderBy: 'timestamp ASC');
  }
}
