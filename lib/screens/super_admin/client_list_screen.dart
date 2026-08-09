import 'package:flutter/material.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client List'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Client...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'No clients found.\nDatabase integration will be added next.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
