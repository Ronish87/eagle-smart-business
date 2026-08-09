import 'package:flutter/material.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Profiles'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_business),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.business, size: 36),
              title: Text('No Business Profiles'),
              subtitle: Text(
                'Business profiles will appear here after clients are created.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
