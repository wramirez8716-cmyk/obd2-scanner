    final rpmHistory = obdService.rpmHistory;
                            ),
                              fontSize: 32,
              child: Column(
            child: Padding(
      child: Column(
                            stability > 90 ? 'OPTIMO' :
                  const Text(
          Card(
                    ],
                        width: 150,
                      Column(
import '../services/obd_service.dart';
            style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
                  Stack(
                    children: [
          ),
          const Text(
  const CkpMonitorTab({super.key});
                            '${stability.toStringAsFixed(1)}%',
                          ),
  @override
import 'package:provider/provider.dart';
                        ),
          ),
                  ),
                children: [
    final stability = obdService.rpmStability;
                    'Estabilidad del Sensor',
                  ),
                        children: [

                        ],
  Widget build(BuildContext context) {
                  Icon(
    final missingPulses = obdService.missingPulses;
    final obdService = context.watch<ObdService>();
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
                  ),],
            ),
                      Column(
                              ),
                        ),
              ),
                              titlesData: FlTitlesData(
          ),
                            '${stability.toStringAsFixed(1)}%',
                          ),
                        ),
                                  sideTitles: SideTitles(showTitles: true),
                  SizedBox(
                  ),
                        children: [
                              borderData: FlBorderData(show: true),
                        ],
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
