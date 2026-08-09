import 'package:flutter/material.dart';

class CategoryDetailsScreen extends StatelessWidget {
  const CategoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Category Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Category Name', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Electronics'),
                Divider(),
                Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Products related to electronic devices and accessories.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
