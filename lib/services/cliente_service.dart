import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newtel_app/models/crud_cliente.dart';

class ClienteService {
  //final String baseUrl = 'http://192.168.0.22:8000/api';
  final String baseUrl = 'http://192.168.251.136:800/api';

  dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else if (response.statusCode == 204) {
      return null;
    } else {
      throw Exception('Error with request: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<Cliente>> getClientes() async {
    final response = await http.get(Uri.parse('$baseUrl/clientes/'));
    final jsonResponse = await _processResponse(response);
    if (jsonResponse is List) {
      return jsonResponse.map((cliente) => Cliente.fromMap(cliente)).toList().cast<Cliente>();
    } else {
      throw Exception('Expected a list');
    }
  }
  
  Future<void> insertCliente(Cliente cliente) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clientes/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cliente.toMap()),
    );
    await _processResponse(response);
  }

  Future<void> updateCliente(Cliente cliente) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clientes/${cliente.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cliente.toMap()),
    );
    await _processResponse(response);
  }

  Future<void> deleteCliente(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/clientes/$id/'));
    _processResponse(response);
  }
}
