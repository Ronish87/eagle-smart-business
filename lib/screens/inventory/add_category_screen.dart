import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../repository/category_repository.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final CategoryRepository _repository = CategoryRepository();

  bool _saving = false;

  Future<void> saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final category = CategoryModel(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    await _repository.insert(category);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Category Saved Successfully")),
    );

    Navigator.pop(context, true);
  }

  InputDecoration decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Category")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: decoration("Category Name"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Category Name is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _descriptionController,
              decoration: decoration("Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 25),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : saveCategory,
                icon: const Icon(Icons.save),
                label: Text(_saving ? "Saving..." : "Save Category"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
