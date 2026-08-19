import 'package:eagle_smart_business/models/client_model.dart';
import 'package:eagle_smart_business/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ClientRepository {
  Future<int> insertClient(ClientModel client) async {
    final Database db = await DatabaseService.instance.database;

    return await db.insert(
      'clients',
      client.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ClientModel>> getAllClients() async {
    final Database db = await DatabaseService.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'clients',
      orderBy: 'id DESC',
    );

    return List.generate(
      maps.length,
      (index) => ClientModel.fromMap(maps[index]),
    );
  }

  Future<int> updateClient(ClientModel client) async {
    final Database db = await DatabaseService.instance.database;

    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final Database db = await DatabaseService.instance.database;

    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ClientModel>> searchClients(String keyword) async {
    final Database db = await DatabaseService.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'clients',
      where: 'company_name LIKE ? OR owner_name LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'id DESC',
    );

    return List.generate(
      maps.length,
      (index) => ClientModel.fromMap(maps[index]),
    );
  }
}