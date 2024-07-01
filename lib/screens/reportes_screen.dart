import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import '../providers/cliente_provider.dart';
import '../providers/lienea_provider.dart';
import '../providers/zona_provider.dart';
import '../providers/plan_provider.dart';

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedReportType = 'Clientes';

  @override
  Widget build(BuildContext context) {
    var dataButtons = ['Clientes', 'Zonas', 'Líneas', 'Planes'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              children: dataButtons.map((type) => ChoiceChip(
                label: Text(type, style: const TextStyle(color: Colors.white)),
                selected: _selectedReportType == type,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedReportType = type;
                    });
                  }
                },
                backgroundColor: Colors.grey,
                selectedColor: Colors.blue,
              )).toList(),
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => _selectStartDate(context),
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: Text(
                _startDate == null
                    ? 'Seleccionar Fecha de Inicio'
                    : 'Inicio: ${_startDate!.toLocal()}'.split('   ')[0],
                style: const TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _selectEndDate(context),
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: Text(
                _endDate == null
                    ? 'Seleccionar Fecha de Fin'
                    : 'Fin: ${_endDate!.toLocal()}'.split('   ')[0],
                style: const TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: (_startDate == null || _endDate == null)
                  ? null
                  : () => _generatePdf(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: Text('Generar PDF de $_selectedReportType'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    switch (_selectedReportType) {
      case 'Clientes':
        await _generateClientesReport(context, pdf);
        break;
      case 'Zonas':
        await _generateZonasReport(context, pdf);
        break;
      case 'Líneas':
        await _generateLineasReport(context, pdf);
        break;
      case 'Planes':
        await _generatePlanesReport(context, pdf);
        break;
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _generateClientesReport(BuildContext context, pw.Document pdf) async {
    final clienteModel = Provider.of<ClienteModel>(context, listen: false);
    await clienteModel.loadClientes();

    final filteredClientes = clienteModel.clientes
        .where((cliente) =>
            cliente.created_at.isAfter(_startDate!) &&
            cliente.created_at.isBefore(_endDate!.add(const Duration(days: 1))))
        .toList();

    if (filteredClientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay clientes en el rango de fechas seleccionado')),
      );
      return;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Reporte de Clientes', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>[
                  'CI',
                  'Nombre',
                  'Celular',
                  'Contacto',
                  'Dirección',
                  'Zona',
                  'IP',
                  'Plan',
                  'Activación',
                  'Estado',
                  'Comentario',
                  'Creado'
                ],
                ...filteredClientes.map((cliente) => [
                      cliente.ci,
                      cliente.nombre,
                      cliente.celular,
                      cliente.contacto,
                      cliente.direccion,
                      clienteModel.getZonaNombre(cliente.id_zona),
                      cliente.ip,
                      clienteModel.getPlanNombre(cliente.id_plan),
                      cliente.activacion,
                      cliente.estado,
                      cliente.comentario,
                      cliente.created_at.toIso8601String()
                    ])
              ],
            ),
          ];
        },
      ),
    );
  }

  Future<void> _generateZonasReport(BuildContext context, pw.Document pdf) async {
    final zonaModel = Provider.of<ZonaModel>(context, listen: false);
    await zonaModel.loadZonas();

    final filteredZonas = zonaModel.zonas
        .where((zona) =>
            zona.created_at.isAfter(_startDate!) &&
            zona.created_at.isBefore(_endDate!.add(const Duration(days: 1))))
        .toList();

    if (filteredZonas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay zonas en el rango de fechas seleccionado')),
      );
      return;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Reporte de Zonas', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['ID', 'Nombre', 'Comentario', 'Id_Linea', 'Creado'],
                ...filteredZonas.map((zona) => [
                      zona.id.toString(),
                      zona.nombre,
                      zona.comentario,
                      zonaModel.getLineaNombre(zona.id_linea),
                      zona.created_at.toIso8601String()
                    ])
              ],
            ),
          ];
        },
      ),
    );
  }

  Future<void> _generateLineasReport(BuildContext context, pw.Document pdf) async {
    final lineaModel = Provider.of<LineaModel>(context, listen: false);
    await lineaModel.loadLineas();

    final filteredLineas = lineaModel.lineas
        .where((linea) =>
            linea.created_at.isAfter(_startDate!) &&
            linea.created_at.isBefore(_endDate!.add(const Duration(days: 1))))
        .toList();

    if (filteredLineas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay líneas en el rango de fechas seleccionado')),
      );
      return;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Reporte de Líneas', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>[
                  'ID',
                  'Nombre',
                  'Proveedor',
                  'Velocidad',
                  'Precio',
                  'Tipo',
                  'Titular',
                  'Celular',
                  'Comentario',
                  'Dirección',
                  'Encargado',
                  'Creado'
                ],
                ...filteredLineas.map((linea) => [
                      linea.id.toString(),
                      linea.nombre,
                      linea.proveedor,
                      linea.velocidad,
                      linea.precio.toString(),
                      linea.tipo,
                      linea.titular,
                      linea.celular,
                      linea.comentario,
                      linea.direccion,
                      linea.encargado,
                      linea.created_at.toIso8601String()
                    ])
              ],
            ),
          ];
        },
      ),
    );
  }

  Future<void> _generatePlanesReport(BuildContext context, pw.Document pdf) async {
    final planModel = Provider.of<PlanModel>(context, listen: false);
    await planModel.loadPlans();

    final filteredPlanes = planModel.plans
        .where((plan) =>
            plan.created_at.isAfter(_startDate!) &&
            plan.created_at.isBefore(_endDate!.add(const Duration(days: 1))))
        .toList();

    if (filteredPlanes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay planes en el rango de fechas seleccionado')),
      );
      return;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Reporte de Planes', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['ID', 'Nombre', 'Descripción', 'Precio', 'Creado'],
                ...filteredPlanes.map((plan) => [
                      plan.id.toString(),
                      plan.name,
                      plan.comentario,
                      plan.costo.toString(),
                      plan.created_at.toIso8601String()
                    ])
              ],
            ),
          ];
        },
      ),
    );
  }
}
