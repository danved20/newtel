import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/crud_linea.dart';
import '../models/crud_zona.dart';

class ZonaService {
  //final String baseUrl = 'http://192.168.0.22:8000/api';
  final String baseUrl = 'http://192.168.251.136:800/api';

  dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Decodifica y devuelve la respuesta si es 200
      return json.decode(response.body);
    } else if (response.statusCode == 204) {
      // Devuelve null o un objeto vacío si el código de estado es 204
      return null;
    } else {
      // Lanza una excepción si el código de estado no es 200 ni 204
      throw Exception('Error with request: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<Zona>> getZonas() async {
    final response = await http.get(Uri.parse('$baseUrl/zonas/'));
    final jsonResponse = await _processResponse(response);
    if (jsonResponse is List) {
      return jsonResponse.map((zona) => Zona.fromMap(zona)).toList().cast<Zona>();
    } else {
      throw Exception('Expected a list');
    }
  }
  
  Future<void> insertZona(Zona zona) async {
    final response = await http.post(
      Uri.parse('$baseUrl/zonas/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(zona.toMap()),
    );
    await _processResponse(response);
  }

  Future<void> updateZona(Zona zona) async {
    final response = await http.put(
      Uri.parse('$baseUrl/zonas/${zona.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(zona.toMap()),
    );
    await _processResponse(response);
  }

  Future<void> deleteZona(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/zonas/$id/'));
    _processResponse(response);
  }

  Future<List<Linea>> getLineas() async {
    final response = await http.get(Uri.parse('$baseUrl/lineas/'));
    final jsonResponse = await _processResponse(response);
    if (jsonResponse is List) {
      return jsonResponse.map((linea) => Linea.fromMap(linea)).toList().cast<Linea>();
    } else {
      throw Exception('Expected a list');
    }
  }
}
