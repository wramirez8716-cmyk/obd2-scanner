import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/obd_service.dart';
import '../models/obd_pid.dart';

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
            'Sensores de Oxigeno (O2)',
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

          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_gas_station, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Consumo de Combustible',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Si los sensores O2 oscilan entre 0.3V y 0.9V constantemente, el consumo de combustible es NORMAL.\n\n'
                    'Si permanecen fijos en un valor, puede indicar:\n'
                    '• Valor alto (>0.9V): Mezcla rica (consume mas)\n'
                    '• Valor bajo (<0.3V): Mezcla pobre (problema de inyectores)',
                    style: TextStyle(fontSize: 12),
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
