import 'package:newtel_app/database/database_helper.dart';

import 'package:sqflite/sqflite.dart';

import '../models/crud_linea.dart';

class LineaDatabase {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> insertLinea(Linea linea) async {
    final db = await _databaseHelper.database;
    try {
      await db.insert(
        'linea',
        linea.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw('Error al insertar la línea: $e');
    }
  }

  Future<List<Linea>> getLineas() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('linea');
    return List.generate(maps.length, (i) => Linea.fromMap(maps[i]));
  }

  Future<void> updateLinea(Linea linea) async {
    final db = await _databaseHelper.database;
    try {
      await db.update(
        'linea',
        linea.toMap(),
        where: "id = ?",
        whereArgs: [linea.id],
      );
    } catch (e) {
      throw('Error al actualizar la línea: $e');
    }
  }

  Future<void> deleteLinea(int id) async {
    final db = await _databaseHelper.database;
    try {
      await db.delete(
        'linea',
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (e) {
      throw('Error al eliminar la línea: $e');
    }
  }
}
