import 'package:flutter/material.dart';

import '../../models/brand_model.dart';
import '../../repository/brand_repository.dart';

class AddBrandScreen extends StatefulWidget {
  const AddBrandScreen({super.key});

  @override
  State<AddBrandScreen> createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final BrandRepository _repository = BrandRepository();

  bool _saving = false;

  Future<void> saveBrand() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final brand = BrandModel(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    await _repository.insert(brand);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Brand Saved Successfully")));

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
      appBar: AppBar(title: const Text("Add Brand")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: decoration("Brand Name"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Brand Name is required";
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
                onPressed: _saving ? null : saveBrand,
                icon: const Icon(Icons.save),
                label: Text(_saving ? "Saving..." : "Save Brand"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
