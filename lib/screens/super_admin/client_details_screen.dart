import 'package:flutter/material.dart';

class ClientDetailsScreen extends StatelessWidget {
  const ClientDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(title: Text('Company'), subtitle: Text('N/A'))),
          Card(child: ListTile(title: Text('Owner'), subtitle: Text('N/A'))),
          Card(child: ListTile(title: Text('Mobile'), subtitle: Text('N/A'))),
          Card(child: ListTile(title: Text('Email'), subtitle: Text('N/A'))),
          Card(child: ListTile(title: Text('Business Type'), subtitle: Text('N/A'))),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'edit',
            onPressed: () {},
            child: Icon(Icons.edit),
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'delete',
            onPressed: () {},
            child: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
