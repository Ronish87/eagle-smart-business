import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';

class ClientRepository {
  // Insert Client
  Future<int> insertClient({
    required String companyName,
    required String ownerName,
    required String adminName,
    required String mobile,
    required String whatsapp,
    required String email,
    required String businessType,
    required bool webAccess,
    required bool mobileAccess,
  }) async {
    final Database db = await DatabaseService.database;

    return await db.insert('clients', {
      'company_name': companyName,
      'owner_name': ownerName,
      'admin_name': adminName,
      'mobile': mobile,
      'whatsapp': whatsapp,
      'email': email,
      'business_type': businessType,
      'web_access': webAccess ? 1 : 0,
      'mobile_access': mobileAccess ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get All Clients
  Future<List<Map<String, dynamic>>> getClients() async {
    final Database db = await DatabaseService.database;

    return await db.query('clients', orderBy: 'id DESC');
  }

  // Update Client
  Future<int> updateClient({
    required int id,
    required String companyName,
    required String ownerName,
    required String adminName,
    required String mobile,
    required String whatsapp,
    required String email,
    required String businessType,
    required bool webAccess,
    required bool mobileAccess,
  }) async {
    final Database db = await DatabaseService.database;

    return await db.update(
      'clients',
      {
        'company_name': companyName,
        'owner_name': ownerName,
        'admin_name': adminName,
        'mobile': mobile,
        'whatsapp': whatsapp,
        'email': email,
        'business_type': businessType,
        'web_access': webAccess ? 1 : 0,
        'mobile_access': mobileAccess ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete Client
  Future<int> deleteClient(int id) async {
    final Database db = await DatabaseService.database;

    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }
}
