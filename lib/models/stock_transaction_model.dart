```dart
import 'package:sqflite/sqflite.dart';

import '../models/stock_transaction_model.dart';
import '../services/database_service.dart';

class StockTransactionRepository {
  final DatabaseService _databaseService =
      DatabaseService.instance;

  Future<Database> get _db async =>
      await _databaseService.database;

  // ============================================================
  // INSERT
  // ============================================================

  Future<int> insert(
    StockTransactionModel transaction,
  ) async {
    final db = await _db;

    return await db.transaction(
      (txn) async {
        // Insert transaction
        final transactionId =
            await txn.insert(
          'stock_transactions',
          transaction.toMap(),
        );

        // Update product stock
        await _updateProductStock(
          txn,
          transaction.productId,
          transaction.quantity,
          transaction.transactionType,
        );

        return transactionId;
      },
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<int> update(
    StockTransactionModel transaction,
  ) async {
    if (transaction.id == null) {
      throw ArgumentError(
        'Transaction ID is required for update.',
      );
    }

    final db = await _db;

    return await db.transaction(
      (txn) async {
        // Get old transaction
        final oldRows = await txn.query(
          'stock_transactions',
          where: 'id = ?',
          whereArgs: [transaction.id],
          limit: 1,
        );

        if (oldRows.isEmpty) {
          throw Exception(
            'Stock transaction not found.',
          );
        }

        final oldTransaction =
            StockTransactionModel.fromMap(
          oldRows.first,
        );

        // Reverse old stock effect
        await _reverseStockEffect(
          txn,
          oldTransaction,
        );

        // Update transaction
        final result =
            await txn.update(
          'stock_transactions',
          transaction.toMap(),
          where: 'id = ?',
          whereArgs: [transaction.id],
        );

        // Apply new stock effect
        await _updateProductStock(
          txn,
          transaction.productId,
          transaction.quantity,
          transaction.transactionType,
        );

        return result;
      },
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<int> delete(
    int id,
  ) async {
    final db = await _db;

    return await db.transaction(
      (txn) async {
        final rows = await txn.query(
          'stock_transactions',
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );

        if (rows.isEmpty) {
          return 0;
        }

        final transaction =
            StockTransactionModel.fromMap(
          rows.first,
        );

        // Reverse stock
        await _reverseStockEffect(
          txn,
          transaction,
        );

        // Delete transaction
        return await txn.delete(
          'stock_transactions',
          where: 'id = ?',
          whereArgs: [id],
        );
      },
    );
  }

  // ============================================================
  // GET ALL
  // ============================================================

  Future<List<StockTransactionModel>>
      getAll() async {
    final db = await _db;

    final rows = await db.query(
      'stock_transactions',
      orderBy:
          'transaction_date DESC, id DESC',
    );

    return rows
        .map(
          (e) =>
              StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // GET BY ID
  // ============================================================

  Future<StockTransactionModel?> getById(
    int id,
  ) async {
    final db = await _db;

    final rows = await db.query(
      'stock_transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return StockTransactionModel.fromMap(
      rows.first,
    );
  }

  // ============================================================
  // STOCK IN
  // ============================================================

  Future<List<StockTransactionModel>>
      getStockIn() async {
    final db = await _db;

    final rows = await db.query(
      'stock_transactions',
      where: 'transaction_type = ?',
      whereArgs: ['IN'],
      orderBy:
          'transaction_date DESC, id DESC',
    );

    return rows
        .map(
          (e) =>
              StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // STOCK OUT
  // ============================================================

  Future<List<StockTransactionModel>>
      getStockOut() async {
    final db = await _db;

    final rows = await db.query(
      'stock_transactions',
      where: 'transaction_type = ?',
      whereArgs: ['OUT'],
      orderBy:
          'transaction_date DESC, id DESC',
    );

    return rows
        .map(
          (e) =>
              StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // PRODUCT TRANSACTIONS
  // ============================================================

  Future<List<StockTransactionModel>>
      getByProductId(
    int productId,
  ) async {
    final db = await _db;

    final rows = await db.query(
      'stock_transactions',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy:
          'transaction_date DESC, id DESC',
    );

    return rows
        .map(
          (e) =>
              StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<List<StockTransactionModel>>
      search(
    String keyword,
  ) async {
    final db = await _db;

    final value = keyword.trim();

    if (value.isEmpty) {
      return getAll();
    }

    final rows = await db.query(
      'stock_transactions',
      where: '''
        product_code LIKE ?
        OR product_name LIKE ?
        OR reference_no LIKE ?
        OR transaction_type LIKE ?
        OR created_by LIKE ?
        OR remarks LIKE ?
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
          'transaction_date DESC, id DESC',
    );

    return rows
        .map(
          (e) =>
              StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // TOTAL STOCK IN QUANTITY
  // ============================================================

  Future<int> totalStockInQuantity() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(
        SUM(quantity), 0
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
        SUM(quantity), 0
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
        SUM(total_amount), 0
      ) AS total
      FROM stock_transactions
      WHERE transaction_type = 'IN'
      ''',
    );

    if (result.isEmpty) {
      return 0;
    }

    final value =
        result.first['total'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // TOTAL SALES AMOUNT
  // ============================================================

  Future<double> totalSalesAmount() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(
        SUM(total_amount), 0
      ) AS total
      FROM stock_transactions
      WHERE transaction_type = 'OUT'
      ''',
    );

    if (result.isEmpty) {
      return 0;
    }

    final value =
        result.first['total'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // PRODUCT STOCK UPDATE
  // ============================================================

  Future<void> _updateProductStock(
    DatabaseExecutor db,
    int? productId,
    int quantity,
    String transactionType,
  ) async {
    if (productId == null) {
      throw Exception(
        'Product ID is required.',
      );
    }

    if (quantity <= 0) {
      throw Exception(
        'Quantity must be greater than zero.',
      );
    }

    final rows = await db.query(
      'products',
      columns: ['id', 'stock'],
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw Exception(
        'Product not found.',
      );
    }

    final currentStock =
        _toInt(rows.first['stock']);

    final type =
        transactionType
            .trim()
            .toUpperCase();

    int newStock;

    if (type == 'IN') {
      newStock =
          currentStock + quantity;
    } else if (type == 'OUT') {
      newStock =
          currentStock - quantity;

      if (newStock < 0) {
        throw Exception(
          'Insufficient stock.',
        );
      }
    } else {
      throw Exception(
        'Invalid transaction type. '
        'Use IN or OUT.',
      );
    }

    await db.update(
      'products',
      {
        'stock': newStock,
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // ============================================================
  // REVERSE STOCK EFFECT
  // ============================================================

  Future<void> _reverseStockEffect(
    DatabaseExecutor db,
    StockTransactionModel transaction,
  ) async {
    if (transaction.productId == null) {
      throw Exception(
        'Product ID is missing.',
      );
    }

    final rows = await db.query(
      'products',
      columns: ['id', 'stock'],
      where: 'id = ?',
      whereArgs: [
        transaction.productId,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw Exception(
        'Product not found.',
      );
    }

    final currentStock =
        _toInt(rows.first['stock']);

    int newStock;

    if (transaction.isStockIn) {
      newStock =
          currentStock -
              transaction.quantity;

      if (newStock < 0) {
        throw Exception(
          'Cannot reverse stock IN. '
          'Current stock is insufficient.',
        );
      }
    } else if (transaction.isStockOut) {
      newStock =
          currentStock +
              transaction.quantity;
    } else {
      throw Exception(
        'Invalid transaction type.',
      );
    }

    await db.update(
      'products',
      {
        'stock': newStock,
      },
      where: 'id = ?',
      whereArgs: [
        transaction.productId,
      ],
    );
  }

  // ============================================================
  // COUNT TRANSACTIONS
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
  // COUNT STOCK IN
  // ============================================================

  Future<int> countStockIn() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
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
  // COUNT STOCK OUT
  // ============================================================

  Future<int> countStockOut() async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
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
  // DATE RANGE
  // ============================================================

  Future<List<StockTransactionModel>>
      getByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await _db;

    final rows = await db.query(
      'stock_transactions',
      where: '''
        transaction_date >= ?
        AND transaction_date <= ?
      ''',
      whereArgs: [
        startDate,
        endDate,
      ],
      orderBy:
          'transaction_date DESC, id DESC',
    );

    return rows
        .map(
          (e) =>
              StockTransactionModel.fromMap(e),
        )
        .toList();
  }

  // ============================================================
  // PRIVATE INT CONVERTER
  // ============================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }
}
```
