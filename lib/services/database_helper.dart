import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('afya_flow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hospitals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL
      )
    ''');
  }

  // ✅ Method to save/cache a hospital
  Future<void> cacheHospital(String id, String name, String location) async {
    final db = await instance.database;
    await db.insert(
      'hospitals',
      {'id': id, 'name': name, 'location': location},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ✅ NEW: Method to retrieve all cached hospitals for the Dashboard
  Future<List<Map<String, dynamic>>> getAllHospitals() async {
    final db = await instance.database;
    return await db.query('hospitals');
  }
}