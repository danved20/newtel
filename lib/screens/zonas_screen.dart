import 'package:flutter/material.dart';
import 'package:newtel_app/models/crud_linea.dart';
import 'package:provider/provider.dart';

import '../models/crud_zona.dart';
import '../providers/zona_provider.dart';

class ZonasScreen extends StatefulWidget {
  const ZonasScreen({super.key});

  @override
  _ZonasScreenState createState() => _ZonasScreenState();
}

class _ZonasScreenState extends State<ZonasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Zona? _selectedZona;
  List<Zona> _filteredZonas = [];
  int? _selectedLinea;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    _searchController.addListener(_filterZonas);
  }

  Future<void> _loadInitialData() async {
    final zonaModel = Provider.of<ZonaModel>(context, listen: false);
    await zonaModel.loadZonas();
    await zonaModel.loadLineas(); // Cargamos las líneas
    _updateFilteredZonas();
  }

  void _filterZonas() {
    _updateFilteredZonas();
  }

  void _updateFilteredZonas() {
    final zonaModel = Provider.of<ZonaModel>(context, listen: false);
    setState(() {
      _filteredZonas = zonaModel.zonas
          .where((zona) => zona.nombre
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _comentarioController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Zonas'),
      ),
      body:Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      buildTextField(_nombreController, 'Nombre'),
                      buildTextField(_comentarioController, 'Comentario'),
                      const SizedBox(height: 20),
                      Consumer<ZonaModel>(
                        builder: (context, zonaModel, child) {
                          return DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'ID de Línea',
                              labelStyle: TextStyle(color: Colors.blue[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            value: _selectedLinea,
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedLinea = newValue;
                              });
                            },
                            items: zonaModel.lineas.map<DropdownMenuItem<int>>((Linea linea) {
                              return DropdownMenuItem<int>(
                                value: linea.id,
                                child: Text(linea.nombre),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor seleccione un ID de Línea';
                              }
                              return null;
                            },
                          );
                        }
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar zona',
                          labelStyle: const TextStyle(color: Colors.blue),
                          prefixIcon: const Icon(Icons.search,color: Colors.blue,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onChanged: (value) => _filterZonas(),
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
                            onPressed: () => _saveOrUpdateZona(context),
                            child: Text(_selectedZona == null ? 'Guardar' : 'Actualizar'),
                          ),
                          if (_selectedZona != null)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                textStyle: const TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _deleteZona(context),
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
              child: _buildZonaList(context),
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
    _comentarioController.clear();
    _searchController.clear();
    setState(() {
      _selectedZona = null;
      _selectedLinea = null;
    });
    _updateFilteredZonas();
  }

  Future<void> _deleteZona(BuildContext context) async {
    if (_selectedZona != null && _selectedZona!.id != null) {
      await Provider.of<ZonaModel>(context, listen: false)
          .deleteZona(_selectedZona!.id!);
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zona eliminada con éxito')));
      _updateFilteredZonas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar la zona')));
    }
  }

  void _selectZonaForEditing(Zona zona) {
    setState(() {
      _selectedZona = zona;
      _nombreController.text = zona.nombre;
      _comentarioController.text = zona.comentario;
      _selectedLinea = zona.id_linea;
    });
  }

  Future<void> _saveOrUpdateZona(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final zona = Zona(
        id: _selectedZona?.id,
        nombre: _nombreController.text,
        comentario: _comentarioController.text,
        id_linea: _selectedLinea!,
        created_at: _selectedZona?.created_at ?? DateTime.now(),
      );
      try {
        if (_selectedZona == null) {
          await Provider.of<ZonaModel>(context, listen: false).addZona(zona);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zona agregada con éxito')));
        } else {
          await Provider.of<ZonaModel>(context, listen: false).updateZona(zona);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zona actualizada con éxito')));
        }
        _clearFields();
        _updateFilteredZonas();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al guardar la zona: $e')));
      }
    }
  }

  Widget _buildZonaList(BuildContext context) {
    return Consumer<ZonaModel>(
      builder: (context, zonaModel, child) {
        if (_filteredZonas.isEmpty) {
          return const Center(child: Text("No hay zonas disponibles."));
        }
        return InteractiveViewer(
          constrained: false,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Comentario')),
              DataColumn(label: Text('Id linea')),
            ],
            rows: _filteredZonas.map(
              (zona) => DataRow(
                cells: [
                  DataCell(Text(zona.nombre), onTap: () => _selectZonaForEditing(zona)),
                  DataCell(Text(zona.comentario)),
                  DataCell(Text(zonaModel.getLineaNombre(zona.id_linea))),
                ],
              ),
            ).toList(),
          ) 
        );
      },
    );
  }
}
