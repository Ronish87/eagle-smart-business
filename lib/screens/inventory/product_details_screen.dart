import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            ListTile(title: Text('Product Code'), subtitle: Text('-')),
            ListTile(title: Text('Product Name'), subtitle: Text('-')),
            ListTile(title: Text('Category'), subtitle: Text('-')),
            ListTile(title: Text('Purchase Price'), subtitle: Text('-')),
            ListTile(title: Text('Selling Price'), subtitle: Text('-')),
            ListTile(title: Text('Current Stock'), subtitle: Text('-')),
          ],
        ),
      ),
    );
  }
}
