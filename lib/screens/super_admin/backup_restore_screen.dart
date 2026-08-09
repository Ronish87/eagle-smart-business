import 'package:flutter/material.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup Database'),
              subtitle: const Text('Create a backup of your ERP database'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Backup'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore Database'),
              subtitle: const Text('Restore from a previous backup'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Restore'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
