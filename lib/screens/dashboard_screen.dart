import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/obd_service.dart';
import '../models/obd_pid.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD2 Scanner Pro'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<ObdService>().disconnect();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardTab(),
          CkpMonitorTab(),
          OxygenSensorsTab(),
          DtcScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: 'CKP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.air),
            label: 'O2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'DTC',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 1: DASHBOARD PRINCIPAL
// ═══════════════════════════════════════════════════════════════
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final obdService = context.watch<ObdService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sensores en Tiempo Real',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: ObdPids.dashboard.length,
            itemBuilder: (context, index) {
              final pid = ObdPids.dashboard[index];
              final value = obdService.pidValues[pid.name];
              final history = obdService.pidHistory[pid.name] ?? [];

              return _buildSensorCard(pid, value, history);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(ObdPid pid, double? value, List<dynamic> history) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[800]!, Colors.blue[600]!],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pid.name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pid.description ?? '',
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? _formatValue(value) : '---',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  pid.unit,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            if (history.isNotEmpty)
              SizedBox(
                height: 40,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: history.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.value);
                        }).toList(),
                        isCurved: true,
                        color: Colors.greenAccent,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 2: MONITOR CKP (Sensor de Cigüeñal)
// ═══════════════════════════════════════════════════════════════
class CkpMonitorTab extends StatelessWidget {
  const CkpMonitorTab({super.key});

  @override
  Widget build(BuildContext context) {
    final obdService = context.watch<ObdService>();
    final rpmHistory = obdService.rpmHistory;
    final stability = obdService.rpmStability;
    final missingPulses = obdService.missingPulses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monitor Sensor CKP',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Estabilidad de RPM y detección de pulsos perdidos',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Indicador de estabilidad
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Estabilidad del Sensor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: CircularProgressIndicator(
                          value: stability / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            stability > 90 ? Colors.green :
                            stability > 70 ? Colors.orange : Colors.red,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${stability.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            stability > 90 ? 'ÓPTIMO' :
                            stability > 70 ? 'REGULAR' : 'DEFICIENTE',
                            style: TextStyle(
                              color: stability > 90 ? Colors.green :
                                   stability > 70 ? Colors.orange : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pulsos perdidos
          Card(
            color: missingPulses > 0 ? Colors.red[50] : Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    missingPulses > 0 ? Icons.warning : Icons.check_circle,
                    color: missingPulses > 0 ? Colors.red : Colors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pulsos Perdidos Detectados',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$missingPulses eventos',
                          style: TextStyle(
                            color: missingPulses > 0 ? Colors.red : Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gráfica de RPM
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RPM en Tiempo Real',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: rpmHistory.isEmpty
                        ? const Center(child: Text('Esperando datos...'))
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: rpmHistory.asMap().entries.map((e) {
                                    return FlSpot(e.key.toDouble(), e.value);
                                  }).toList(),
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 3: SENSORES DE OXÍGENO
// ═══════════════════════════════════════════════════════════════
class OxygenSensorsTab extends StatelessWidget {
  const OxygenSensorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final obdService = context.watch<ObdService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sensores de Oxígeno (O2)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monitoreo de consumo de combustible',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          ...ObdPids.oxygenSensors.map((pid) {
            final value = obdService.pidValues[pid.name];
            final history = obdService.pidHistory[pid.name] ?? [];
            final isHealthy = value != null && value > 0.3 && value < 0.9;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pid.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                pid.description ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isHealthy ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isHealthy ? 'NORMAL' : 'REVISAR',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Voltaje:',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          value != null ? '${value.toStringAsFixed(3)} V' : '---',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: history.isEmpty
                          ? const Center(child: Text('Esperando datos...'))
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: history.asMap().entries.map((e) {
                                      return FlSpot(
                                        e.key.toDouble(),
                                        e.value.value,
                                      );
                                    }).toList(),
                                    isCurved: true,
                                    color: Colors.orange,
                                    barWidth: 3,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.orange.withOpacity(0.2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Indicador de consumo
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.fuel, color: Colors.blue),
   SizedBox(width: 8),
    );
class DtcScreen extends StatelessWidget {
                        'Consumo de Combustible',
            ),
                    '• Valor alto (>0.9V): Mezcla rica (consume más)\n'
            );
                    ],
            color: Colors.blue[50],
                  ],
                    'Si los sensores O2 oscilan entre 0.3V y 0.9V constantemente,\n'
                  const SizedBox(height: 12),
                ],
                    style: TextStyle(fontSize: 12),
                    ),
                      Icon(Icons.fuel, color: Colors.blue),

// ═══════════════════════════════════════════════════════════════
// TAB 4: CÓDIGOS DTC
                          fontWeight: FontWeight.bold,

                          fontSize: 16,
                            ),
          Card(
}
                              ),
                  const Row(
          // Indicador de consumo
              padding: const EdgeInsets.all(16),
                      ),
  }
                    '• Valor bajo (<0.3V): Mezcla pobre (problema de inyectores)',
                  ),
            child: Padding(
                    'el consumo de combustible es NORMAL.\n\n'
                  const Text(
                        ),
  Future<void> _loadDTCs(BuildContext context) async {
                    children: [
              child: Column(
                    'Si permanecen fijos en un valor, puede indicar:\n'
    final obdService = context.read<ObdService>();
                crossAxisAlignment: CrossAxisAlignment.start,
    await obdService.readDTCs();
                children: [
  }

  Future<void> _clearDTCs(BuildContext context) async {
    final obdService = context.read<ObdService>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Advertencia'),
        content: const Text(
          '¿Estás seguro de borrar los códigos de error?\n\n'
          'Solo debes borrarlos DESPUÉS de reparar la falla.\n'
          'Si borras sin reparar, la luz Check Engine volverá a encenderse.',
        ),actions: [
                label: const Text('Leer'),
        ScaffoldMessenger.of(context).showSnackBar(
  @override
          ),
        ),
                        leading: const Icon(Icons.error, color: Colors.red),
                    final dtc = dtcs[index];
            ],

                        style: TextStyle(fontSize: 18, color: Colors.grey),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            onPressed: () => Navigator.pop(ctx, false),
            content: Text(
              ),
  }
      }
                  backgroundColor: Colors.blue[700],
            ),
          '¿Estás seguro de borrar los códigos de error?\n\n'
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
    final descriptions = {
      'P0300': 'Fallo de encendido aleatorio/múltiple cilindro',
      'P0301': 'Fallo de encendido - Cilindro 1',
      'P0302': 'Fallo de encendido - Cilindro 2',
      'P0303': 'Fallo de encendido - Cilindro 3',
      'P0304': 'Fallo de encendido - Cilindro 4',
      'P0335': 'Malfunción del sensor CKP',
      'P0336': 'Rango/rendimiento del sensor CKP',
      'P0385': 'Sensor CKP B - Malfunción',
      'P0171': 'Sistema demasiado pobre (Banco 1)',
      'P0172': 'Sistema demasiado rico (Banco 1)',
      'P0420': 'Eficiencia del catalizador below threshold',
    };
    return descriptions[dtc] ?? 'Código de error no identificado';
  }
}
