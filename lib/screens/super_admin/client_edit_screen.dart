import 'package:flutter/material.dart';

class ClientEditScreen extends StatefulWidget {
  const ClientEditScreen({super.key});

  @override
  State<ClientEditScreen> createState() => _ClientEditScreenState();
}

class _ClientEditScreenState extends State<ClientEditScreen> {
  final companyController = TextEditingController();
  final ownerController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    companyController.dispose();
    ownerController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Client'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: companyController,
            decoration: const InputDecoration(
              labelText: 'Company Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            decoration: const InputDecoration(
              labelText: 'Owner Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: mobileController,
            decoration: const InputDecoration(
              labelText: 'Mobile',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Client updated successfully')),
              );
            },
            child: const Text('Update Client'),
          ),
        ],
      ),
    );
  }
}
