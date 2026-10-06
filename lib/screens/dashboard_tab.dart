              crossAxisCount: 2,
            begin: Alignment.topLeft,

  Widget build(BuildContext context) {
class DashboardTab extends StatelessWidget {
          ),
              style: const TextStyle(
  }
import '../models/obd_pid.dart';
            ),
import 'package:provider/provider.dart';
                  style: const TextStyle(

            shrinkWrap: true,
      padding: const EdgeInsets.all(16),
                fontSize: 12,
              return _buildSensorCard(pid, value, history);
                Text(
        ),
              ),
                Text(
      child: Container(
            itemBuilder: (context, index) {
            Text(
import 'package:flutter/material.dart';
              childAspectRatio: 1.3,
            end: Alignment.bottomRight,
  Widget _buildSensorCard(ObdPid pid, double? value, List<dynamic> history) {
    final obdService = context.watch<ObdService>();
  const DashboardTab({super.key});

            const Spacer(),
import 'package:fl_chart/fl_chart.dart';
  @override
            physics: const NeverScrollableScrollPhysics(),
            },
                  pid.unit,
            ),
        decoration: BoxDecoration(
              final pid = ObdPids.dashboard[index];
              pid.description ?? '',
              crossAxisSpacing: 12,
            colors: [Colors.blue[800]!, Colors.blue[600]!],
    return Card(
            Row(
import '../services/obd_service.dart';
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
          borderRadius: BorderRadius.circular(16),
              final value = obdService.pidValues[pid.name];
              mainAxisSpacing: 12,
      elevation: 4,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
          gradient: LinearGradient(
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
                      ),],
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
