import 'package:flutter/material.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clients = [
      {
        "company": "Eagle Scrpio Enterprises",
        "admin": "Nawaraj Tripathee",
        "phone": "9849858790",
      },
      {"company": "ABC Hotel", "admin": "Ram Sharma", "phone": "9811111111"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Client List"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.business)),
              title: Text(client["company"]!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Admin : ${client["admin"]}"),
                  Text("Phone : ${client["phone"]}"),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("$value clicked")));
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: "Open", child: Text("Open")),
                  PopupMenuItem(value: "Edit", child: Text("Edit")),
                  PopupMenuItem(value: "Delete", child: Text("Delete")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
