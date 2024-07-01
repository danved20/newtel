import 'package:flutter/material.dart';
import 'package:newtel_app/services/zona_service.dart';

import '../models/crud_linea.dart';
import '../models/crud_zona.dart';

class ZonaModel with ChangeNotifier {
  List<Zona> _zonas = [];
  List<Linea> _lineas = [];
  final ZonaService _zonaService = ZonaService();
  

  List<Zona> get zonas => _zonas;
  List<Linea> get lineas => _lineas;

  // Carga inicial de zonas y notificación a los listeners
  Future<void> loadZonas() async {
    _zonas = await _zonaService.getZonas();
    notifyListeners();
  }

  Future<void> loadLineas() async {
    _lineas = await _zonaService.getLineas();
    notifyListeners();
  }

  // Agregar zona y actualizar UI
  Future<void> addZona(Zona zona) async {
    await _zonaService.insertZona(zona);
    _zonas.add(zona);
    notifyListeners();
  }

  // Actualizar zona y UI
  Future<void> updateZona(Zona zona) async {
    await _zonaService.updateZona(zona);
    int index = _zonas.indexWhere((z) => z.id == zona.id);
    if (index != -1) {
      _zonas[index] = zona;
      notifyListeners();
    }
  }

  // Eliminar zona y actualizar UI
  Future<void> deleteZona(int id) async {
    await _zonaService.deleteZona(id);
    _zonas.removeWhere((zona) => zona.id == id);
    notifyListeners();
  }
  
  String getLineaNombre(int id) {
    final linea = _lineas.firstWhere((linea) => linea.id == id, orElse: () => Linea(
      id: 0, nombre: 'Desconocido', 
      proveedor: '', velocidad: '', 
      precio: 0, tipo: '', titular: '', celular: '', comentario: '', direccion: '', encargado: '', created_at: DateTime.timestamp(),
    ));
    return linea.nombre;
  }
}
