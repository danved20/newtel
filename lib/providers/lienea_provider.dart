import 'package:flutter/material.dart';

import '../models/crud_linea.dart';
import '../services/linea_service.dart';

class LineaModel with ChangeNotifier {
  List<Linea> _lineas = [];
  final LineaService _lineaService = LineaService();

  List<Linea> get lineas => _lineas;

  // Carga inicial de líneas y notificación a listeners
  Future<void> loadLineas() async {
    _lineas = await _lineaService.getLineas();
    notifyListeners();
  }

  // Agregar línea y actualizar UI
  Future<void> addLinea(Linea linea) async {
    await _lineaService.insertLinea(linea);
    _lineas.add(linea);
    notifyListeners();
  }

  // Actualizar línea y UI
  Future<void> updateLinea(Linea linea) async {
    await _lineaService.updateLinea(linea);
    int index = _lineas.indexWhere((l) => l.id == linea.id);
    if (index != -1) {
      _lineas[index] = linea;
      notifyListeners();
    }
  }

  // Eliminar línea y actualizar UI
  Future<void> deleteLinea(int id) async {
    await _lineaService.deleteLinea(id);
    _lineas.removeWhere((linea) => linea.id == id);
    notifyListeners();
  }
}
