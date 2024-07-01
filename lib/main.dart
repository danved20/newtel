import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/cliente_provider.dart';
import '../providers/plan_provider.dart';
import '../providers/zona_provider.dart';
import '../screens/clientes_screen.dart';
import '../providers/lienea_provider.dart';
import '../screens/cobranza_screen.dart';
import '../screens/actividades_screen.dart';
import '../screens/planes_screen.dart';
import '../screens/zonas_screen.dart';
import '../screens/lineas_screen.dart';
import '../screens/reportes_screen.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlanModel()),
        ChangeNotifierProvider(create: (context) => LineaModel()),
        ChangeNotifierProvider(create: (context) => ZonaModel()),
        ChangeNotifierProvider(create: (context) => ClienteModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Newtel App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int clienteCount = 0;
  int activoCliente = 0;
  int inactivoCliente = 0;
  int zonaCount = 0;
  int planCount = 0;
  int lineCount = 0;
  double totalMonto = 0;
  double ingreso = 0;
  double egreso = 0;
  double beneficio = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final clientsResponse = await http.get(Uri.parse('http://192.168.251.136:800/api/clientes'));
    final zonesResponse = await http.get(Uri.parse('http://192.168.251.136:800/api/zonas'));
    final plansResponse = await http.get(Uri.parse('http://192.168.251.136:800/api/planes'));
    final linesResponse = await http.get(Uri.parse('http://192.168.251.136:800/api/lineas'));

    if (clientsResponse.statusCode == 200 &&
        zonesResponse.statusCode == 200 &&
        plansResponse.statusCode == 200 &&
        linesResponse.statusCode == 200) {
      final clients = json.decode(clientsResponse.body);
      final zones = json.decode(zonesResponse.body);
      final plans = json.decode(plansResponse.body);
      final lines = json.decode(linesResponse.body);

      //double totalExpenses = 0;
      double totalIncome = 0;
      int active = 0;
      int inactive = 0;

      Map<int, double> planAmounts = {};
      for (var plan in plans) {
        planAmounts[plan['id']]  = double.tryParse(plan['costo']) ?? 0.0;
      }

      for (var client in clients) {
        if (client['estado'] == 'activo') {
          active++;
        } else {
          inactive++;
        }
        double planAmount = planAmounts[client['id_plan']] ?? 0;
        totalIncome = planAmount;
        
        /* for (var line in lines) {
          if (line['id'] == client['lineId']) {
            totalExpenses += line['amount'];
            break;
          }
        } */
      }

      setState(() {
        clienteCount = clients.length;
        activoCliente = active;
        inactivoCliente = inactive;
        zonaCount = zones.length;
        planCount = plans.length;
        lineCount = lines.length;
        totalMonto = lines.fold(0, (sum, line) => sum + (line['precio']));
        ingreso = totalIncome;
        
        beneficio = ingreso - totalMonto;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Newtel App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Newtel App', style: TextStyle(color: Colors.white, fontSize: 24)),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Clientes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.money),
              title: Text('Cobranza'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CobranzaScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.work),
              title: Text('Actividades'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActividadesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text('Planes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlanesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Zonas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ZonasScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Líneas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LineasScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Reportes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportesScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          children: [
            InfoCard(
              title: 'Clientes',
              value: clienteCount.toString(),
              details: 'ACTIVOS: $activoCliente\nINACTIVOS: $inactivoCliente',
              backgroundColor: Colors.yellow.shade100,
            ),
            InfoCard(
              title: 'Zonas',
              value: zonaCount.toString(),
              backgroundColor: Colors.cyan.shade100,
            ),
            InfoCard(
              title: 'Planes',
              value: planCount.toString(),
              backgroundColor: Colors.orange.shade100,
            ),
            InfoCard(
              title: 'Líneas',
              value: lineCount.toString(),
              details: 'MONTO Bs: $totalMonto',
              backgroundColor: Colors.purple.shade100,
            ),
            InfoCard(
              title: 'Flujo de Caja',
              value: '',
              details: 'I: $ingreso\nE: $totalMonto\nU: $beneficio',
              backgroundColor: Colors.green.shade100,
              valueStyle: TextStyle(fontSize: 0), // Hide the value text
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String details;
  final Color backgroundColor;
  final TextStyle? valueStyle;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    this.details = '',
    required this.backgroundColor,
    this.valueStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 36.0,
                ),
          ),
          if (details.isNotEmpty) ...[
            SizedBox(height: 8.0),
            Text(
              details,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}