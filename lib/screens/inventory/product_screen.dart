import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../repository/product_repository.dart';

import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductRepository _repository = ProductRepository();

  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];

  bool loading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() {
      loading = true;
    });

    products = await _repository.getAll();
    filteredProducts = List.from(products);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  void search(String keyword) {
    if (keyword.trim().isEmpty) {
      setState(() {
        filteredProducts = List.from(products);
      });
      return;
    }

    final lower = keyword.toLowerCase();

    setState(() {
      filteredProducts = products.where((product) {
        return product.code.toLowerCase().contains(lower) ||
            product.barcode.toLowerCase().contains(lower) ||
            product.name.toLowerCase().contains(lower) ||
            product.category.toLowerCase().contains(lower) ||
            product.brand.toLowerCase().contains(lower) ||
            product.supplier.toLowerCase().contains(lower);
      }).toList();
    });
  }

  Future<void> deleteProduct(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: Text("Are you sure you want to delete '${product.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _repository.delete(product.id!);

    await loadProducts();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Product Deleted")));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add"),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );

          if (result == true) {
            loadProducts();
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search Product...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: search,
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      "No Products Found",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadProducts,
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                product.name.isNotEmpty
                                    ? product.name[0].toUpperCase()
                                    : "?",
                              ),
                            ),

                            title: Text(product.name),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Code : ${product.code}"),
                                Text("Category : ${product.category}"),
                                Text("Brand : ${product.brand}"),
                                Text("Supplier : ${product.supplier}"),
                                Text(
                                  "Stock : ${product.stock} ${product.unit}",
                                ),
                                Text(
                                  "Purchase : Rs ${product.purchasePrice.toStringAsFixed(2)}",
                                ),
                                Text(
                                  "Selling : Rs ${product.sellingPrice.toStringAsFixed(2)}",
                                ),
                              ],
                            ),

                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == "edit") {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditProductScreen(product: product),
                                    ),
                                  );

                                  if (updated == true) {
                                    loadProducts();
                                  }
                                }

                                if (value == "delete") {
                                  deleteProduct(product);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: "edit",
                                  child: Text("Edit"),
                                ),
                                PopupMenuItem(
                                  value: "delete",
                                  child: Text("Delete"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
