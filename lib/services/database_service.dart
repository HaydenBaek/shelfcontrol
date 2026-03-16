import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/book.dart';

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService instance = DatabaseService._internal();

  static const String _databaseName = 'shelfcontrol.db';
  static const String booksTable = 'books';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _databaseName);

    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $booksTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            author TEXT NOT NULL,
            coverUrl TEXT NOT NULL,
            status TEXT NOT NULL,
            notes TEXT NOT NULL,
            rating INTEGER NOT NULL,
            currentPage INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $booksTable ADD COLUMN currentPage INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  Future<List<Book>> getBooks() async {
    final db = await database;
    final maps = await db.query(booksTable, orderBy: 'title COLLATE NOCASE');
    return maps.map(Book.fromMap).toList();
  }

  Future<Book> insertBook(Book book) async {
    final db = await database;
    final id = await db.insert(booksTable, book.toMap());
    return book.copyWith(id: id);
  }

  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update(
      booksTable,
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBook(int id) async {
    final db = await database;
    await db.delete(booksTable, where: 'id = ?', whereArgs: [id]);
  }
}
