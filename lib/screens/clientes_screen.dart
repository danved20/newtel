import 'package:flutter/material.dart';
import 'package:newtel_app/models/crud_zona.dart';
import 'package:provider/provider.dart';

import '../models/crud_cliente.dart';
import '../models/crud_plan.dart';
import '../providers/cliente_provider.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ciController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _idZonaController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _idPlanController = TextEditingController();
  final TextEditingController _activacionController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Cliente? _selectedCliente;
  List<Cliente> _filteredClientes = [];
  int? _selectedZona;
  int? _selectedPlan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    _searchController.addListener(_filterClientes);
  }

  Future<void> _loadInitialData() async {
    final clienteModel = Provider.of<ClienteModel>(context, listen: false);
    await clienteModel.loadClientes();
    await clienteModel.loadZonas();
    await clienteModel.loadPlanes();
    _updateFilteredClientes();
  }

  void _filterClientes() {
    _updateFilteredClientes();
  }

  void _updateFilteredClientes() {
    final clienteModel = Provider.of<ClienteModel>(context, listen: false);
    setState(() {
      _filteredClientes = clienteModel.clientes
          .where((cliente) => cliente.nombre.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _ciController.dispose();
    _nombreController.dispose();
    _celularController.dispose();
    _contactoController.dispose();
    _direccionController.dispose();
    _idZonaController.dispose();
    _ipController.dispose();
    _idPlanController.dispose();
    _activacionController.dispose();
    _estadoController.dispose();
    _comentarioController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clientes'),
      ),
      body: Container(
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
                      buildTextField(_ciController, 'C.I.'),
                      buildTextField(_nombreController, 'Nombre'),
                      buildTextField(_celularController, 'Celular'),
                      buildTextField(_contactoController, 'Contacto'),
                      buildTextField(_direccionController, 'Dirección'),

                      const SizedBox(height: 10),

                      Consumer<ClienteModel>(
                        builder: (context, clienteModel, child) {
                          return DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'ID de Zona',
                              labelStyle: TextStyle(color: Colors.blue[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            value: _selectedZona,
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedZona = newValue;
                              });
                            },
                            items: clienteModel.zonas.map<DropdownMenuItem<int>>((Zona zona) {
                              return DropdownMenuItem<int>(
                                value: zona.id,
                                child: Text(zona.nombre),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor seleccione un NOMBRE de Zona';
                              }
                              return null;
                            },
                          );
                        }
                      ),
                      buildTextField(_ipController, 'IP'),

                      const SizedBox(height: 10),

                      Consumer<ClienteModel>(
                        builder: (context, clienteModel, child) {
                          return DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'ID de Linea',
                              labelStyle: TextStyle(color: Colors.blue[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            value: _selectedPlan,
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedPlan = newValue;
                              });
                            },
                            items: clienteModel.planes.map<DropdownMenuItem<int>>((Plan plan) {
                              return DropdownMenuItem<int>(
                                value: plan.id,
                                child: Text(plan.name),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor seleccione un NOMBRE de Plan';
                              }
                              return null;
                            },
                          );
                        }
                      ),
                      buildTextField(_activacionController, 'Activación'),
                      buildTextField(_estadoController, 'Estado'),
                      buildTextField(_comentarioController, 'Comentario'),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar cliente',
                          labelStyle: TextStyle(color: Colors.blue[800]),
                          prefixIcon: const Icon(Icons.search,color: Colors.blue,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onChanged: (value) => _filterClientes(),
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
                            onPressed: () => _saveOrUpdateCliente(context),
                            child: Text(_selectedCliente == null ? 'Guardar' : 'Actualizar'),
                          ),
                          if (_selectedCliente != null)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                textStyle: const TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _deleteCliente(context),
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
              child: _buildClienteList(context),
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
      keyboardType: isNumeric ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese $label';
        }
        return null;
      },
    );
  }

  TextFormField buildNumericField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese $label';
        }
        if (int.tryParse(value) == null) {
          return 'Ingrese un número válido para $label';
        }
        return null;
      },
    );
  }

  void _clearFields() {
    _formKey.currentState!.reset();
    _ciController.clear();
    _nombreController.clear();
    _celularController.clear();
    _contactoController.clear();
    _direccionController.clear();
    _idZonaController.clear();
    _ipController.clear();
    _idPlanController.clear();
    _activacionController.clear();
    _estadoController.clear();
    _comentarioController.clear();
    _searchController.clear();
    setState(() {
      _selectedCliente = null;
      _selectedZona = null;
      _selectedPlan = null;
    });
    _updateFilteredClientes();
  }

  Future<void> _deleteCliente(BuildContext context) async {
    if (_selectedCliente != null && _selectedCliente!.id != null) {
      await Provider.of<ClienteModel>(context, listen: false)
          .deleteCliente(_selectedCliente!.id!);
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente eliminado con éxito')));
      _updateFilteredClientes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el cliente')));
    }
  }

  void _selectClienteForEditing(Cliente cliente) {
    setState(() {
      _selectedCliente = cliente;
      _ciController.text = cliente.ci;
      _nombreController.text = cliente.nombre;
      _celularController.text = cliente.celular;
      _contactoController.text = cliente.contacto;
      _direccionController.text = cliente.direccion;
      _selectedZona = cliente.id_zona;
      _ipController.text = cliente.ip;
      _selectedPlan = cliente.id_plan;
      _activacionController.text = cliente.activacion;
      _estadoController.text = cliente.estado;
      _comentarioController.text = cliente.comentario;
    });
  }

  Future<void> _saveOrUpdateCliente(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final cliente = Cliente(
        id: _selectedCliente?.id,
        ci: _ciController.text,
        nombre: _nombreController.text,
        celular: _celularController.text,
        contacto: _contactoController.text,
        direccion: _direccionController.text,
        id_zona: _selectedZona!,
        ip: _ipController.text,
        id_plan: _selectedPlan!,
        activacion: _activacionController.text,
        estado: _estadoController.text,
        comentario: _comentarioController.text,
        created_at: _selectedCliente?.created_at ?? DateTime.now(),
      );
      try {
        if (_selectedCliente == null) {
          await Provider.of<ClienteModel>(context, listen: false).addCliente(cliente);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cliente agregado con éxito')));
        } else {
          await Provider.of<ClienteModel>(context, listen: false).updateCliente(cliente);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cliente actualizado con éxito')));
        }
        _clearFields();
        _updateFilteredClientes();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al guardar el cliente: $e')));
      }
    }
  }

  Widget _buildClienteList(BuildContext context) {
    return Consumer<ClienteModel>(
      builder: (context, clienteModel, child) {
        if (_filteredClientes.isEmpty) {
          return const Center(child: Text("No hay clientes disponibles."));
        }
        return InteractiveViewer(
          constrained: false,
          child: DataTable(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('C.I.')),
            DataColumn(label: Text('Celular')),
            DataColumn(label: Text('Contacto')),
            DataColumn(label: Text('Direccion')),
            DataColumn(label: Text('Nombre_zona')),
            DataColumn(label: Text('Ip')),
            DataColumn(label: Text('Nombre_plan')),
            DataColumn(label: Text('activacion')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Comentario')),

          ],
            rows: _filteredClientes.map(
              (cliente) => DataRow(
                cells: [
                  DataCell(Text(cliente.nombre), onTap: () => _selectClienteForEditing(cliente)),
                  DataCell(Text(cliente.ci)),
                  DataCell(Text(cliente.celular)),
                  DataCell(Text(cliente.contacto)),
                  DataCell(Text(cliente.direccion)),
                  DataCell(Text(clienteModel.getZonaNombre(cliente.id_zona))),
                  DataCell(Text(cliente.ip)),
                  DataCell(Text(clienteModel.getPlanNombre(cliente.id_plan))),
                  DataCell(Text(cliente.activacion)),
                  DataCell(Text(cliente.estado)),
                  DataCell(Text(cliente.comentario)),
                ],
              ),
            ).toList(),
          )
        );
      },
    );
  }
}
