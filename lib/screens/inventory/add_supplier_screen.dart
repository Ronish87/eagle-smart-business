import 'package:flutter/material.dart';

import '../../models/supplier_model.dart';
import '../../repository/supplier_repository.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _panController = TextEditingController();
  final _remarksController = TextEditingController();

  final SupplierRepository _repository = SupplierRepository();

  bool _saving = false;

  Future<void> saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final supplier = SupplierModel(
      supplierCode: _codeController.text.trim(),
      supplierName: _nameController.text.trim(),
      contactPerson: _contactController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      panNumber: _panController.text.trim(),
      remarks: _remarksController.text.trim(),
    );

    await _repository.insert(supplier);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Supplier Saved Successfully")),
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
    _codeController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _panController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Supplier")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _codeController,
              decoration: decoration("Supplier Code"),
              validator: (v) => v == null || v.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameController,
              decoration: decoration("Supplier Name"),
              validator: (v) => v == null || v.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _contactController,
              decoration: decoration("Contact Person"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _phoneController,
              decoration: decoration("Phone"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _emailController,
              decoration: decoration("Email"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _addressController,
              decoration: decoration("Address"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _panController,
              decoration: decoration("PAN Number"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _remarksController,
              decoration: decoration("Remarks"),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : saveSupplier,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text("Save Supplier"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
