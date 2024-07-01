import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'newtel.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cliente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ci TEXT,
        nombre TEXT,
        celular TEXT,
        contacto TEXT,
        direccion TEXT,
        id_zona INTEGER,
        ip TEXT,
        id_plan INTEGER,
        activacion TEXT,
        estado TEXT,
        comentario TEXT,
        created_at TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE factura (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER,
        id_plan INTEGER,
        mes TEXT,
        fecha_pago TEXT,
        modalidad TEXT,
        monto FLOAT,
        created_at TIMESTAMP,
        FOREIGN KEY (cliente_id) REFERENCES cliente (id),
        FOREIGN KEY (id_plan) REFERENCES plan (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE linea (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        proveedor TEXT,
        velocidad TEXT,
        precio FLOAT,
        tipo TEXT,
        titular TEXT,
        celular TEXT,
        comentario TEXT,
        direccion TEXT,
        encargado TEXT,
        created_at TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE zona (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        comentario TEXT,
        id_linea INTEGER,
        created_at TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS plan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        costo DECIMAL,
        comentario TEXT,
        created_at TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE suspendido (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER,
        codigo BLOB,
        usuario TEXT,
        celular TEXT,
        fecha TEXT,
        monto FLOAT,
        created_at TIMESTAMP,
        FOREIGN KEY (cliente_id) REFERENCES cliente (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE plan_cliente (
        plan_id INTEGER,
        cliente_id INTEGER,
        created_at TIMESTAMP,
        FOREIGN KEY (plan_id) REFERENCES plan (id),
        FOREIGN KEY (cliente_id) REFERENCES cliente (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE zona_linea (
        zona_id INTEGER,
        linea_id INTEGER,
        created_at TIMESTAMP,
        FOREIGN KEY (zona_id) REFERENCES zona (id),
        FOREIGN KEY (linea_id) REFERENCES linea (id)
      );
    ''');
  }
}
