import 'package:flutter/material.dart';
import 'create_client_screen.dart';
import 'client_list_screen.dart';
import 'admin_management_screen.dart';
import 'business_profile_screen.dart';
import 'renewal_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

class SuperAdminScreen extends StatelessWidget {
  const SuperAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _btn(context, "🏢 Create Client", const CreateClientScreen()),
          _btn(context, "📋 Client List", const ClientListScreen()),
          _btn(context, "👤 Admin Management", const AdminManagementScreen()),
          _btn(context, "🏬 Business Profiles", const BusinessProfileScreen()),
          _btn(context, "📦 Renewal", const RenewalScreen()),
          _btn(context, "📊 Reports", const ReportScreen()),
          _btn(context, "⚙ Settings", const SettingsScreen()),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 55,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
          child: Text(title),
        ),
      ),
    );
  }
}
