import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newtel_app/models/crud_plan.dart';

class ApiService {
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
  Future<List<Plan>> getPlans() async {
    final response = await http.get(Uri.parse('$baseUrl/planes/'));
    final jsonResponse = await _processResponse(response);
    if (jsonResponse is List) {
      return jsonResponse.map((plan) => Plan.fromMap(plan)).toList().cast<Plan>();
    } else {
      throw Exception('Expected a list');
    }
  }
  
  Future<void> insertPlan(Plan plan) async {
    final response = await http.post(
      Uri.parse('$baseUrl/planes/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(plan.toMap()),
    );
    await _processResponse(response);
  }

  Future<void> updatePlan(Plan plan) async {
    final response = await http.put(
      Uri.parse('$baseUrl/planes/${plan.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(plan.toMap()),
    );
    await _processResponse(response);
  }

  Future<void> deletePlan(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/planes/$id/'));
    // No se espera un resultado en el cuerpo del mensaje, solo la confirmación de la eliminación
    _processResponse(response);
  }
}
