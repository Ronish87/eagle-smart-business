```dart
import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../models/stock_transaction_model.dart';
import '../../repository/product_repository.dart';
import '../../repository/stock_transaction_repository.dart';

class StockOutScreen extends StatefulWidget {
  const StockOutScreen({super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final ProductRepository _productRepository =
      ProductRepository();

  final StockTransactionRepository _transactionRepository =
      StockTransactionRepository();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _quantityController =
      TextEditingController(text: '1');

  final TextEditingController _priceController =
      TextEditingController(text: '0');

  final TextEditingController _referenceController =
      TextEditingController();

  final TextEditingController _remarksController =
      TextEditingController();

  List<ProductModel> products = [];

  ProductModel? selectedProduct;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();

    _quantityController.addListener(_refreshTotal);
    _priceController.addListener(_refreshTotal);

    loadProducts();
  }

  // ============================================================
  // REFRESH TOTAL
  // ============================================================

  void _refreshTotal() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> loadProducts() async {
    setState(() {
      loading = true;
    });

    try {
      products = await _productRepository.getAll();

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load products: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SELECT PRODUCT
  // ============================================================

  void selectProduct(ProductModel? product) {
    setState(() {
      selectedProduct = product;

      if (product != null) {
        _priceController.text =
            product.sellingPrice.toStringAsFixed(2);
      }
    });
  }

  // ============================================================
  // GET QUANTITY
  // ============================================================

  int get quantity {
    return int.tryParse(
          _quantityController.text.trim(),
        ) ??
        0;
  }

  // ============================================================
  // GET UNIT PRICE
  // ============================================================

  double get unitPrice {
    return double.tryParse(
          _priceController.text.trim(),
        ) ??
        0;
  }

  // ============================================================
  // GET TOTAL
  // ============================================================

  double get totalAmount {
    return quantity * unitPrice;
  }

  // ============================================================
  // SAVE STOCK OUT
  // ============================================================

  Future<void> saveStockOut() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a product.',
          ),
        ),
      );

      return;
    }

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Quantity must be greater than 0.',
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // STOCK VALIDATION
    // ==========================================================

    if (quantity > selectedProduct!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient stock. '
            'Available stock: ${selectedProduct!.stock}',
          ),
        ),
      );

      return;
    }

    if (unitPrice < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Price cannot be negative.',
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final transaction = StockTransactionModel(
        productId: selectedProduct!.id!,
        productCode: selectedProduct!.code,
        productName: selectedProduct!.name,
        transactionType: 'OUT',
        quantity: quantity,
        unitPrice: unitPrice,
        totalAmount: totalAmount,
        referenceNo:
            _referenceController.text.trim(),
        remarks:
            _remarksController.text.trim(),
        createdBy: 'Admin',
        transactionDate:
            DateTime.now().toIso8601String(),
      );

      await _transactionRepository.insert(
        transaction,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Stock Out saved successfully.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save stock: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration inputDecoration(
    String label, {
    IconData? icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          icon != null ? Icon(icon) : null,
      border: const OutlineInputBorder(),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _quantityController.removeListener(_refreshTotal);
    _priceController.removeListener(_refreshTotal);

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Out'),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,

              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  // ==================================================
                  // TITLE
                  // ==================================================

                  const Text(
                    'Stock Out / Sales Entry',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // PRODUCT
                  // ==================================================

                  DropdownButtonFormField<ProductModel>(
                    value: selectedProduct,

                    isExpanded: true,

                    decoration: inputDecoration(
                      'Select Product',
                      icon: Icons.inventory_2,
                    ),

                    items: products.map(
                      (product) {
                        return DropdownMenuItem<ProductModel>(
                          value: product,

                          child: Text(
                            '${product.code} - ${product.name}',
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: selectProduct,

                    validator: (value) {
                      if (value == null) {
                        return 'Please select a product';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // SELECTED PRODUCT INFORMATION
                  // ==================================================

                  if (selectedProduct != null)
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(12),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              selectedProduct!.name,

                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Code: ${selectedProduct!.code}',
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Category: ${selectedProduct!.category}',
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Brand: ${selectedProduct!.brand}',
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Supplier: ${selectedProduct!.supplier}',
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Available Stock: '
                              '${selectedProduct!.stock} '
                              '${selectedProduct!.unit}',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Selling Price: '
                              'Rs ${selectedProduct!.sellingPrice.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // QUANTITY
                  // ==================================================

                  TextFormField(
                    controller:
                        _quantityController,

                    keyboardType:
                        TextInputType.number,

                    decoration: inputDecoration(
                      'Quantity',
                      icon: Icons.remove_circle,
                    ),

                    validator: (value) {
                      final valueNumber =
                          int.tryParse(
                        value?.trim() ?? '',
                      );

                      if (valueNumber == null) {
                        return 'Enter a valid quantity';
                      }

                      if (valueNumber <= 0) {
                        return 'Quantity must be greater than 0';
                      }

                      if (selectedProduct != null &&
                          valueNumber >
                              selectedProduct!.stock) {
                        return 'Only ${selectedProduct!.stock} '
                            'items available';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // SELLING PRICE
                  // ==================================================

                  TextFormField(
                    controller:
                        _priceController,

                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),

                    decoration: inputDecoration(
                      'Unit Selling Price',
                      icon:
                          Icons.currency_rupee,
                    ),

                    validator: (value) {
                      final price =
                          double.tryParse(
                        value?.trim() ?? '',
                      );

                      if (price == null) {
                        return 'Enter a valid price';
                      }

                      if (price < 0) {
                        return 'Price cannot be negative';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // REFERENCE NUMBER
                  // ==================================================

                  TextFormField(
                    controller:
                        _referenceController,

                    decoration:
                        inputDecoration(
                      'Reference / Invoice No.',
                      icon:
                          Icons.receipt_long,
                      hint:
                          'e.g. INV-1001',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // REMARKS
                  // ==================================================

                  TextFormField(
                    controller:
                        _remarksController,

                    maxLines: 3,

                    decoration:
                        inputDecoration(
                      'Remarks',
                      icon: Icons.notes,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // TOTAL
                  // ==================================================

                  Card(
                    elevation: 2,

                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),

                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),

                              Text(
                                '$quantity',
                                style:
                                    const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [
                              const Text(
                                'Unit Price',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),

                              Text(
                                'Rs ${unitPrice.toStringAsFixed(2)}',
                                style:
                                    const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const Divider(
                            height: 24,
                          ),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              Text(
                                'Rs ${totalAmount.toStringAsFixed(2)}',
                                style:
                                    const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // SAVE BUTTON
                  // ==================================================

                  SizedBox(
                    height: 52,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          saving
                              ? null
                              : saveStockOut,

                      icon: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.save,
                            ),

                      label: Text(
                        saving
                            ? 'Saving...'
                            : 'Save Stock Out',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
```
