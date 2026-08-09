import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../repository/category_repository.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryRepository _repository = CategoryRepository();

  List<CategoryModel> _categories = [];
  List<CategoryModel> _filtered = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    setState(() => _loading = true);

    final data = await _repository.getAll();

    setState(() {
      _categories = data;
      _filtered = data;
      _loading = false;
    });
  }

  void search(String value) {
    if (value.trim().isEmpty) {
      setState(() => _filtered = _categories);
      return;
    }

    setState(() {
      _filtered = _categories
          .where((e) => e.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteCategory(int id) async {
    await _repository.delete(id);
    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open Add Category Screen
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search Category",
                border: OutlineInputBorder(),
              ),
              onChanged: search,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? const Center(child: Text("No Category Found"))
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final category = _filtered[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              category.name.isEmpty ? "C" : category.name[0],
                            ),
                          ),
                          title: Text(category.name),
                          subtitle: Text(category.description),
                          trailing: PopupMenuButton<int>(
                            onSelected: (value) async {
                              if (value == 2) {
                                await deleteCategory(category.id!);
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
