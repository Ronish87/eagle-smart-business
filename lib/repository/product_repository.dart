import '../models/product_model.dart';
import '../services/database_service.dart';

class ProductRepository {
  // ============================================================
  // DATABASE
  // ============================================================

  Future get _db async => await DatabaseService.instance.database;

  // ============================================================
  // INSERT PRODUCT
  // ============================================================

  Future<int> insert(ProductModel product) async {
    final db = await _db;

    return await db.insert('products', product.toMap());
  }

  // ============================================================
  // GET ALL PRODUCTS
  // ============================================================

  Future<List<ProductModel>> getAll() async {
    final db = await _db;

    final rows = await db.query('products', orderBy: 'name ASC');

    return rows.map((e) => ProductModel.fromMap(e)).toList();
  }

  // ============================================================
  // GET PRODUCT BY ID
  // ============================================================

  Future<ProductModel?> getById(int id) async {
    final db = await _db;

    final rows = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return ProductModel.fromMap(rows.first);
  }

  // ============================================================
  // SEARCH PRODUCTS
  // ============================================================

  Future<List<ProductModel>> search(String keyword) async {
    final db = await _db;

    final rows = await db.query(
      'products',
      where: '''
        code LIKE ?
        OR barcode LIKE ?
        OR name LIKE ?
        OR category LIKE ?
        OR brand LIKE ?
        OR supplier LIKE ?
      ''',
      whereArgs: [
        '%$keyword%',
        '%$keyword%',
        '%$keyword%',
        '%$keyword%',
        '%$keyword%',
        '%$keyword%',
      ],
      orderBy: 'name ASC',
    );

    return rows.map((e) => ProductModel.fromMap(e)).toList();
  }

  // ============================================================
  // UPDATE PRODUCT
  // ============================================================

  Future<int> update(ProductModel product) async {
    final db = await _db;

    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<int> delete(int id) async {
    final db = await _db;

    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  // INCREASE STOCK
  // ============================================================

  Future<int> increaseStock(int productId, int quantity) async {
    if (quantity <= 0) {
      return 0;
    }

    final db = await _db;

    return await db.rawUpdate(
      '''
      UPDATE products
      SET stock = stock + ?
      WHERE id = ?
      ''',
      [quantity, productId],
    );
  }

  // ============================================================
  // DECREASE STOCK
  // ============================================================

  Future<int> decreaseStock(int productId, int quantity) async {
    if (quantity <= 0) {
      return 0;
    }

    final db = await _db;

    return await db.rawUpdate(
      '''
      UPDATE products
      SET stock = stock - ?
      WHERE id = ?
      AND stock >= ?
      ''',
      [quantity, productId, quantity],
    );
  }

  // ============================================================
  // GET CURRENT STOCK
  // ============================================================

  Future<int> getStock(int productId) async {
    final db = await _db;

    final result = await db.query(
      'products',
      columns: ['stock'],
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );

    if (result.isEmpty) {
      return 0;
    }

    return (result.first['stock'] as int?) ?? 0;
  }

  // ============================================================
  // LOW STOCK PRODUCTS
  // ============================================================

  Future<List<ProductModel>> getLowStockProducts() async {
    final db = await _db;

    final rows = await db.query(
      'products',
      where: 'stock <= minimum_stock',
      orderBy: 'stock ASC',
    );

    return rows.map((e) => ProductModel.fromMap(e)).toList();
  }

  // ============================================================
  // ACTIVE PRODUCTS
  // ============================================================

  Future<List<ProductModel>> getActiveProducts() async {
    final db = await _db;

    final rows = await db.query(
      'products',
      where: 'active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return rows.map((e) => ProductModel.fromMap(e)).toList();
  }

  // ============================================================
  // COUNT PRODUCTS
  // ============================================================

  Future<int> count() async {
    final db = await _db;

    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM products');

    if (result.isEmpty) {
      return 0;
    }

    return (result.first['total'] as int?) ?? 0;
  }

  // ============================================================
  // TOTAL STOCK QUANTITY
  // ============================================================

  Future<int> totalStock() async {
    final db = await _db;

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(stock), 0) AS total FROM products',
    );

    if (result.isEmpty) {
      return 0;
    }

    return (result.first['total'] as int?) ?? 0;
  }
}
