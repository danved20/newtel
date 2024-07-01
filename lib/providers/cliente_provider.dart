import 'package:flutter/material.dart';
import 'package:newtel_app/services/api_service.dart';
import 'package:newtel_app/services/cliente_service.dart';  
import 'package:newtel_app/models/crud_cliente.dart';

import '../models/crud_plan.dart';
import '../models/crud_zona.dart';
import '../services/zona_service.dart';

class ClienteModel with ChangeNotifier {
  List<Cliente> _clientes = [];
  List<Zona> _zonas = [];
  List<Plan> _planes = [];

  final ClienteService _clienteService = ClienteService();
  final ZonaService _zonaService = ZonaService();
  final ApiService _apiService = ApiService();

  List<Cliente> get clientes => _clientes;
  List<Zona> get zonas => _zonas;
  List<Plan> get planes => _planes;

  Future<void> loadClientes() async {
    _clientes = await _clienteService.getClientes();
    notifyListeners();
  }
  Future<void> loadZonas() async {
    _zonas = await _zonaService.getZonas();
    notifyListeners();
  }

   Future<void> loadPlanes() async {
    _planes = await _apiService.getPlans();
    notifyListeners();
  }

  Future<void> addCliente(Cliente cliente) async {
    await _clienteService.insertCliente(cliente);
    _clientes.add(cliente);
    notifyListeners();

  }

  Future<void> updateCliente(Cliente cliente) async {
    await _clienteService.updateCliente(cliente);
    int index = _clientes.indexWhere((c) => c.id == cliente.id);
    if (index != -1) {
      _clientes[index] = cliente;
      notifyListeners();
    }
  }

  Future<void> deleteCliente(int id) async {
    await _clienteService.deleteCliente(id);
    _clientes.removeWhere((cliente) => cliente.id == id);
    notifyListeners();
  }

  String getZonaNombre(int id) {
    final zona = _zonas.firstWhere((zona) => zona.id == id, orElse: () => Zona(
      id: 0, nombre: 'Desconocido', comentario: '', id_linea: 0, created_at: DateTime.timestamp(), 
    ));
    return zona.nombre;
  }

  String getPlanNombre(int id) {
    final plan = _planes.firstWhere((plan) => plan.id == id, orElse: () => Plan(
      id: 0, name: 'Desconocido', costo: 0, comentario: '', created_at: DateTime.timestamp(),
    ));
    return plan.name;
  }
}
