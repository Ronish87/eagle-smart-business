import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.business),
            title: Text('Company Settings'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Security'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup & Restore'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Eagle Smart Business'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
