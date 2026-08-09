```dart
import 'package:sqflite/sqflite.dart';

import '../models/stock_transaction_model.dart';
import '../services/database_service.dart';

class StockTransactionRepository {
  // ============================================================
  // DATABASE
  // ============================================================

  Future<Database> get _db async {
    return await DatabaseService.database;
  }

  // ============================================================
  // INSERT STOCK TRANSACTION
  // ============================================================

  Future<int> insert(
    StockTransactionModel transaction,
  ) async {
    final db = await _db;

    return await db.transaction<int>(
      (txn) async {
        // ======================================================
        // STOCK IN
        // ======================================================

        if (transaction.transactionType == 'IN') {
          await txn.rawUpdate(
            '''
            UPDATE products
            SET stock = stock + ?
            WHERE id = ?
            ''',
            [
              transaction.quantity,
              transaction.productId,
            ],
          );
        }

        // ======================================================
        // STOCK OUT
        // ======================================================

        else if (transaction.transactionType == 'OUT') {
          final product = await txn.query(
            'products',
            columns: ['stock'],
            where: 'id = ?',
            whereArgs: [transaction.productId],
            limit: 1,
          );

          if (product.isEmpty) {
            throw Exception(
              'Product not found.',
            );
          }

          final currentStock =
              (product.first['stock'] as int?) ?? 0;

          if (transaction.quantity > currentStock) {
            throw Exception(
              'Insufficient stock. '
              'Available: $currentStock',
            );
          }

          await txn.rawUpdate(
            '''
            UPDATE products
            SET stock = stock - ?
            WHERE id = ?
            ''',
            [
              transaction.quantity,
              transaction.productId,
            ],
          );
        }

        // ======================================================
        // INVALID TRANSACTION TYPE
        // ======================================================

        else {
          throw Exception(
            'Invalid transaction type: '
            '${transaction.transactionType}',
          );
        }

        // ======================================================
        // SAVE TRANSACTION
        // ======================================================

        return await txn.insert(
          'stock_transactions',
          transaction.toMap(),
          conflictAlgorithm:
              ConflictAlgorithm.replace,
        );
      },
    );
  }

  // ============================================================
  // GET ALL TRANSACTIONS
  // ============================================================

  Future<List<StockTransactionModel>> getAll() async {
    final db = await _db;

    final result = await db.query(
      'stock_transactions',
      orderBy:
          'transaction_date DESC, id DESC',
    );

    return result
        .map(
          (e) => StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // GET TRANSACTION BY ID
  // ============================================================

  Future<StockTransactionModel?> getById(
    int id,
  ) async {
    final db = await _db;

    final result = await db.query(
      'stock_transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return StockTransactionModel.fromMap(
      result.first,
    );
  }

  // ============================================================
  // GET BY PRODUCT
  // ============================================================

  Future<List<StockTransactionModel>> getByProduct(
    int productId,
  ) async {
    final db = await _db;

    final result = await db.query(
      'stock_transactions',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy:
          'transaction_date DESC, id DESC',
    );

    return result
        .map(
          (e) => StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // STOCK IN LIST
  // ============================================================

  Future<List<StockTransactionModel>> getStockIn() async {
    final db = await _db;

    final result = await db.query(
      'stock_transactions',
      where: 'transaction_type = ?',
      whereArgs: ['IN'],
      orderBy:
          'transaction_date DESC, id DESC',
    );

    return result
        .map(
          (e) => StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // STOCK OUT LIST
  // ============================================================

  Future<List<StockTransactionModel>> getStockOut() async {
    final db = await _db;

    final result = await db.query(
      'stock_transactions',
      where: 'transaction_type = ?',
      whereArgs: ['OUT'],
      orderBy:
          'transaction_date DESC, id DESC',
    );

    return result
        .map(
          (e) => StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // SEARCH TRANSACTIONS
  // ============================================================

  Future<List<StockTransactionModel>> search(
    String keyword,
  ) async {
    final db = await _db;

    final searchText = '%$keyword%';

    final result = await db.query(
      'stock_transactions',
      where: '''
        product_name LIKE ?
        OR product_code LIKE ?
        OR reference_no LIKE ?
        OR remarks LIKE ?
        OR transaction_type LIKE ?
      ''',
      whereArgs: [
        searchText,
        searchText,
        searchText,
        searchText,
        searchText,
      ],
      orderBy:
          'transaction_date DESC, id DESC',
    );

    return result
        .map(
          (e) => StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================
  //
  // IMPORTANT:
  // Deleting a transaction must reverse its stock effect.
  //
  // IN  -> stock decreases
  // OUT -> stock increases
  //
  // ============================================================

  Future<int> delete(
    int id,
  ) async {
    final db = await _db;

    return await db.transaction<int>(
      (txn) async {
        final result = await txn.query(
          'stock_transactions',
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );

        if (result.isEmpty) {
          return 0;
        }

        final transaction =
            StockTransactionModel.fromMap(
          result.first,
        );

        // ======================================================
        // REVERSE STOCK IN
        // ======================================================

        if (transaction.transactionType == 'IN') {
          final product = await txn.query(
            'products',
            columns: ['stock'],
            where: 'id = ?',
            whereArgs: [
              transaction.productId,
            ],
            limit: 1,
          );

          if (product.isEmpty) {
            throw Exception(
              'Product not found.',
            );
          }

          final currentStock =
              (product.first['stock'] as int?) ?? 0;

          if (transaction.quantity >
              currentStock) {
            throw Exception(
              'Cannot delete transaction because '
              'current stock is lower than the '
              'transaction quantity.',
            );
          }

          await txn.rawUpdate(
            '''
            UPDATE products
            SET stock = stock - ?
            WHERE id = ?
            ''',
            [
              transaction.quantity,
              transaction.productId,
            ],
          );
        }

        // ======================================================
        // REVERSE STOCK OUT
        // ======================================================

        else if (
            transaction.transactionType == 'OUT') {
          await txn.rawUpdate(
            '''
            UPDATE products
            SET stock = stock + ?
            WHERE id = ?
            ''',
            [
              transaction.quantity,
              transaction.productId,
            ],
          );
        }

        // ======================================================
        // DELETE TRANSACTION
        // ======================================================

        return await txn.delete(
          'stock_transactions',
          where: 'id = ?',
          whereArgs: [id],
        );
      },
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
      FROM stock_transactions
      ''',
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  // ============================================================
  // TOTAL STOCK IN QUANTITY
  // ============================================================

  Future<int> totalStockInQuantity() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(
        SUM(quantity),
        0
      ) AS total
      FROM stock_transactions
      WHERE transaction_type = 'IN'
      ''',
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  // ============================================================
  // TOTAL STOCK OUT QUANTITY
  // ============================================================

  Future<int> totalStockOutQuantity() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(
        SUM(quantity),
        0
      ) AS total
      FROM stock_transactions
      WHERE transaction_type = 'OUT'
      ''',
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  // ============================================================
  // TOTAL PURCHASE AMOUNT
  // ============================================================

  Future<double> totalPurchaseAmount() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(
        SUM(total_amount),
        0
      ) AS total
      FROM stock_transactions
      WHERE transaction_type = 'IN'
      ''',
    );

    if (result.isEmpty) {
      return 0;
    }

    return ((result.first['total'] ?? 0)
            as num)
        .toDouble();
  }

  // ============================================================
  // TOTAL SALES AMOUNT
  // ============================================================

  Future<double> totalSalesAmount() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(
        SUM(total_amount),
        0
      ) AS total
      FROM stock_transactions
      WHERE transaction_type = 'OUT'
      ''',
    );

    if (result.isEmpty) {
      return 0;
    }

    return ((result.first['total'] ?? 0)
            as num)
        .toDouble();
  }

  // ============================================================
  // TODAY'S STOCK IN
  // ============================================================

  Future<List<StockTransactionModel>>
      getTodayStockIn() async {
    final db = await _db;

    final today =
        DateTime.now()
            .toIso8601String()
            .substring(0, 10);

    final result = await db.query(
      'stock_transactions',
      where: '''
        transaction_type = ?
        AND transaction_date LIKE ?
      ''',
      whereArgs: [
        'IN',
        '$today%',
      ],
      orderBy:
          'transaction_date DESC',
    );

    return result
        .map(
          (e) => StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // TODAY'S STOCK OUT
  // ============================================================

  Future<List<StockTransactionModel>>
      getTodayStockOut() async {
    final db = await _db;

    final today =
        DateTime.now()
            .toIso8601String()
            .substring(0, 10);

    final result = await db.query(
      'stock_transactions',
      where: '''
        transaction_type = ?
        AND transaction_date LIKE ?
      ''',
      whereArgs: [
        'OUT',
        '$today%',
      ],
      orderBy:
          'transaction_date DESC',
    );

    return result
        .map(
          (e) => StockTransactionModel.fromMap(e),
        )
        .toList();
  }
}
```
