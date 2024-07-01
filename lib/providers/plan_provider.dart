/* import 'package:flutter/material.dart';
import '../database/plan_actions.dart';
import '../models/crud_plan.dart';

class PlanModel with ChangeNotifier {
  List<Plan> _plans = [];

  List<Plan> get plans => _plans;

  Future<void> loadPlans() async {
    _plans = await PlanDatabase().getPlans();
    notifyListeners();
  }

  Future<void> addPlan(Plan plan) async {
    await PlanDatabase().insertPlan(plan);
    _plans.add(plan);
    notifyListeners();
  }

  Future<void> updatePlan(Plan plan) async {
    await PlanDatabase().updatePlan(plan);
    int index = _plans.indexWhere((p) => p.id == plan.id);
    if (index != -1) {
      _plans[index] = plan;
      notifyListeners();
    }
  }

  Future<void> deletePlan(int id) async {
    await PlanDatabase().deletePlan(id);
    _plans.removeWhere((plan) => plan.id == id);
    notifyListeners();
  }
}

 */
import 'package:flutter/material.dart';
import '../models/crud_plan.dart';
import '../services/api_service.dart';

class PlanModel with ChangeNotifier {
  List<Plan> _plans = [];
  final ApiService _apiService = ApiService();

  List<Plan> get plans => _plans;

  // Carga inicial de planes y notificación a listeners
  Future<void> loadPlans() async {
    _plans = await _apiService.getPlans();
    notifyListeners();
  }

  // Agregar plan y actualizar UI
  Future<void> addPlan(Plan plan) async {
    await _apiService.insertPlan(plan);
    _plans.add(plan);
    notifyListeners();
  }

  // Actualizar plan y UI
  Future<void> updatePlan(Plan plan) async {
    await _apiService.updatePlan(plan);
    int index = _plans.indexWhere((p) => p.id == plan.id);
    if (index != -1) {
      _plans[index] = plan;
      notifyListeners();
    }
  }

  // Eliminar plan y actualizar UI
  Future<void> deletePlan(int id) async {
    await _apiService.deletePlan(id);
    _plans.removeWhere((plan) => plan.id == id);
    notifyListeners();
  }
}