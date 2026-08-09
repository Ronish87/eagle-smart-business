import 'package:flutter/material.dart';

import 'brand_screen.dart';
import 'category_screen.dart';
import 'supplier_screen.dart';

class InventoryDashboard extends StatelessWidget {
  const InventoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Management"),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.15,
        children: [
          _menuCard(
            context,
            title: "Products",
            icon: Icons.inventory_2,
            color: Colors.blue,
            onTap: () {
              // TODO: Product Screen
            },
          ),

          _menuCard(
            context,
            title: "Categories",
            icon: Icons.category,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryScreen()),
              );
            },
          ),

          _menuCard(
            context,
            title: "Brands",
            icon: Icons.workspace_premium,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrandScreen()),
              );
            },
          ),

          _menuCard(
            context,
            title: "Suppliers",
            icon: Icons.local_shipping,
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupplierScreen()),
              );
            },
          ),

          _menuCard(
            context,
            title: "Stock In",
            icon: Icons.arrow_downward,
            color: Colors.teal,
            onTap: () {
              // TODO
            },
          ),

          _menuCard(
            context,
            title: "Stock Out",
            icon: Icons.arrow_upward,
            color: Colors.red,
            onTap: () {
              // TODO
            },
          ),

          _menuCard(
            context,
            title: "Purchase",
            icon: Icons.shopping_cart,
            color: Colors.indigo,
            onTap: () {
              // TODO
            },
          ),

          _menuCard(
            context,
            title: "Inventory Report",
            icon: Icons.bar_chart,
            color: Colors.brown,
            onTap: () {
              // TODO
            },
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: .15),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
