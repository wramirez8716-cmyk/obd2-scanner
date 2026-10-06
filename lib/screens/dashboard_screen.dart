import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/obd_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ObdService>().startPolling();
    });
  }

  @override
  void dispose() {
    context.read<ObdService>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final obdService = context.watch<ObdService>();
    final values = obdService.pidValues;
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD2 Scanner Pro'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              obdService.disconnect();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _buildTab(values, obdService),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_heart), label: 'CKP'),
          BottomNavigationBarItem(icon: Icon(Icons.air), label: 'O2'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'DTC'),
        ],
      ),
    );
  }

  Widget _buildTab(Map<String, double> values, ObdService service) {
    switch (_currentIndex) {
      case 0: return _buildDashboard(values);
      case 1: return _buildCkp(service);
      case 2: return _buildO2(values);
      case 3: return _buildDtc(service);
      default: return const SizedBox();
    }
  }

  Widget _buildDashboard(Map<String, double> values) {
    final sensors = [
      {'name': 'RPM', 'value': values['RPM'], 'unit': 'rpm', 'icon': Icons.speed},
      {'name': 'Velocidad', 'value': values['Velocidad'], 'unit': 'km/h', 'icon': Icons.directions_car},
      {'name': 'Temp. Motor', 'value': values['Temp. Motor'], 'unit': 'C', 'icon': Icons.thermostat},
      {'name': 'MAF', 'value': values['MAF'], 'unit': 'g/s', 'icon': Icons.wind_power},
      {'name': 'TPS', 'value': values['TPS'], 'unit': '%', 'icon': Icons.gas_meter},
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sensores en Tiempo Real', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          ...sensors.map((s) => Card(
            color: Colors.blue[800],
            child: ListTile(
              leading: Icon(s['icon'] as IconData, color: Colors.white, size: 32),
              title: Text(s['name'] as String, style: const TextStyle(color: Colors.white70)),
              trailing: Text(
                s['value'] != null ? '${(s['value'] as double).toStringAsFixed(1)} ${s['unit']}' : '---',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCkp(ObdService service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Monitor Sensor CKP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Card(
            color: Colors.blue[800],
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Estabilidad del Sensor', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 16),
                  Text(
                    '${service.rpmStability.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: service.rpmStability > 90 ? Colors.green : Colors.orange),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.rpmStability > 90 ? 'OPTIMO' : service.rpmStability > 70 ? 'REGULAR' : 'DEFICIENTE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: service.rpmStability > 90 ? Colors.green : Colors.orange),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: service.missingPulses > 0 ? Colors.red[800] : Colors.green[800],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(service.missingPulses > 0 ? Icons.warning : Icons.check_circle, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  const Text('Pulsos Perdidos:', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const Spacer(),
                  Text('${service.missingPulses}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildO2(Map<String, double> values) {
    final o2Sensors = [
      {'name': 'O2 Banco 1 Sensor 1', 'value': values['O2 Banco 1 Sensor 1']},
      {'name': 'O2 Banco 1 Sensor 2', 'value': values['O2 Banco 1 Sensor 2']},
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sensores de Oxigeno (O2)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          ...o2Sensors.map((s) {
            final v = s['value'] as double?;
            final healthy = v != null && v > 0.3 && v < 0.9;
            return Card(
              color: Colors.blue[800],
              child: ListTile(
                title: Text(s['name'] as String, style: const TextStyle(color: Colors.white)),
                subtitle: Text('Voltaje: ${v != null ? '${v.toStringAsFixed(3)} V' : '---'}', style: const TextStyle(color: Colors.white70)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: healthy ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(20)),
                  child: Text(healthy ? 'NORMAL' : 'REVISAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue[900],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Si los sensores O2 oscilan entre 0.3V y 0.9V, el consumo es NORMAL.\n\nValor alto (>0.9V): Mezcla rica\nValor bajo (<0.3V): Mezcla pobre',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDtc(ObdService service) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(child: Text('Codigos de Error (DTC)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
              ElevatedButton.icon(
                onPressed: () => service.readDTCs(),
                icon: const Icon(Icons.refresh),
                label: const Text('Leer'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: service.dtcs.isEmpty ? null : () => service.clearDTCs(),
                icon: const Icon(Icons.delete),
                label: const Text('Borrar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              ),
            ],
          ),
        ),
        Expanded(
          child: service.dtcs.isEmpty
              ? const Center(child: Text('No hay codigos de error', style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: service.dtcs.length,
                  itemBuilder: (context, index) {
                    final dtc = service.dtcs[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.error, color: Colors.red),
                        title: Text(dtc, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(_getDtcDescription(dtc)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _getDtcDescription(String dtc) {
    final d = {
      'P0300': 'Fallo de encendido aleatorio',
      'P0301': 'Fallo encendido - Cilindro 1',
      'P0302': 'Fallo encendido - Cilindro 2',
      'P0303': 'Fallo encendido - Cilindro 3',
      'P0304': 'Fallo encendido - Cilindro 4',
      'P0335': 'Malfuncion sensor CKP',
      'P0336': 'Rango/rendimiento sensor CKP',
      'P0385': 'Sensor CKP B - Malfuncion',
      'P0171': 'Sistema demasiado pobre (Banco 1)',
      'P0172': 'Sistema demasiado rico (Banco 1)',
      'P0420': 'Eficiencia catalizador baja',
    };
    return d[dtc] ?? 'Codigo no identificado';
  }
}
