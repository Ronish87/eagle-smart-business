import 'package:flutter/material.dart';

import '../../models/stock_transaction_model.dart';
import '../../repository/stock_transaction_repository.dart';

class StockTransactionScreen extends StatefulWidget {
  const StockTransactionScreen({super.key});

  @override
  State<StockTransactionScreen> createState() =>
      _StockTransactionScreenState();
}

class _StockTransactionScreenState
    extends State<StockTransactionScreen> {
  final StockTransactionRepository _repository =
      StockTransactionRepository();

  final TextEditingController _searchController =
      TextEditingController();

  List<StockTransactionModel> transactions = [];

  bool loading = true;

  String selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_search);

    loadTransactions();
  }

  // ============================================================
  // LOAD TRANSACTIONS
  // ============================================================

  Future<void> loadTransactions() async {
    setState(() {
      loading = true;
    });

    try {
      List<StockTransactionModel> result;

      if (selectedFilter == 'IN') {
        result = await _repository.getStockIn();
      } else if (selectedFilter == 'OUT') {
        result = await _repository.getStockOut();
      } else {
        result = await _repository.getAll();
      }

      if (!mounted) return;

      setState(() {
        transactions = result;
        loading = false;
      });

      _search();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load transactions: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _search() async {
    final keyword =
        _searchController.text.trim();

    if (keyword.isEmpty) {
      if (!mounted) return;

      setState(() {});
      return;
    }

    try {
      final result =
          await _repository.search(keyword);

      if (!mounted) return;

      List<StockTransactionModel> filtered =
          result;

      if (selectedFilter == 'IN') {
        filtered = result
            .where(
              (e) =>
                  e.transactionType == 'IN',
            )
            .toList();
      } else if (selectedFilter == 'OUT') {
        filtered = result
            .where(
              (e) =>
                  e.transactionType == 'OUT',
            )
            .toList();
      }

      setState(() {
        transactions = filtered;
      });
    } catch (e) {
      // Ignore search errors.
    }
  }

  // ============================================================
  // CHANGE FILTER
  // ============================================================

  Future<void> changeFilter(
    String filter,
  ) async {
    setState(() {
      selectedFilter = filter;
    });

    await loadTransactions();
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteTransaction(
    StockTransactionModel transaction,
  ) async {
    if (transaction.id == null) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Transaction?',
          ),

          content: Text(
            'This will delete the transaction '
            'and reverse its stock effect.\n\n'
            '${transaction.productName}\n'
            'Quantity: ${transaction.quantity}',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _repository.delete(
        transaction.id!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaction deleted successfully.',
          ),
        ),
      );

      await loadTransactions();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete transaction: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // TOTAL QUANTITY
  // ============================================================

  int get totalQuantity {
    return transactions.fold(
      0,
      (sum, item) =>
          sum + item.quantity,
    );
  }

  // ============================================================
  // TOTAL AMOUNT
  // ============================================================

  double get totalAmount {
    return transactions.fold(
      0,
      (sum, item) =>
          sum + item.totalAmount,
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(String date) {
    try {
      final parsed =
          DateTime.parse(date);

      return '${parsed.year}-'
          '${parsed.month.toString().padLeft(2, '0')}-'
          '${parsed.day.toString().padLeft(2, '0')} '
          '${parsed.hour.toString().padLeft(2, '0')}:'
          '${parsed.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return date;
    }
  }

  // ============================================================
  // TRANSACTION COLOR
  // ============================================================

  Color transactionColor(
    String type,
  ) {
    if (type == 'IN') {
      return Colors.green;
    }

    return Colors.red;
  }

  // ============================================================
  // TRANSACTION ICON
  // ============================================================

  IconData transactionIcon(
    String type,
  ) {
    if (type == 'IN') {
      return Icons.arrow_downward;
    }

    return Icons.arrow_upward;
  }

  // ============================================================
  // SHOW DETAILS
  // ============================================================

  void showTransactionDetails(
    StockTransactionModel transaction,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                transactionIcon(
                  transaction.transactionType,
                ),
                color: transactionColor(
                  transaction.transactionType,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  transaction.transactionType ==
                          'IN'
                      ? 'Stock In Details'
                      : 'Stock Out Details',
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                _detailRow(
                  'Product',
                  transaction.productName,
                ),

                _detailRow(
                  'Product Code',
                  transaction.productCode,
                ),

                _detailRow(
                  'Transaction Type',
                  transaction.transactionType,
                ),

                _detailRow(
                  'Quantity',
                  transaction.quantity.toString(),
                ),

                _detailRow(
                  'Unit Price',
                  'Rs ${transaction.unitPrice.toStringAsFixed(2)}',
                ),

                _detailRow(
                  'Total Amount',
                  'Rs ${transaction.totalAmount.toStringAsFixed(2)}',
                ),

                _detailRow(
                  'Reference No.',
                  transaction.referenceNo.isEmpty
                      ? '-'
                      : transaction.referenceNo,
                ),

                _detailRow(
                  'Created By',
                  transaction.createdBy.isEmpty
                      ? '-'
                      : transaction.createdBy,
                ),

                _detailRow(
                  'Date',
                  formatDate(
                    transaction.transactionDate,
                  ),
                ),

                _detailRow(
                  'Remarks',
                  transaction.remarks.isEmpty
                      ? '-'
                      : transaction.remarks,
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 120,

            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER BUTTON
  // ============================================================

  Widget filterButton(
    String label,
    String value,
  ) {
    final selected =
        selectedFilter == value;

    return ChoiceChip(
      label: Text(label),

      selected: selected,

      onSelected: (_) {
        changeFilter(value);
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.removeListener(_search);
    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock Transactions',
        ),

        actions: [
          IconButton(
            onPressed: loadTransactions,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ======================================================
          // SEARCH
          // ======================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),

            child: TextField(
              controller:
                  _searchController,

              decoration:
                  InputDecoration(
                hintText:
                    'Search product, code, invoice...',

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                suffixIcon:
                    _searchController
                            .text
                            .isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController
                                  .clear();

                              loadTransactions();
                            },
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,

                border:
                    const OutlineInputBorder(),
              ),
            ),
          ),

          // ======================================================
          // FILTERS
          // ======================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            child: SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,

              child: Row(
                children: [
                  filterButton(
                    'All',
                    'ALL',
                  ),

                  const SizedBox(width: 8),

                  filterButton(
                    'Stock In',
                    'IN',
                  ),

                  const SizedBox(width: 8),

                  filterButton(
                    'Stock Out',
                    'OUT',
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // SUMMARY
          // ======================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'Transactions',
                    transactions.length
                        .toString(),
                    Icons.receipt_long,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _summaryCard(
                    'Quantity',
                    totalQuantity
                        .toString(),
                    Icons.inventory_2,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _summaryCard(
                    'Amount',
                    'Rs ${totalAmount.toStringAsFixed(0)}',
                    Icons.currency_rupee,
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // LIST
          // ======================================================

          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : transactions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color:
                                  Colors.grey,
                            ),

                            SizedBox(height: 12),

                            Text(
                              'No transactions found.',
                              style:
                                  TextStyle(
                                fontSize: 16,
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh:
                            loadTransactions,

                        child: ListView.builder(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            16,
                            8,
                            16,
                            20,
                          ),

                          itemCount:
                              transactions
                                  .length,

                          itemBuilder:
                              (context, index) {
                            final transaction =
                                transactions[
                                    index];

                            return _transactionCard(
                              transaction,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(10),

        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              value,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TRANSACTION CARD
  // ============================================================

  Widget _transactionCard(
    StockTransactionModel transaction,
  ) {
    final isStockIn =
        transaction.transactionType ==
            'IN';

    final color =
        transactionColor(
      transaction.transactionType,
    );

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: InkWell(
        onTap: () {
          showTransactionDetails(
            transaction,
          );
        },

        borderRadius:
            BorderRadius.circular(12),

        child: Padding(
          padding:
              const EdgeInsets.all(12),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color:
                      color.withOpacity(
                    0.12,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),

                child: Icon(
                  transactionIcon(
                    transaction
                        .transactionType,
                  ),

                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // DETAILS
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      transaction.productName,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      transaction.productCode,

                      style:
                          const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                color.withOpacity(
                              0.12,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),

                          child: Text(
                            isStockIn
                                ? 'STOCK IN'
                                : 'STOCK OUT',

                            style:
                                TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          'Qty: ${transaction.quantity}',

                          style:
                              const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      formatDate(
                        transaction
                            .transactionDate,
                      ),

                      style:
                          const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ==================================================
              // AMOUNT + DELETE
              // ==================================================

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,

                children: [
                  Text(
                    'Rs ${transaction.totalAmount.toStringAsFixed(2)}',

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Rs ${transaction.unitPrice.toStringAsFixed(2)} / unit',

                    style:
                        const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 4),

                  IconButton(
                    visualDensity:
                        VisualDensity.compact,

                    tooltip: 'Delete',

                    onPressed: () {
                      deleteTransaction(
                        transaction,
                      );
                    },

                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
