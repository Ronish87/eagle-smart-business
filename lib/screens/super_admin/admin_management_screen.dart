import 'package:flutter/material.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Management'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.admin_panel_settings)),
              title: Text('No Admin Available'),
              subtitle: Text(
                'Admin database integration will be added next stage.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
