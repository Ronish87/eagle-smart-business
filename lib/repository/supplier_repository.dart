import 'package:sqflite/sqflite.dart';

import '../models/supplier_model.dart';
import '../services/database_service.dart';

class SupplierRepository {
  final DatabaseService _databaseService =
      DatabaseService.instance;

  Future<Database> get _db async =>
      await _databaseService.database;

  // ============================================================
  // INSERT
  // ============================================================

  Future<int> insert(
    SupplierModel supplier,
  ) async {
    final db = await _db;

    return await db.insert(
      'suppliers',
      supplier.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.abort,
    );
  }

  // ============================================================
  // GET ALL
  // ============================================================

  Future<List<SupplierModel>> getAll() async {
    final db = await _db;

    final result = await db.query(
      'suppliers',
      orderBy: 'supplierName ASC',
    );

    return result
        .map(
          (e) => SupplierModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // GET ACTIVE SUPPLIERS
  // ============================================================

  Future<List<SupplierModel>> getActive() async {
    final db = await _db;

    final result = await db.query(
      'suppliers',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'supplierName ASC',
    );

    return result
        .map(
          (e) => SupplierModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // GET INACTIVE SUPPLIERS
  // ============================================================

  Future<List<SupplierModel>> getInactive() async {
    final db = await _db;

    final result = await db.query(
      'suppliers',
      where: 'isActive = ?',
      whereArgs: [0],
      orderBy: 'supplierName ASC',
    );

    return result
        .map(
          (e) => SupplierModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // GET BY ID
  // ============================================================

  Future<SupplierModel?> getById(
    int id,
  ) async {
    final db = await _db;

    final result = await db.query(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return SupplierModel.fromMap(
      result.first,
    );
  }

  // ============================================================
  // GET BY CODE
  // ============================================================

  Future<SupplierModel?> getByCode(
    String code,
  ) async {
    final db = await _db;

    final result = await db.query(
      'suppliers',
      where: 'supplierCode = ?',
      whereArgs: [code],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return SupplierModel.fromMap(
      result.first,
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<List<SupplierModel>> search(
    String keyword,
  ) async {
    final db = await _db;

    final value =
        keyword.trim();

    if (value.isEmpty) {
      return getAll();
    }

    final result = await db.query(
      'suppliers',

      where: '''
        supplierCode LIKE ?
        OR supplierName LIKE ?
        OR contactPerson LIKE ?
        OR phone LIKE ?
        OR email LIKE ?
        OR panNumber LIKE ?
      ''',

      whereArgs: [
        '%$value%',
        '%$value%',
        '%$value%',
        '%$value%',
        '%$value%',
        '%$value%',
      ],

      orderBy:
          'supplierName ASC',
    );

    return result
        .map(
          (e) => SupplierModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<int> update(
    SupplierModel supplier,
  ) async {
    final db = await _db;

    if (supplier.id == null) {
      throw ArgumentError(
        'Supplier ID is required for update.',
      );
    }

    return await db.update(
      'suppliers',
      supplier.toMap(),

      where: 'id = ?',

      whereArgs: [
        supplier.id,
      ],
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<int> delete(
    int id,
  ) async {
    final db = await _db;

    return await db.delete(
      'suppliers',

      where: 'id = ?',

      whereArgs: [id],
    );
  }

  // ============================================================
  // SET ACTIVE
  // ============================================================

  Future<int> activate(
    int id,
  ) async {
    final db = await _db;

    return await db.update(
      'suppliers',

      {
        'isActive': 1,
      },

      where: 'id = ?',

      whereArgs: [id],
    );
  }

  // ============================================================
  // SET INACTIVE
  // ============================================================

  Future<int> deactivate(
    int id,
  ) async {
    final db = await _db;

    return await db.update(
      'suppliers',

      {
        'isActive': 0,
      },

      where: 'id = ?',

      whereArgs: [id],
    );
  }

  // ============================================================
  // COUNT ALL
  // ============================================================

  Future<int> count() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM suppliers
      ''',
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  // ============================================================
  // COUNT ACTIVE
  // ============================================================

  Future<int> countActive() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM suppliers
      WHERE isActive = 1
      ''',
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  // ============================================================
  // COUNT INACTIVE
  // ============================================================

  Future<int> countInactive() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM suppliers
      WHERE isActive = 0
      ''',
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  // ============================================================
  // CHECK CODE EXISTS
  // ============================================================

  Future<bool> codeExists(
    String code, {
    int? excludeId,
  }) async {
    final db = await _db;

    String where =
        'supplierCode = ?';

    final List<dynamic> args = [
      code,
    ];

    if (excludeId != null) {
      where +=
          ' AND id != ?';

      args.add(excludeId);
    }

    final result = await db.query(
      'suppliers',

      columns: ['id'],

      where: where,

      whereArgs: args,

      limit: 1,
    );

    return result.isNotEmpty;
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  Future<int> deleteAll() async {
    final db = await _db;

    return await db.delete(
      'suppliers',
    );
  }
}
