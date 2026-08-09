import 'package:flutter/material.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Low Stock')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.warning_amber_rounded,color: Colors.orange),
            title: Text('Product ${index + 1}'),
            subtitle: const Text('Current Stock: 2 | Minimum: 5'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Restock'),
            ),
          );
        },
      ),
    );
  }
}
