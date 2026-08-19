import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../repository/product_repository.dart';
import '../../repository/stock_transaction_repository.dart';

import 'product_screen.dart';
import 'stock_in_screen.dart';
import 'stock_out_screen.dart';
import 'stock_transaction_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() =>
      _InventoryScreenState();
}

class _InventoryScreenState
    extends State<InventoryScreen> {
  final ProductRepository _productRepository =
      ProductRepository();

  final StockTransactionRepository
      _transactionRepository =
      StockTransactionRepository();

  bool loading = true;

  int totalProducts = 0;
  int totalStock = 0;
  int lowStockCount = 0;

  int stockInQuantity = 0;
  int stockOutQuantity = 0;

  double purchaseAmount = 0;
  double salesAmount = 0;

  List<ProductModel> lowStockProducts = [];

  @override
  void initState() {
    super.initState();

    loadDashboard();
  }

  // ============================================================
  // LOAD INVENTORY DASHBOARD
  // ============================================================

  Future<void> loadDashboard() async {
    setState(() {
      loading = true;
    });

    try {
      final products =
          await _productRepository.getAll();

      final lowStock =
          await _productRepository
              .getLowStockProducts();

      final totalStockValue =
          await _calculateStockValue(
        products,
      );

      final inQuantity =
          await _transactionRepository
              .totalStockInQuantity();

      final outQuantity =
          await _transactionRepository
              .totalStockOutQuantity();

      final purchase =
          await _transactionRepository
              .totalPurchaseAmount();

      final sales =
          await _transactionRepository
              .totalSalesAmount();

      if (!mounted) return;

      setState(() {
        totalProducts = products.length;

        totalStock = products.fold(
          0,
          (sum, product) =>
              sum + product.stock,
        );

        lowStockCount = lowStock.length;

        lowStockProducts = lowStock;

        stockInQuantity = inQuantity;

        stockOutQuantity = outQuantity;

        purchaseAmount = purchase;

        salesAmount = sales;

        loading = false;
      });

      // Prevent unused calculation warning
      // and keep this value available for
      // future dashboard expansion.
      totalStockValue;
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load inventory: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CALCULATE STOCK VALUE
  // ============================================================

  Future<double> _calculateStockValue(
    List<ProductModel> products,
  ) async {
    double value = 0;

    for (final product in products) {
      value +=
          product.stock *
          product.purchasePrice;
    }

    return value;
  }

  // ============================================================
  // OPEN SCREEN
  // ============================================================

  Future<void> openScreen(
    Widget screen,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );

    await loadDashboard();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory',
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loadDashboard,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadDashboard,

              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(16),

                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  const Text(
                    'Inventory Overview',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Manage products, stock and inventory transactions.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // SUMMARY CARDS
                  // ==================================================

                  GridView.count(
                    crossAxisCount: 2,

                    crossAxisSpacing: 12,

                    mainAxisSpacing: 12,

                    childAspectRatio: 1.55,

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    children: [
                      _summaryCard(
                        title: 'Products',
                        value:
                            totalProducts.toString(),
                        icon:
                            Icons.inventory_2,
                      ),

                      _summaryCard(
                        title: 'Total Stock',
                        value:
                            totalStock.toString(),
                        icon:
                            Icons.warehouse,
                      ),

                      _summaryCard(
                        title: 'Low Stock',
                        value:
                            lowStockCount.toString(),
                        icon:
                            Icons.warning_amber,
                      ),

                      _summaryCard(
                        title: 'Stock In',
                        value:
                            stockInQuantity.toString(),
                        icon:
                            Icons.arrow_downward,
                      ),

                      _summaryCard(
                        title: 'Stock Out',
                        value:
                            stockOutQuantity.toString(),
                        icon:
                            Icons.arrow_upward,
                      ),

                      _summaryCard(
                        title: 'Sales',
                        value:
                            'Rs ${salesAmount.toStringAsFixed(0)}',
                        icon:
                            Icons.point_of_sale,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // QUICK ACTIONS
                  // ==================================================

                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _actionTile(
                    title:
                        'Products',
                    subtitle:
                        'Add, edit and manage products',
                    icon:
                        Icons.inventory_2,
                    onTap: () {
                      openScreen(
                        const ProductScreen(),
                      );
                    },
                  ),

                  _actionTile(
                    title:
                        'Stock In',
                    subtitle:
                        'Add purchased stock',
                    icon:
                        Icons.add_box,
                    onTap: () {
                      openScreen(
                        const StockInScreen(),
                      );
                    },
                  ),

                  _actionTile(
                    title:
                        'Stock Out',
                    subtitle:
                        'Record sales / stock issue',
                    icon:
                        Icons.remove_circle,
                    onTap: () {
                      openScreen(
                        const StockOutScreen(),
                      );
                    },
                  ),

                  _actionTile(
                    title:
                        'Stock Transactions',
                    subtitle:
                        'View complete stock history',
                    icon:
                        Icons.receipt_long,
                    onTap: () {
                      openScreen(
                        const StockTransactionScreen(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // LOW STOCK
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [
                      const Text(
                        'Low Stock Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      if (lowStockProducts
                          .isNotEmpty)
                        TextButton(
                          onPressed: () {
                            openScreen(
                              const ProductScreen(),
                            );
                          },
                          child:
                              const Text(
                            'View Products',
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  lowStockProducts.isEmpty
                      ? Card(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              20,
                            ),

                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 30,
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: const [
                                      Text(
                                        'Stock level is good',
                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        'No products are currently below minimum stock.',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children:
                              lowStockProducts
                                  .take(10)
                                  .map(
                                    (
                                      product,
                                    ) =>
                                        _lowStockTile(
                                      product,
                                    ),
                                  )
                                  .toList(),
                        ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // STOCK SUMMARY
                  // ==================================================

                  const Text(
                    'Stock Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),

                      child: Column(
                        children: [
                          _summaryRow(
                            'Total Products',
                            totalProducts
                                .toString(),
                          ),

                          const Divider(),

                          _summaryRow(
                            'Total Stock Quantity',
                            totalStock
                                .toString(),
                          ),

                          const Divider(),

                          _summaryRow(
                            'Stock In Quantity',
                            stockInQuantity
                                .toString(),
                          ),

                          const Divider(),

                          _summaryRow(
                            'Stock Out Quantity',
                            stockOutQuantity
                                .toString(),
                          ),

                          const Divider(),

                          _summaryRow(
                            'Purchase Amount',
                            'Rs ${purchaseAmount.toStringAsFixed(2)}',
                          ),

                          const Divider(),

                          _summaryRow(
                            'Sales Amount',
                            'Rs ${salesAmount.toStringAsFixed(2)}',
                          ),

                          const Divider(),

                          _summaryRow(
                            'Gross Difference',
                            'Rs ${(salesAmount - purchaseAmount).toStringAsFixed(2)}',
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(14),

        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,

              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),

                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .primaryContainer,
              ),

              child: Icon(
                icon,
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .onPrimaryContainer,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    value,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACTION TILE
  // ============================================================

  Widget _actionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              10,
            ),

            color: Theme.of(
              context,
            )
                .colorScheme
                .primaryContainer,
          ),

          child: Icon(
            icon,
            color: Theme.of(
              context,
            )
                .colorScheme
                .onPrimaryContainer,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Text(
          subtitle,
        ),

        trailing:
            const Icon(
          Icons.chevron_right,
        ),

        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // LOW STOCK TILE
  // ============================================================

  Widget _lowStockTile(
    ProductModel product,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),

      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(
            Icons.warning_amber,
          ),
        ),

        title: Text(
          product.name,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,

          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Text(
          '${product.code} • '
          'Minimum: ${product.minimumStock}',
        ),

        trailing: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          crossAxisAlignment:
              CrossAxisAlignment.end,

          children: [
            Text(
              '${product.stock}',
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              product.unit,
              style:
                  const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,

      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
