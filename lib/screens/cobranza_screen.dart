import 'package:flutter/material.dart';
import 'package:newtel_app/providers/plan_provider.dart';
import 'package:provider/provider.dart';
import '../models/crud_cliente.dart';
import '../providers/cliente_provider.dart';

class CobranzaScreen extends StatefulWidget {
  @override
  State<CobranzaScreen> createState() => _CobranzaScreenState();
}

class _CobranzaScreenState extends State<CobranzaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  List<Cliente> _filteredClientes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Cobranza'),
      ),
      body:Container(
        padding: const EdgeInsets.all(20), 
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Form(
                key: _formKey,
                child:  Wrap(
                  spacing: 5.0,
                  runSpacing: 5.0,
                  children: <Widget>[
                    Container(
                       // Ajusta el ancho de los TextFormFields
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Codigo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Celular',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Zona',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Plan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _buildClienteList(context),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Wrap(
                spacing: 5.0,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => {},
                    child: const Text('Limpiar'),
                  ),
                  ElevatedButton(
                    onPressed: () => {},
                    child: const Text('Registrar Pago'),
                  ),
                  ElevatedButton(
                    onPressed: () => {},
                    child: const Text('Reenviar'),
                  ),
                  ElevatedButton(
                    onPressed: () => {},
                    child: const Text('Pendientes'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildClientesList(context),
            ),
          ],
        ),
      ),
    );
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
              DataColumn(label: Text('CI/COD')),
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Celular')),
              DataColumn(label: Text('Direccion')),
              DataColumn(label: Text('Activacion')),
              DataColumn(label: Text('Plan Actual')),
              DataColumn(label: Text('IP')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Comentario')),

            ],
            rows: _filteredClientes.map(
              (cliente) => DataRow(
                cells: [
                  DataCell(Text(clienteModel.getZonaNombre(cliente.id_zona))),
                  DataCell(Text(cliente.nombre)), 
                  DataCell(Text(cliente.celular)),
                  DataCell(Text(cliente.direccion)),
                  DataCell(Text(cliente.activacion)),
                  DataCell(Text(clienteModel.getPlanNombre(cliente.id_plan))),
                  DataCell(Text(cliente.ip)),
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
  Widget _buildClientesList(BuildContext context) {
    return Consumer<PlanModel>(
      builder: (context, clienteModel, child) {
        if (_filteredClientes.isEmpty) {
          return const Center(child: Text("No hay planes disponibles."));
        }
        return InteractiveViewer(
          constrained: false,
            child: DataTable(
            columns: const [
              DataColumn(label: Text('Id Plan')),
              DataColumn(label: Text('Plan')),
              DataColumn(label: Text('Costo')),
              DataColumn(label: Text('Mes')),
              DataColumn(label: Text('Fecha de Pago')),
              DataColumn(label: Text('Modalidad')),
              DataColumn(label: Text('Accion')),
            ],
            rows: _filteredClientes.map(
              (cliente) => DataRow(
                cells: [
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                ],
              ),
            ).toList(),
          )
        );
      },
    );
  }
}