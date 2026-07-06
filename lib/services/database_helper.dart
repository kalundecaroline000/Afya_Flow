import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 1. Singleton pattern
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
    // Create Hospitals table
    await db.execute('''
      CREATE TABLE hospitals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL
      )
    ''');

    // ✅ Create Users table for Login
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  // ✅ Method to Register a User
  Future<int> registerUser(String name, String email, String password) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  // ✅ Method to Login a User
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // 🚀 NEW METHOD: This caches the hospitals fetched from your service!
  Future<void> cacheHospital(Map<String, dynamic> hospitalData) async {
    final db = await database;
    await db.insert(
      'hospitals',
      hospitalData,
      conflictAlgorithm: ConflictAlgorithm.replace, // Replaces if the hospital already exists
    );
  }
  Future<List<Map<String,dynamic>>> getAllHospitals() async {
    final db = await database;
    return await db.query('hospitals');
  }
}