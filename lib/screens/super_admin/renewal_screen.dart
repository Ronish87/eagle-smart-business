import 'package:flutter/material.dart';

class RenewalScreen extends StatelessWidget {
  const RenewalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renewal Management'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.event_repeat, size: 36),
              title: Text('No Renewals'),
              subtitle: Text('Client renewals will appear here.'),
            ),
          ),
        ],
      ),
    );
  }
}
