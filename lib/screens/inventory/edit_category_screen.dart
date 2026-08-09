import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../repository/category_repository.dart';

class EditCategoryScreen extends StatefulWidget {
  final CategoryModel category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  final CategoryRepository _repository = CategoryRepository();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.category.name);

    _descriptionController = TextEditingController(
      text: widget.category.description,
    );
  }

  Future<void> updateCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final updatedCategory = widget.category.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    await _repository.update(updatedCategory);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Category Updated Successfully")),
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
      appBar: AppBar(title: const Text("Edit Category")),
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
                onPressed: _saving ? null : updateCategory,
                icon: const Icon(Icons.save),
                label: Text(_saving ? "Updating..." : "Update Category"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
