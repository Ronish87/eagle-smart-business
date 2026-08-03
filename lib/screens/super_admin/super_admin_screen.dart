import 'package:flutter/material.dart';
import 'create_client_screen.dart';
import 'client_list_screen.dart';

class SuperAdminScreen extends StatelessWidget {
  const SuperAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Super Admin Dashboard"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Icon(Icons.business, size: 60, color: Colors.blue),

                  SizedBox(height: 10),

                  Text(
                    "Eagle Smart Business",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Developer : Nawaraj Tripathee",
                    style: TextStyle(fontSize: 16),
                  ),

                  Text(
                    "Company : Eagle Scrpio Enterprises Pvt. Ltd.",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          dashboardButton(context, "🏢 Create Client", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateClientScreen(),
              ),
            );
          }),

          dashboardButton(context, "📋 Client List", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClientListScreen()),
            );
          }),

          dashboardButton(context, "👤 Admin Management", () {}),

          dashboardButton(context, "🏬 Business Profiles", () {}),

          dashboardButton(context, "📦 Renewal", () {}),

          dashboardButton(context, "☁ Google Drive Backup", () {}),

          dashboardButton(context, "📊 Reports", () {}),

          dashboardButton(context, "⚙ Settings", () {}),

          dashboardButton(context, "🤖 AI Assistant", () {}),

          dashboardButton(context, "🚪 Logout", () {}),
        ],
      ),
    );
  }

  static Widget dashboardButton(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: onTap,
          child: Text(title, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
