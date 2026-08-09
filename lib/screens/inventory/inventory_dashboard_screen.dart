import 'package:flutter/material.dart';

class InventoryDashboardScreen extends StatelessWidget {
  const InventoryDashboardScreen({super.key});

  Widget _card(String title, IconData icon, BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card('Products', Icons.inventory_2, context),
          _card('Add Product', Icons.add_box, context),
          _card('Stock In', Icons.arrow_downward, context),
          _card('Stock Out', Icons.arrow_upward, context),
          _card('Low Stock', Icons.warning_amber, context),
          _card('Inventory Report', Icons.assessment, context),
        ],
      ),
    );
  }
}
