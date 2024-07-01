class Zona {
  final int? id;
  final String nombre;
  final String comentario;
  final int id_linea;
  final DateTime created_at;

  Zona({this.id, required this.nombre, required this.comentario, required this.id_linea, required this.created_at});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'comentario': comentario,
      'id_linea': id_linea,
      'created_at': created_at.toIso8601String(),
    };
  }

  factory Zona.fromMap(Map<String, dynamic> map) {
    return Zona(
      id: map['id'],
      nombre: map['nombre'],
      comentario: map['comentario'],
      id_linea: map['id_linea'],
      created_at: DateTime.parse(map['created_at']),
    );
  }
}
