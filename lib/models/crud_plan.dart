/* class Plan {
  final int? id; 
  final String name;
  final double costo;
  final String comentario;

  Plan({this.id, required this.name, required this.costo, required this.comentario});

  Map<String, dynamic> toMap() {
    return {
      'id': id,  
      'nombre': name,
      'costo': costo,
      'comentario': comentario,
    };
  }

  factory Plan.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null || map['nombre'] == null || map['costo'] == null || map['comentario'] == null) {
      throw Exception('Missing data for Plan'); 
    }
    return Plan(
      id: map['id'] as int,
      name: map['nombre'] as String,
      costo: (map['costo'] as num).toDouble(),  
      comentario: map['comentario'] as String,
    );
  }

  @override
  String toString() {
    return 'Plan{id: $id, name: $name, costo: $costo, comentario: $comentario}';
  }
}
 */
class Plan {
  final int? id;
  final String name;
  final double costo;
  final String comentario;
  final DateTime created_at;

  Plan({this.id, required this.name, required this.costo, required this.comentario,required this.created_at});

  // Convertir el objeto Plan a un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,           // Incluye el id solo si no es null
      'nombre': name,
      'costo': costo,
      'comentario': comentario,
      'created_at': created_at.toIso8601String(),
    };
  }

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      id: map['id'],
      name: map['nombre'],
      costo: double.parse(map['costo'].toString()),
      comentario: map['comentario'],
      created_at: DateTime.parse(map['created_at']),
    );
  }
}
