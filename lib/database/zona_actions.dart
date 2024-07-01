import 'package:sqflite/sqflite.dart';
import '../models/crud_zona.dart';
import 'database_helper.dart';

class ZonaDatabase {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> insertZona(Zona zona) async {
    final db = await _databaseHelper.database;
    try {
      await db.insert(
        'zona',
        zona.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw('Error al insertar la zona: $e');
    }
  }

  Future<List<Zona>> getZonas() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('zona');
    return List.generate(maps.length, (i) => Zona.fromMap(maps[i]));
  }

  Future<void> updateZona(Zona zona) async {
    final db = await _databaseHelper.database;
    try {
      await db.update(
        'zona',
        zona.toMap(),
        where: "id = ?",
        whereArgs: [zona.id],
      );
    } catch (e) {
      throw('Error al actualizar la zona: $e');
    }
  }

  Future<void> deleteZona(int id) async {
    final db = await _databaseHelper.database;
    try {
      await db.delete(
        'zona',
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (e) {
      throw('Error al eliminar la zona: $e');
    }
  }
}
