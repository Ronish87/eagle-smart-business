import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/brand_model.dart';
import '../../models/supplier_model.dart';

import '../../repository/product_repository.dart';
import '../../repository/category_repository.dart';
import '../../repository/brand_repository.dart';
import '../../repository/supplier_repository.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProductRepository _productRepository = ProductRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final BrandRepository _brandRepository = BrandRepository();
  final SupplierRepository _supplierRepository = SupplierRepository();

  final _codeController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();

  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  final _stockController = TextEditingController(text: "0");
  final _minimumStockController = TextEditingController(text: "0");

  String? selectedCategory;
  String? selectedBrand;
  String? selectedSupplier;
  String? selectedUnit;

  bool active = true;
  bool saving = false;

  List<CategoryModel> categories = [];
  List<BrandModel> brands = [];
  List<SupplierModel> suppliers = [];

  final units = [
    "PCS",
    "BOX",
    "PACK",
    "KG",
    "GRAM",
    "LITER",
    "METER",
    "SET",
    "DOZEN",
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    categories = await _categoryRepository.getAll();
    brands = await _brandRepository.getAll();
    suppliers = await _supplierRepository.getAll();

    setState(() {});
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null ||
        selectedBrand == null ||
        selectedSupplier == null ||
        selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all dropdown values.")),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    final product = ProductModel(
      code: _codeController.text.trim(),
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      category: selectedCategory!,
      brand: selectedBrand!,
      supplier: selectedSupplier!,
      unit: selectedUnit!,
      purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
      sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      minimumStock: int.tryParse(_minimumStockController.text) ?? 0,
      active: active,
      image: "",
    );

    await _productRepository.insert(product);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  InputDecoration decoration(String title) {
    return InputDecoration(
      labelText: title,
      border: const OutlineInputBorder(),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _barcodeController.dispose();
    _nameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _codeController,
              decoration: decoration("Product Code"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Required";
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _barcodeController,
              decoration: decoration("Barcode"),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _nameController,
              decoration: decoration("Product Name"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Required";
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: decoration("Category"),
              items: categories.map((e) {
                return DropdownMenuItem(value: e.name, child: Text(e.name));
              }).toList(),
              onChanged: (v) {
                setState(() {
                  selectedCategory = v;
                });
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedBrand,
              decoration: decoration("Brand"),
              items: brands.map((e) {
                return DropdownMenuItem(value: e.name, child: Text(e.name));
              }).toList(),
              onChanged: (v) {
                setState(() {
                  selectedBrand = v;
                });
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedSupplier,
              decoration: decoration("Supplier"),
              items: suppliers.map((e) {
                return DropdownMenuItem(
                  value: e.supplierName,
                  child: Text(e.supplierName),
                );
              }).toList(),
              onChanged: (v) {
                setState(() {
                  selectedSupplier = v;
                });
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedUnit,
              decoration: decoration("Unit"),
              items: units.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (v) {
                setState(() {
                  selectedUnit = v;
                });
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _purchasePriceController,
              keyboardType: TextInputType.number,
              decoration: decoration("Purchase Price"),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _sellingPriceController,
              keyboardType: TextInputType.number,
              decoration: decoration("Selling Price"),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: decoration("Opening Stock"),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _minimumStockController,
              keyboardType: TextInputType.number,
              decoration: decoration("Minimum Stock"),
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text("Active"),
              value: active,
              onChanged: (value) {
                setState(() {
                  active = value;
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: saving ? null : saveProduct,
                icon: const Icon(Icons.save),
                label: Text(saving ? "Saving..." : "Save Product"),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
