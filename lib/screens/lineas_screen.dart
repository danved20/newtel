import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/crud_linea.dart';
import '../providers/lienea_provider.dart';


class LineasScreen extends StatefulWidget {
  const LineasScreen({super.key});

  @override
  _LineasScreenState createState() => _LineasScreenState();
}

class _LineasScreenState extends State<LineasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();
  final TextEditingController _velocidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _titularController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _encargadoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Linea? _selectedLinea;
  List<Linea> _filteredLineas = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    _searchController.addListener(_filterLineas);
  }

  Future<void> _loadInitialData() async {
    final lineaModel = Provider.of<LineaModel>(context, listen: false);
    await lineaModel.loadLineas();
    _updateFilteredLineas();
  }

  void _filterLineas() {
    _updateFilteredLineas();
  }

  void _updateFilteredLineas() {
    final lineaModel = Provider.of<LineaModel>(context, listen: false);
    setState(() {
      _filteredLineas = lineaModel.lineas
          .where((linea) => linea.nombre
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _proveedorController.dispose();
    _velocidadController.dispose();
    _precioController.dispose();
    _tipoController.dispose();
    _titularController.dispose();
    _celularController.dispose();
    _comentarioController.dispose();
    _direccionController.dispose();
    _encargadoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Líneas'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child:  Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      buildTextField(_nombreController, 'Nombre'),
                      buildTextField(_proveedorController, 'Proveedor'),
                      buildTextField(_velocidadController, 'Velocidad'),
                      buildTextField(_precioController, 'Precio', isNumeric: true),
                      buildTextField(_tipoController, 'Tipo'),
                      buildTextField(_titularController, 'Titular'),
                      buildTextField(_celularController, 'Celular'),
                      buildTextField(_comentarioController, 'Comentario'),
                      buildTextField(_direccionController, 'Dirección'),
                      buildTextField(_encargadoController, 'Encargado'),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar línea',
                          labelStyle: TextStyle(color: Colors.blue[800]),
                          prefixIcon: const Icon(Icons.search,color: Colors.blue,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onChanged: (value) => _filterLineas(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                            onPressed: _clearFields,
                            child: const Text('Limpiar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                            onPressed: () => _saveOrUpdateLinea(context),
                            child: Text(_selectedLinea == null ? 'Guardar' : 'Actualizar'),
                          ),
                          if (_selectedLinea != null)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                textStyle: const TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _deleteLinea(context),
                              child: const Text('Eliminar'),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildLineaList(context),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese $label';
        }
        return null;
      },
    );
  }

  void _clearFields() {
    _formKey.currentState!.reset();
    _nombreController.clear();
    _proveedorController.clear();
    _velocidadController.clear();
    _precioController.clear();
    _tipoController.clear();
    _titularController.clear();
    _celularController.clear();
    _comentarioController.clear();
    _direccionController.clear();
    _encargadoController.clear();
    _searchController.clear();
    setState(() {
      _selectedLinea = null;
    });
    _updateFilteredLineas();
  }

  Future<void> _deleteLinea(BuildContext context) async {
    if (_selectedLinea != null && _selectedLinea!.id != null) {
      await Provider.of<LineaModel>(context, listen: false)
          .deleteLinea(_selectedLinea!.id!);
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Línea eliminada con éxito')));
      _updateFilteredLineas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar la línea')));
    }
  }

  void _selectLineaForEditing(Linea linea) {
    setState(() {
      _selectedLinea = linea;
      _nombreController.text = linea.nombre;
      _proveedorController.text = linea.proveedor;
      _velocidadController.text = linea.velocidad;
      _precioController.text = linea.precio.toString();
      _tipoController.text = linea.tipo;
      _titularController.text = linea.titular;
      _celularController.text = linea.celular;
      _comentarioController.text = linea.comentario;
      _direccionController.text = linea.direccion;
      _encargadoController.text = linea.encargado;
    });
  }

  Future<void> _saveOrUpdateLinea(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final linea = Linea(
        id: _selectedLinea?.id,
        nombre: _nombreController.text,
        proveedor: _proveedorController.text,
        velocidad: _velocidadController.text,
        precio: double.tryParse(_precioController.text) ?? 0.0,
        tipo: _tipoController.text,
        titular: _titularController.text,
        celular: _celularController.text,
        comentario: _comentarioController.text,
        direccion: _direccionController.text,
        encargado: _encargadoController.text,
        created_at: _selectedLinea?.created_at ?? DateTime.now(),
      );
      try {
        if (_selectedLinea == null) {
          await Provider.of<LineaModel>(context, listen: false).addLinea(linea);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Línea agregada con éxito')));
        } else {
          await Provider.of<LineaModel>(context, listen: false).updateLinea(linea);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Línea actualizada con éxito')));
        }
        _clearFields();
        _updateFilteredLineas();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al guardar la línea: $e')));
      }
    }
  }

  Widget _buildLineaList(BuildContext context) {
    return Consumer<LineaModel>(
      builder: (context, lineaModel, child) {
        if (_filteredLineas.isEmpty) {
          return const Center(child: Text("No hay líneas disponibles."));
        }
        return InteractiveViewer(
          constrained: false,
          child:  DataTable(
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Proveedor')),
              DataColumn(label: Text('Velocidad')),
              DataColumn(label: Text('Precio')),
              DataColumn(label: Text('Tipo')),
              DataColumn(label: Text('Titular')),
              DataColumn(label: Text('Celular')),
              DataColumn(label: Text('Comentario')),
              DataColumn(label: Text('Dirección')),
              DataColumn(label: Text('Encargado')),
            ],
            rows: _filteredLineas.map(
              (linea) => DataRow(
                cells: [
                  DataCell(Text(linea.nombre), onTap: () => _selectLineaForEditing(linea)),
                  DataCell(Text(linea.proveedor)),
                  DataCell(Text(linea.velocidad)),
                  DataCell(Text(linea.precio.toStringAsFixed(2))),
                  DataCell(Text(linea.tipo)),
                  DataCell(Text(linea.titular)),
                  DataCell(Text(linea.celular)),
                  DataCell(Text(linea.comentario)),
                  DataCell(Text(linea.direccion)),
                  DataCell(Text(linea.encargado)),
                ],
              ),
            ).toList(),
          ),
        );
      },
    );
  }
}
