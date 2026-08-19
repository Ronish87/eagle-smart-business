import 'package:flutter/material.dart';

import '../../models/supplier_model.dart';
import '../../repository/supplier_repository.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() =>
      _SupplierScreenState();
}

class _SupplierScreenState
    extends State<SupplierScreen> {
  final SupplierRepository _repository =
      SupplierRepository();

  final TextEditingController _searchController =
      TextEditingController();

  List<SupplierModel> suppliers = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      loadSuppliers,
    );

    loadSuppliers();
  }

  // ============================================================
  // LOAD SUPPLIERS
  // ============================================================

  Future<void> loadSuppliers() async {
    try {
      final keyword =
          _searchController.text.trim();

      final result = keyword.isEmpty
          ? await _repository.getAll()
          : await _repository.search(
              keyword,
            );

      if (!mounted) return;

      setState(() {
        suppliers = result;
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
            'Failed to load suppliers: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ADD / EDIT SUPPLIER
  // ============================================================

  Future<void> openSupplierForm({
    SupplierModel? supplier,
  }) async {
    final result =
        await showDialog<SupplierModel>(
      context: context,
      builder: (_) => SupplierFormDialog(
        supplier: supplier,
      ),
    );

    if (result == null) {
      return;
    }

    try {
      if (supplier == null) {
        await _repository.insert(
          result,
        );
      } else {
        await _repository.update(
          result,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            supplier == null
                ? 'Supplier added successfully.'
                : 'Supplier updated successfully.',
          ),
        ),
      );

      await loadSuppliers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save supplier: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE SUPPLIER
  // ============================================================

  Future<void> deleteSupplier(
    SupplierModel supplier,
  ) async {
    if (supplier.id == null) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Supplier?',
          ),

          content: Text(
            'Are you sure you want to delete '
            '${supplier.supplierName}?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _repository.delete(
        supplier.id!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Supplier deleted successfully.',
          ),
        ),
      );

      await loadSuppliers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete supplier: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // TOGGLE ACTIVE STATUS
  // ============================================================

  Future<void> toggleStatus(
    SupplierModel supplier,
  ) async {
    if (supplier.id == null) {
      return;
    }

    try {
      final updated =
          supplier.copyWith(
        isActive: !supplier.isActive,
      );

      await _repository.update(
        updated,
      );

      await loadSuppliers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update status: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.removeListener(
      loadSuppliers,
    );

    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suppliers',
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loadSuppliers,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          openSupplierForm();
        },

        icon: const Icon(
          Icons.add,
        ),

        label: const Text(
          'Add Supplier',
        ),
      ),

      body: Column(
        children: [
          // ======================================================
          // SEARCH
          // ======================================================

          Padding(
            padding:
                const EdgeInsets.all(16),

            child: TextField(
              controller:
                  _searchController,

              decoration:
                  InputDecoration(
                hintText:
                    'Search supplier...',

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                suffixIcon:
                    _searchController
                            .text
                            .isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController
                                  .clear();

                              loadSuppliers();
                            },
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,

                border:
                    const OutlineInputBorder(),
              ),
            ),
          ),

          // ======================================================
          // SUPPLIER COUNT
          // ======================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Align(
              alignment:
                  Alignment.centerLeft,

              child: Text(
                '${suppliers.length} supplier(s)',
                style:
                    const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ======================================================
          // LIST
          // ======================================================

          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : suppliers.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [
                            Icon(
                              Icons.business,
                              size: 64,
                              color:
                                  Colors.grey,
                            ),

                            SizedBox(
                              height: 12,
                            ),

                            Text(
                              'No suppliers found.',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                                fontSize:
                                    16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh:
                            loadSuppliers,

                        child:
                            ListView.builder(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            16,
                            8,
                            16,
                            90,
                          ),

                          itemCount:
                              suppliers.length,

                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            return _supplierCard(
                              suppliers[index],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUPPLIER CARD
  // ============================================================

  Widget _supplierCard(
    SupplierModel supplier,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: ListTile(
        contentPadding:
            const EdgeInsets.all(12),

        leading: CircleAvatar(
          child: Text(
            supplier.supplierName
                    .isNotEmpty
                ? supplier
                    .supplierName[0]
                    .toUpperCase()
                : 'S',
          ),
        ),

        title: Text(
          supplier.supplierName,

          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 6,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'Code: ${supplier.supplierCode}',
              ),

              if (supplier
                  .contactPerson
                  .isNotEmpty)
                Text(
                  'Contact: ${supplier.contactPerson}',
                ),

              if (supplier.phone.isNotEmpty)
                Text(
                  'Phone: ${supplier.phone}',
                ),

              const SizedBox(
                height: 4,
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),

                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),

                  color:
                      supplier.isActive
                          ? Colors.green
                              .withOpacity(
                              0.12,
                            )
                          : Colors.red
                              .withOpacity(
                              0.12,
                            ),
                ),

                child: Text(
                  supplier.isActive
                      ? 'ACTIVE'
                      : 'INACTIVE',

                  style: TextStyle(
                    fontSize: 10,

                    fontWeight:
                        FontWeight.bold,

                    color:
                        supplier.isActive
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              openSupplierForm(
                supplier: supplier,
              );
            }

            if (value == 'status') {
              toggleStatus(
                supplier,
              );
            }

            if (value == 'delete') {
              deleteSupplier(
                supplier,
              );
            }
          },

          itemBuilder:
              (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading:
                    Icon(Icons.edit),
                title: Text(
                  'Edit',
                ),
              ),
            ),

            PopupMenuItem(
              value: 'status',

              child: ListTile(
                leading: Icon(
                  supplier.isActive
                      ? Icons.block
                      : Icons.check_circle,
                ),

                title: Text(
                  supplier.isActive
                      ? 'Deactivate'
                      : 'Activate',
                ),
              ),
            ),

            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading:
                    Icon(Icons.delete),
                title: Text(
                  'Delete',
                ),
              ),
            ),
          ],
        ),

        onTap: () {
          openSupplierForm(
            supplier: supplier,
          );
        },
      ),
    );
  }
}

// ==================================================================
// SUPPLIER FORM DIALOG
// ==================================================================

class SupplierFormDialog extends StatefulWidget {
  final SupplierModel? supplier;

  const SupplierFormDialog({
    super.key,
    this.supplier,
  });

  @override
  State<SupplierFormDialog> createState() =>
      _SupplierFormDialogState();
}

class _SupplierFormDialogState
    extends State<SupplierFormDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _codeController;

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _contactController;

  late final TextEditingController
      _phoneController;

  late final TextEditingController
      _emailController;

  late final TextEditingController
      _addressController;

  late final TextEditingController
      _panController;

  late final TextEditingController
      _remarksController;

  bool isActive = true;

  @override
  void initState() {
    super.initState();

    final supplier =
        widget.supplier;

    _codeController =
        TextEditingController(
      text:
          supplier?.supplierCode ?? '',
    );

    _nameController =
        TextEditingController(
      text:
          supplier?.supplierName ?? '',
    );

    _contactController =
        TextEditingController(
      text:
          supplier?.contactPerson ?? '',
    );

    _phoneController =
        TextEditingController(
      text:
          supplier?.phone ?? '',
    );

    _emailController =
        TextEditingController(
      text:
          supplier?.email ?? '',
    );

    _addressController =
        TextEditingController(
      text:
          supplier?.address ?? '',
    );

    _panController =
        TextEditingController(
      text:
          supplier?.panNumber ?? '',
    );

    _remarksController =
        TextEditingController(
      text:
          supplier?.remarks ?? '',
    );

    isActive =
        supplier?.isActive ?? true;
  }

  // ============================================================
  // SAVE
  // ============================================================

  void save() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final now =
        DateTime.now()
            .toIso8601String();

    final supplier =
        SupplierModel(
      id: widget.supplier?.id,

      supplierCode:
          _codeController.text.trim(),

      supplierName:
          _nameController.text.trim(),

      contactPerson:
          _contactController.text.trim(),

      phone:
          _phoneController.text.trim(),

      email:
          _emailController.text.trim(),

      address:
          _addressController.text.trim(),

      panNumber:
          _panController.text.trim(),

      remarks:
          _remarksController.text.trim(),

      isActive: isActive,

      createdAt:
          widget.supplier?.createdAt ??
              now,
    );

    Navigator.pop(
      context,
      supplier,
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  InputDecoration decoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon:
          Icon(icon),
      border:
          const OutlineInputBorder(),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final editing =
        widget.supplier != null;

    return AlertDialog(
      title: Text(
        editing
            ? 'Edit Supplier'
            : 'Add Supplier',
      ),

      content: SizedBox(
        width: 500,

        child: SingleChildScrollView(
          child: Form(
            key: _formKey,

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                TextFormField(
                  controller:
                      _codeController,

                  decoration:
                      decoration(
                    'Supplier Code',
                    Icons.tag,
                  ),

                  validator: (value) {
                    if (value ==
                            null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Supplier code is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      _nameController,

                  decoration:
                      decoration(
                    'Supplier Name',
                    Icons.business,
                  ),

                  validator: (value) {
                    if (value ==
                            null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Supplier name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      _contactController,

                  decoration:
                      decoration(
                    'Contact Person',
                    Icons.person,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      _phoneController,

                  keyboardType:
                      TextInputType.phone,

                  decoration:
                      decoration(
                    'Phone',
                    Icons.phone,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      _emailController,

                  keyboardType:
                      TextInputType.emailAddress,

                  decoration:
                      decoration(
                    'Email',
                    Icons.email,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      _addressController,

                  maxLines: 2,

                  decoration:
                      decoration(
                    'Address',
                    Icons.location_on,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      _panController,

                  decoration:
                      decoration(
                    'PAN Number',
                    Icons.badge,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      _remarksController,

                  maxLines: 3,

                  decoration:
                      decoration(
                    'Remarks',
                    Icons.notes,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                SwitchListTile(
                  contentPadding:
                      EdgeInsets.zero,

                  title:
                      const Text(
                    'Active Supplier',
                  ),

                  value: isActive,

                  onChanged: (value) {
                    setState(() {
                      isActive =
                          value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },

          child:
              const Text(
            'Cancel',
          ),
        ),

        ElevatedButton.icon(
          onPressed: save,

          icon:
              const Icon(
            Icons.save,
          ),

          label:
              Text(
            editing
                ? 'Update'
                : 'Save',
          ),
        ),
      ],
    );
  }
}
