import 'package:flutter/material.dart';

import '../../models/brand_model.dart';
import '../../repository/brand_repository.dart';

class EditBrandScreen extends StatefulWidget {
  final BrandModel brand;

  const EditBrandScreen({super.key, required this.brand});

  @override
  State<EditBrandScreen> createState() => _EditBrandScreenState();
}

class _EditBrandScreenState extends State<EditBrandScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  final BrandRepository _repository = BrandRepository();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.brand.name);

    _descriptionController = TextEditingController(
      text: widget.brand.description,
    );
  }

  Future<void> updateBrand() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final updatedBrand = widget.brand.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    await _repository.update(updatedBrand);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Brand Updated Successfully")));

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
      appBar: AppBar(title: const Text("Edit Brand")),
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
                onPressed: _saving ? null : updateBrand,
                icon: const Icon(Icons.save),
                label: Text(_saving ? "Updating..." : "Update Brand"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
