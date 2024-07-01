import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/crud_plan.dart';
import '../providers/plan_provider.dart';

class PlanesScreen extends StatefulWidget {
  const PlanesScreen({super.key});

  @override
  _PlanesScreenState createState() => _PlanesScreenState();
}

class _PlanesScreenState extends State<PlanesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Plan? _selectedPlan;
  List<Plan> _filteredPlans = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    _searchController.addListener(_filterPlans);
  }

  Future<void> _loadInitialData() async {
    final planModel = Provider.of<PlanModel>(context, listen: false);
    await planModel.loadPlans();
    _updateFilteredPlans();
  }

  void _filterPlans() {
    _updateFilteredPlans();
  }

  void _updateFilteredPlans() {
    final planModel = Provider.of<PlanModel>(context, listen: false);
    setState(() {
      _filteredPlans = planModel.plans
          .where((plan) => plan.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _costoController.dispose();
    _comentarioController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Planes'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(color: Colors.blue[800]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[700]!, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[900]!, width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _costoController,
                      decoration: InputDecoration(
                        labelText: 'Costo',
                        labelStyle: TextStyle(color: Colors.blue[800]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[700]!, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[900]!, width: 2.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un costo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _comentarioController,
                      decoration: InputDecoration(
                        labelText: 'Comentario',
                        labelStyle: TextStyle(color: Colors.blue[800]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[700]!, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[900]!, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar plan',
                        prefixIcon: const Icon(Icons.search, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      onChanged: (value) => _filterPlans(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          onPressed: _clearFields,
                          child: const Text('Limpiar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          onPressed: () => _saveOrUpdatePlan(context),
                          child: Text(
                              _selectedPlan == null ? 'Guardar' : 'Actualizar'),
                        ),
                        if (_selectedPlan != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => _deletePlan(context),
                            child: const Text('Eliminar'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _buildPlanList(context),
            ),
          ],
        ),
      ),
    );
  }

  void _clearFields() {
    _formKey.currentState!.reset();
    _nombreController.clear();
    _costoController.clear();
    _comentarioController.clear();
    setState(() {
      _selectedPlan = null;
    });
    _updateFilteredPlans();
  }

  Future<void> _deletePlan(BuildContext context) async {
    if (_selectedPlan != null && _selectedPlan!.id != null) {
      await Provider.of<PlanModel>(context, listen: false)
          .deletePlan(_selectedPlan!.id!);
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan eliminado con éxito')));
      _updateFilteredPlans();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el plan')));
    }
  }

  void _selectPlanForEditing(Plan plan) {
    setState(() {
      _selectedPlan = plan;
      _nombreController.text = plan.name;
      _costoController.text = plan.costo.toString();
      _comentarioController.text = plan.comentario;
    });
  }

  Future<void> _saveOrUpdatePlan(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final plan = Plan(
        id: _selectedPlan?.id, // Usar el ID existente si es una edición
        name: _nombreController.text,
        costo: double.tryParse(_costoController.text) ?? 0,
        comentario: _comentarioController.text, 
        created_at: DateTime.timestamp(),
      );
      try {
        if (_selectedPlan == null) {
          await Provider.of<PlanModel>(context, listen: false).addPlan(plan);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plan agregado con éxito')));
        } else {
          await Provider.of<PlanModel>(context, listen: false).updatePlan(plan);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plan actualizado con éxito')));
        }
        _clearFields();
        _updateFilteredPlans();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al guardar el plan: $e')));
      }
    }
  }

  Widget _buildPlanList(BuildContext context) {
    return Consumer<PlanModel>(
      builder: (context, planModel, child) {
        if (_filteredPlans.isEmpty) {
          return const Center(child: Text("No hay planes disponibles."));
        }
        return InteractiveViewer(
          constrained: false,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Costo')),
              DataColumn(label: Text('Comentario')),
            ],
            rows: _filteredPlans
              .map((plan) => DataRow(
                    cells: [
                      DataCell(Text(plan.name),
                          onTap: () => _selectPlanForEditing(plan)),
                      DataCell(Text(plan.costo.toString()),
                          onTap: () => _selectPlanForEditing(plan)),
                      DataCell(Text(plan.comentario),
                          onTap: () => _selectPlanForEditing(plan)),
                    ],
                  ))
              .toList(),
          ),
        );
      },
    );
  }
}
