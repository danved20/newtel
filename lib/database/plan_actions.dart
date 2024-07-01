import 'package:newtel_app/database/database_helper.dart';
import 'package:newtel_app/models/crud_plan.dart';

import 'package:sqflite/sqflite.dart';

class PlanDatabase {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> insertPlan(Plan plan) async {
    final db = await _databaseHelper.database;
    try {
      await db.insert(
        'plan',
        plan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw('Error al insertar el plan: $e');
    }
  }

  Future<List<Plan>> getPlans() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('plan');
    return List.generate(maps.length, (i) => Plan.fromMap(maps[i]));
  }

  Future<void> updatePlan(Plan plan) async {
    final db = await _databaseHelper.database;
    try {
      await db.update(
        'plan',
        plan.toMap(),
        where: "id = ?",
        whereArgs: [plan.id],
      );
    } catch (e) {
      throw('Error al actualizar el plan: $e');
    }
  }

  Future<void> deletePlan(int id) async {
    final db = await _databaseHelper.database;
    try {
      await db.delete(
        'plan',
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (e) {
      throw('Error al eliminar el plan: $e');
    }
  }
}
