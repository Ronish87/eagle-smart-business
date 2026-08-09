import 'package:sqflite/sqflite.dart';

import '../models/brand_model.dart';
import '../services/database_service.dart';

class BrandRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<Database> get _db async => await _databaseService.database;

  Future<int> insert(BrandModel brand) async {
    final db = await _db;

    return await db.insert(
      'brands',
      brand.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BrandModel>> getAll() async {
    final db = await _db;

    final result = await db.query('brands', orderBy: 'name ASC');

    return result.map((e) => BrandModel.fromMap(e)).toList();
  }

  Future<BrandModel?> getById(int id) async {
    final db = await _db;

    final result = await db.query(
      'brands',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return BrandModel.fromMap(result.first);
  }

  Future<List<BrandModel>> search(String keyword) async {
    final db = await _db;

    final result = await db.query(
      'brands',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'name ASC',
    );

    return result.map((e) => BrandModel.fromMap(e)).toList();
  }

  Future<int> update(BrandModel brand) async {
    final db = await _db;

    return await db.update(
      'brands',
      brand.toMap(),
      where: 'id = ?',
      whereArgs: [brand.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;

    return await db.delete('brands', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count() async {
    final db = await _db;

    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM brands');

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
