```dart
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/stock_transaction_model.dart';
import '../repository/product_repository.dart';
import '../repository/stock_transaction_repository.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  State<StockInScreen> createState() =>
      _StockInScreenState();
}

class _StockInScreenState
    extends State<StockInScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final ProductRepository
      _productRepository =
      ProductRepository();

  final StockTransactionRepository
      _transactionRepository =
      StockTransactionRepository();

  final TextEditingController
      _quantityController =
      TextEditingController(text: '1');

  final TextEditingController
      _priceController =
      TextEditingController(text: '0');

  final TextEditingController
      _referenceController =
      TextEditingController();

  final TextEditingController
      _remarksController =
      TextEditingController();

  List<ProductModel> _products = [];

  ProductModel? _selectedProduct;

  double _totalAmount = 0;

  bool _loadingProducts = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _quantityController
        .addListener(_calculateTotal);

    _priceController
        .addListener(_calculateTotal);

    _loadProducts();
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> _loadProducts() async {
    try {
      final products =
          await _productRepository
              .getAll();

      if (!mounted) return;

      setState(() {
        _products = products;
        _loadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingProducts = false;
      });

      _showMessage(
        'Failed to load products: $e',
        isError: true,
      );
    }
  }

  // ============================================================
  // CALCULATE TOTAL
  // ============================================================

  void _calculateTotal() {
    final quantity =
        int.tryParse(
              _quantityController.text
                  .trim(),
            ) ??
            0;

    final price =
        double.tryParse(
              _priceController.text
                  .trim(),
            ) ??
            0;

    final total =
        quantity * price;

    if (!mounted) {
      _totalAmount = total;
      return;
    }

    setState(() {
      _totalAmount = total;
    });
  }

  // ============================================================
  // PRODUCT SELECT
  // ============================================================

  void _onProductSelected(
    ProductModel? product,
  ) {
    if (product == null) return;

    setState(() {
      _selectedProduct = product;

      if (_priceController.text
          .trim()
          .isEmpty ||
          _priceController.text
                  .trim() ==
              '0') {
        _priceController.text =
            product.purchasePrice
                .toStringAsFixed(2);
      }
    });

    _calculateTotal();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveStockIn() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_selectedProduct == null) {
      _showMessage(
        'Please select a product.',
        isError: true,
      );
      return;
    }

    final quantity =
        int.tryParse(
      _quantityController.text
          .trim(),
    );

    final price =
        double.tryParse(
      _priceController.text
          .trim(),
    );

    if (quantity == null ||
        quantity <= 0) {
      _showMessage(
        'Quantity must be greater than 0.',
        isError: true,
      );
      return;
    }

    if (price == null ||
        price < 0) {
      _showMessage(
        'Please enter a valid price.',
        isError: true,
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final transaction =
          StockTransactionModel(
        productId:
            _selectedProduct!.id,

        productCode:
            _selectedProduct!.code,

        productName:
            _selectedProduct!.name,

        transactionType:
            'IN',

        quantity:
            quantity,

        unitPrice:
            price,

        totalAmount:
            quantity * price,

        referenceNo:
            _referenceController
                .text
                .trim(),

        createdBy:
            'Admin',

        transactionDate:
            DateTime.now()
                .toIso8601String(),

        remarks:
            _remarksController
                .text
                .trim(),
      );

      await _transactionRepository
          .insert(transaction);

      if (!mounted) return;

      _showMessage(
        'Stock IN saved successfully.',
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to save Stock IN: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            isError
                ? Colors.red
                : Colors.green,
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _quantityController
        .removeListener(
      _calculateTotal,
    );

    _priceController
        .removeListener(
      _calculateTotal,
    );

    _quantityController.dispose();
    _priceController.dispose();
    _referenceController.dispose();
    _remarksController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Stock In'),
      ),

      body: _loadingProducts
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,

              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,

                  children: [
                    // ==================================================
                    // PRODUCT
                    // ==================================================

                    DropdownButtonFormField<
                        ProductModel>(
                      value:
                          _selectedProduct,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Product',
                        border:
                            OutlineInputBorder(),
                      ),

                      items: _products
                          .map(
                            (
                              product,
                            ) =>
                                DropdownMenuItem<
                                    ProductModel>(
                              value:
                                  product,

                              child: Text(
                                '${product.code} - ${product.name}',
                              ),
                            ),
                          )
                          .toList(),

                      onChanged:
                          _onProductSelected,

                      validator:
                          (value) {
                        if (value ==
                            null) {
                          return 'Please select a product';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ==================================================
                    // QUANTITY
                    // ==================================================

                    TextFormField(
                      controller:
                          _quantityController,

                      keyboardType:
                          TextInputType
                              .number,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Quantity',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .inventory_2_outlined,
                        ),
                      ),

                      validator:
                          (value) {
                        final quantity =
                            int.tryParse(
                          value
                                  ?.trim() ??
                              '',
                        );

                        if (quantity ==
                                null ||
                            quantity <=
                                0) {
                          return 'Enter valid quantity';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ==================================================
                    // PRICE
                    // ==================================================

                    TextFormField(
                      controller:
                          _priceController,

                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Purchase Price',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .payments_outlined,
                        ),
                      ),

                      validator:
                          (value) {
                        final price =
                            double.tryParse(
                          value
                                  ?.trim() ??
                              '',
                        );

                        if (price ==
                                null ||
                            price < 0) {
                          return 'Enter valid price';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // TOTAL
                    // ==================================================

                    Container(
                      padding:
                          const EdgeInsets
                              .all(18),

                      decoration:
                          BoxDecoration(
                        border:
                            Border.all(
                          color:
                              Colors.grey,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [
                          const Text(
                            'Total Amount',
                            style:
                                TextStyle(
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          Text(
                            'Rs. ${_totalAmount.toStringAsFixed(2)}',

                            style:
                                const TextStyle(
                              fontSize:
                                  20,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ==================================================
                    // REFERENCE
                    // ==================================================

                    TextFormField(
                      controller:
                          _referenceController,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Reference No. / Invoice No.',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(
                          Icons
                              .receipt_long_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ==================================================
                    // REMARKS
                    // ==================================================

                    TextFormField(
                      controller:
                          _remarksController,

                      maxLines: 3,

                      decoration:
                          const InputDecoration(
                        labelText:
                            'Remarks',
                        border:
                            OutlineInputBorder(),
                        alignLabelWithHint:
                            true,
                        prefixIcon:
                            Icon(
                          Icons
                              .notes_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // SAVE BUTTON
                    // ==================================================

                    SizedBox(
                      height: 52,

                      child:
                          ElevatedButton.icon(
                        onPressed:
                            _saving
                                ? null
                                : _saveStockIn,

                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .save_outlined,
                              ),

                        label: Text(
                          _saving
                              ? 'Saving...'
                              : 'Save Stock In',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
```
