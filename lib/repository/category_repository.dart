import 'package:sqflite/sqflite.dart';

import '../models/category_model.dart';
import '../services/database_service.dart';

class CategoryRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<Database> get _db async => await _databaseService.database;

  Future<int> insert(CategoryModel category) async {
    final db = await _db;

    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CategoryModel>> getAll() async {
    final db = await _db;

    final result = await db.query('categories', orderBy: 'name ASC');

    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<CategoryModel?> getById(int id) async {
    final db = await _db;

    final result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return CategoryModel.fromMap(result.first);
  }

  Future<List<CategoryModel>> search(String keyword) async {
    final db = await _db;

    final result = await db.query(
      'categories',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'name ASC',
    );

    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<int> update(CategoryModel category) async {
    final db = await _db;

    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;

    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count() async {
    final db = await _db;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM categories',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
