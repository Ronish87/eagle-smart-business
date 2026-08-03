import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    String dbPath = await getDatabasesPath();

    String path = join(dbPath, 'eagle_smart_business.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE clients(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            company_name TEXT,
            owner_name TEXT,
            admin_name TEXT,
            mobile TEXT,
            whatsapp TEXT,
            email TEXT,
            business_type TEXT,
            web_access INTEGER,
            mobile_access INTEGER
          )
        ''');
      },
    );
  }
}
