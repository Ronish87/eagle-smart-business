```dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._privateConstructor();

  static final DatabaseService instance =
      DatabaseService._privateConstructor();

  static Database? _database;

  // ============================================================
  // DATABASE GETTER
  // ============================================================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  // ============================================================
  // INIT DATABASE
  // ============================================================

  Future<Database> _initDatabase() async {
    final dbPath =
        await getDatabasesPath();

    final path = join(
      dbPath,
      'eagle_smart_business.db',
    );

    return await openDatabase(
      path,

      version: 4,

      onCreate: _createDatabase,

      onUpgrade: _onUpgrade,
    );
  }

  // ============================================================
  // CREATE DATABASE
  // ============================================================

  Future<void> _createDatabase(
    Database db,
    int version,
  ) async {
    // ==========================================================
    // CLIENTS
    // ==========================================================

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

        address TEXT,

        district TEXT,

        province TEXT,

        country TEXT,

        pan_no TEXT,

        vat_no TEXT,

        registration_no TEXT,

        web_access INTEGER DEFAULT 0,

        mobile_access INTEGER DEFAULT 0,

        status TEXT DEFAULT 'Active',

        created_date TEXT
      )
    ''');

    // ==========================================================
    // CATEGORIES
    // ==========================================================

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        name TEXT NOT NULL,

        description TEXT,

        isActive INTEGER DEFAULT 1,

        createdAt TEXT NOT NULL
      )
    ''');

    // ==========================================================
    // BRANDS
    // ==========================================================

    await db.execute('''
      CREATE TABLE brands(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        name TEXT NOT NULL,

        description TEXT,

        isActive INTEGER DEFAULT 1,

        createdAt TEXT NOT NULL
      )
    ''');

    // ==========================================================
    // SUPPLIERS
    // ==========================================================

    await db.execute('''
      CREATE TABLE suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        supplierCode TEXT NOT NULL UNIQUE,

        supplierName TEXT NOT NULL,

        contactPerson TEXT,

        phone TEXT,

        email TEXT,

        address TEXT,

        panNumber TEXT,

        remarks TEXT,

        isActive INTEGER DEFAULT 1,

        createdAt TEXT NOT NULL
      )
    ''');

    // ==========================================================
    // PRODUCTS
    // ==========================================================

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        code TEXT NOT NULL UNIQUE,

        barcode TEXT,

        name TEXT NOT NULL,

        category TEXT NOT NULL,

        brand TEXT NOT NULL,

        supplier TEXT NOT NULL,

        unit TEXT NOT NULL,

        purchase_price REAL NOT NULL DEFAULT 0,

        selling_price REAL NOT NULL DEFAULT 0,

        stock INTEGER NOT NULL DEFAULT 0,

        minimum_stock INTEGER NOT NULL DEFAULT 0,

        image TEXT,

        active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // ==========================================================
    // STOCK TRANSACTIONS
    // ==========================================================

    await db.execute('''
      CREATE TABLE stock_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        product_id INTEGER,

        product_code TEXT NOT NULL,

        product_name TEXT NOT NULL,

        transaction_type TEXT NOT NULL,

        quantity INTEGER NOT NULL DEFAULT 0,

        unit_price REAL NOT NULL DEFAULT 0,

        total_amount REAL NOT NULL DEFAULT 0,

        reference_no TEXT,

        created_by TEXT,

        transaction_date TEXT NOT NULL,

        remarks TEXT,

        FOREIGN KEY(product_id)
          REFERENCES products(id)
          ON DELETE SET NULL
      )
    ''');

    // ==========================================================
    // INDEXES
    // ==========================================================

    await db.execute('''
      CREATE INDEX idx_products_code
      ON products(code)
    ''');

    await db.execute('''
      CREATE INDEX idx_products_barcode
      ON products(barcode)
    ''');

    await db.execute('''
      CREATE INDEX idx_products_name
      ON products(name)
    ''');

    await db.execute('''
      CREATE INDEX idx_stock_transactions_product
      ON stock_transactions(product_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_stock_transactions_type
      ON stock_transactions(transaction_type)
    ''');

    await db.execute('''
      CREATE INDEX idx_stock_transactions_date
      ON stock_transactions(transaction_date)
    ''');
  }

  // ============================================================
  // DATABASE UPGRADE
  // ============================================================

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // ==========================================================
    // VERSION 1 -> VERSION 2
    // ==========================================================

    if (oldVersion < 2) {
      await _upgradeClientsToV2(
        db,
      );
    }

    // ==========================================================
    // VERSION 2 -> VERSION 3
    // ==========================================================

    if (oldVersion < 3) {
      await _createMasterTables(
        db,
      );
    }

    // ==========================================================
    // VERSION 3 -> VERSION 4
    // ==========================================================

    if (oldVersion < 4) {
      await _createProductsAndStockTables(
        db,
      );
    }
  }

  // ============================================================
  // CLIENT UPGRADE
  // ============================================================

  Future<void> _upgradeClientsToV2(
    Database db,
  ) async {
    await _addColumnIfNotExists(
      db,
      'clients',
      'address',
      'TEXT DEFAULT \'\'',
    );

    await _addColumnIfNotExists(
      db,
      'clients',
      'district',
      'TEXT DEFAULT \'\'',
    );

    await _addColumnIfNotExists(
      db,
      'clients',
      'province',
      'TEXT DEFAULT \'\'',
    );

    await _addColumnIfNotExists(
      db,
      'clients',
      'country',
      'TEXT DEFAULT \'\'',
    );

    await _addColumnIfNotExists(
      db,
      'clients',
      'pan_no',
      'TEXT DEFAULT \'\'',
    );

    await _addColumnIfNotExists(
      db,
      'clients',
      'vat_no',
      'TEXT DEFAULT \'\'',
    );

    await _addColumnIfNotExists(
      db,
      'clients',
      'registration_no',
      'TEXT DEFAULT \'\'',
    );

    await _addColumnIfNotExists(
      db,
      'clients',
      'status',
      'TEXT DEFAULT \'Active\'',
    );

    await _addColumnIfNotExists(
      db,
      'clients',
      'created_date',
      'TEXT DEFAULT \'\'',
    );
  }

  // ============================================================
  // CREATE MASTER TABLES
  // ============================================================

  Future<void> _createMasterTables(
    Database db,
  ) async {
    // ----------------------------------------------------------
    // CATEGORIES
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        name TEXT NOT NULL,

        description TEXT,

        isActive INTEGER DEFAULT 1,

        createdAt TEXT NOT NULL
      )
    ''');

    // ----------------------------------------------------------
    // BRANDS
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS brands(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        name TEXT NOT NULL,

        description TEXT,

        isActive INTEGER DEFAULT 1,

        createdAt TEXT NOT NULL
      )
    ''');

    // ----------------------------------------------------------
    // SUPPLIERS
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        supplierCode TEXT NOT NULL UNIQUE,

        supplierName TEXT NOT NULL,

        contactPerson TEXT,

        phone TEXT,

        email TEXT,

        address TEXT,

        panNumber TEXT,

        remarks TEXT,

        isActive INTEGER DEFAULT 1,

        createdAt TEXT NOT NULL
      )
    ''');
  }

  // ============================================================
  // CREATE PRODUCTS + STOCK TABLES
  // ============================================================

  Future<void> _createProductsAndStockTables(
    Database db,
  ) async {
    // ----------------------------------------------------------
    // PRODUCTS
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        code TEXT NOT NULL UNIQUE,

        barcode TEXT,

        name TEXT NOT NULL,

        category TEXT NOT NULL,

        brand TEXT NOT NULL,

        supplier TEXT NOT NULL,

        unit TEXT NOT NULL,

        purchase_price REAL NOT NULL DEFAULT 0,

        selling_price REAL NOT NULL DEFAULT 0,

        stock INTEGER NOT NULL DEFAULT 0,

        minimum_stock INTEGER NOT NULL DEFAULT 0,

        image TEXT,

        active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // ----------------------------------------------------------
    // STOCK TRANSACTIONS
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        product_id INTEGER,

        product_code TEXT NOT NULL,

        product_name TEXT NOT NULL,

        transaction_type TEXT NOT NULL,

        quantity INTEGER NOT NULL DEFAULT 0,

        unit_price REAL NOT NULL DEFAULT 0,

        total_amount REAL NOT NULL DEFAULT 0,

        reference_no TEXT,

        created_by TEXT,

        transaction_date TEXT NOT NULL,

        remarks TEXT,

        FOREIGN KEY(product_id)
          REFERENCES products(id)
          ON DELETE SET NULL
      )
    ''');

    // ----------------------------------------------------------
    // INDEXES
    // ----------------------------------------------------------

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_products_code
      ON products(code)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_products_barcode
      ON products(barcode)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_products_name
      ON products(name)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_stock_transactions_product
      ON stock_transactions(product_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_stock_transactions_type
      ON stock_transactions(transaction_type)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_stock_transactions_date
      ON stock_transactions(transaction_date)
    ''');
  }

  // ============================================================
  // ADD COLUMN SAFELY
  // ============================================================

  Future<void> _addColumnIfNotExists(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final columns =
        await db.rawQuery(
      'PRAGMA table_info($table)',
    );

    final exists = columns.any(
      (columnInfo) =>
          columnInfo['name'] == column,
    );

    if (!exists) {
      await db.execute(
        'ALTER TABLE $table '
        'ADD COLUMN $column $definition',
      );
    }
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();

      _database = null;
    }
  }

  // ============================================================
  // DELETE DATABASE
  // ============================================================
  //
  // USE ONLY DURING DEVELOPMENT / RESET.
  // THIS WILL DELETE ALL DATA.
  //
  // ============================================================

  Future<void> deleteDatabaseFile() async {
    await closeDatabase();

    final dbPath =
        await getDatabasesPath();

    final path = join(
      dbPath,
      'eagle_smart_business.db',
    );

    await deleteDatabase(
      path,
    );
  }
}
```
