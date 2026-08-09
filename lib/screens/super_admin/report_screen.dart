import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Client Report'),
              subtitle: const Text('View all registered clients'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Business Report'),
              subtitle: const Text('Business summary and statistics'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Renewal Report'),
              subtitle: const Text('Upcoming renewals'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
