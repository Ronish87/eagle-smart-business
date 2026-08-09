import 'package:flutter/material.dart';

import '../../models/brand_model.dart';
import '../../repository/brand_repository.dart';
import 'add_brand_screen.dart';
import 'edit_brand_screen.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  final BrandRepository _repository = BrandRepository();

  List<BrandModel> _brands = [];
  List<BrandModel> _filteredBrands = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadBrands();
  }

  Future<void> loadBrands() async {
    setState(() => _loading = true);

    final data = await _repository.getAll();

    setState(() {
      _brands = data;
      _filteredBrands = data;
      _loading = false;
    });
  }

  void search(String keyword) {
    if (keyword.trim().isEmpty) {
      setState(() {
        _filteredBrands = _brands;
      });
      return;
    }

    setState(() {
      _filteredBrands = _brands.where((brand) {
        return brand.name.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    });
  }

  Future<void> deleteBrand(int id) async {
    await _repository.delete(id);
    await loadBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Brands")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBrandScreen()),
          );

          if (result == true) {
            loadBrands();
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search Brand",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: search,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBrands.isEmpty
                ? const Center(child: Text("No Brand Found"))
                : ListView.builder(
                    itemCount: _filteredBrands.length,
                    itemBuilder: (context, index) {
                      final brand = _filteredBrands[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              brand.name.isEmpty ? "B" : brand.name[0],
                            ),
                          ),
                          title: Text(brand.name),
                          subtitle: Text(brand.description),
                          trailing: PopupMenuButton<int>(
                            onSelected: (value) async {
                              if (value == 1) {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditBrandScreen(brand: brand),
                                  ),
                                );

                                if (updated == true) {
                                  loadBrands();
                                }
                              }

                              if (value == 2) {
                                await deleteBrand(brand.id!);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 1, child: Text("Edit")),
                              PopupMenuItem(value: 2, child: Text("Delete")),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
