import 'package:flutter/material.dart';

class DashboardStatisticsScreen extends StatelessWidget {
  const DashboardStatisticsScreen({super.key});

  Widget card(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 36),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          card('Total Clients','0',Icons.people),
          card('Active Clients','0',Icons.verified),
          card('Renewals Due','0',Icons.event_repeat),
          card('Admins','0',Icons.admin_panel_settings),
        ],
      ),
    );
  }
}
