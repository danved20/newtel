class Cliente {
  final int? id;
  final String ci;
  final String nombre;
  final String celular;
  final String contacto;
  final String direccion;
  final int id_zona;
  final String ip;
  final int id_plan;
  final String activacion;
  final String estado;
  final String comentario;
  final DateTime created_at;

  Cliente({
    this.id,
    required this.ci,
    required this.nombre,
    required this.celular,
    required this.contacto,
    required this.direccion,
    required this.id_zona,
    required this.ip,
    required this.id_plan,
    required this.activacion,
    required this.estado,
    required this.comentario,
    required this.created_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ci': ci,
      'nombre': nombre,
      'celular': celular,
      'contacto': contacto,
      'direccion': direccion,
      'id_zona': id_zona,
      'ip': ip,
      'id_plan': id_plan,
      'activacion': activacion,
      'estado': estado,
      'comentario': comentario,
      'created_at': created_at.toIso8601String(),
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      ci: map['ci'],
      nombre: map['nombre'],
      celular: map['celular'],
      contacto: map['contacto'],
      direccion: map['direccion'],
      id_zona: map['id_zona'],
      ip: map['ip'],
      id_plan: map['id_plan'],
      activacion: map['activacion'],
      estado: map['estado'],
      comentario: map['comentario'],
      created_at: DateTime.parse(map['created_at']),
    );
  }
}
