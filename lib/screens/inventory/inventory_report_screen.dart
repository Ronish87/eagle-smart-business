import 'package:flutter/material.dart';

class InventoryReportScreen extends StatelessWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DataTable(columns: const [
          DataColumn(label: Text('Product')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Status')),
        ], rows: const [
          DataRow(cells:[
            DataCell(Text('Sample Product')),
            DataCell(Text('25')),
            DataCell(Text('Available')),
          ]),
          DataRow(cells:[
            DataCell(Text('Low Stock Item')),
            DataCell(Text('2')),
            DataCell(Text('Low')),
          ]),
        ]),
      ),
    );
  }
}
