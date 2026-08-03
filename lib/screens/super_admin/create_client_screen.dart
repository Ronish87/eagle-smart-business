import 'package:flutter/material.dart';
import '../../widgets/reusable_textfield.dart';

class CreateClientScreen extends StatefulWidget {
  const CreateClientScreen({super.key});

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  final companyController = TextEditingController();
  final ownerController = TextEditingController();
  final adminController = TextEditingController();
  final mobileController = TextEditingController();
  final whatsappController = TextEditingController();
  final emailController = TextEditingController();

  String businessType = "IT Company";

  bool webAccess = true;
  bool mobileAccess = true;

  final List<String> businessTypes = [
    "IT Company",
    "Hotel",
    "Restaurant",
    "Retail Shop",
    "Agriculture",
    "Real Estate",
    "Construction",
    "School",
    "Hospital",
    "Pharmacy",
    "Workshop",
    "Travel & Tours",
    "Trading",
    "Wholesale",
    "Manufacturing",
    "Repair & Service",
    "Online Shop",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Client"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Client Registration",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ReusableTextField(
            controller: companyController,
            label: "Company Name",
            icon: Icons.business,
          ),

          const SizedBox(height: 15),

          ReusableTextField(
            controller: ownerController,
            label: "Owner Name",
            icon: Icons.person,
          ),

          const SizedBox(height: 15),

          ReusableTextField(
            controller: adminController,
            label: "Admin Name",
            icon: Icons.admin_panel_settings,
          ),

          const SizedBox(height: 15),

          ReusableTextField(
            controller: mobileController,
            label: "Mobile Number",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 15),

          ReusableTextField(
            controller: whatsappController,
            label: "WhatsApp Number",
            icon: Icons.message,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 15),

          ReusableTextField(
            controller: emailController,
            label: "Email Address",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            initialValue: businessType,
            decoration: const InputDecoration(
              labelText: "Business Type",
              border: OutlineInputBorder(),
            ),
            items: businessTypes.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: (value) {
              setState(() {
                businessType = value!;
              });
            },
          ),

          const SizedBox(height: 20),

          SwitchListTile(
            title: const Text("Web Access"),
            value: webAccess,
            onChanged: (value) {
              setState(() {
                webAccess = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text("Mobile Access"),
            value: mobileAccess,
            onChanged: (value) {
              setState(() {
                mobileAccess = value;
              });
            },
          ),

          const SizedBox(height: 25),

          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${companyController.text} Client Created Successfully",
                    ),
                  ),
                );
              },
              child: const Text(
                "Create Client",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
