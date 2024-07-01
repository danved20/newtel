import 'package:newtel_app/database/database_helper.dart';
import 'package:newtel_app/models/crud_cliente.dart';
import 'package:sqflite/sqflite.dart';

class ClienteDatabase {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> insertCliente(Cliente cliente) async {
    final db = await _databaseHelper.database;
    try {
      await db.insert(
        'cliente',
        cliente.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error al insertar el cliente: $e');
    }
  }

  Future<List<Cliente>> getClientes() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cliente');
    return List.generate(maps.length, (i) => Cliente.fromMap(maps[i]));
  }

  Future<void> updateCliente(Cliente cliente) async {
    final db = await _databaseHelper.database;
    try {
      await db.update(
        'cliente',
        cliente.toMap(),
        where: "id = ?",
        whereArgs: [cliente.id],
      );
    } catch (e) {
      throw Exception('Error al actualizar el cliente: $e');
    }
  }

  Future<void> deleteCliente(int id) async {
    final db = await _databaseHelper.database;
    try {
      await db.delete(
        'cliente',
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error al eliminar el cliente: $e');
    }
  }
}
