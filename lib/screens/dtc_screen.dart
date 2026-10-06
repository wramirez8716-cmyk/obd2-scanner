            child: const Text('Borrar', style: TextStyle(color: Colors.red)),
            ],
  }
                icon: const Icon(Icons.refresh),
import '../services/obd_service.dart';
  Future<void> _loadDTCs(BuildContext context) async {
          SnackBar(
          padding: const EdgeInsets.all(16),
  const DtcScreen({super.key});
                onPressed: dtcs.isEmpty ? null : () => _clearDTCs(context),
            onPressed: () => Navigator.pop(ctx, true),
        actions: [
                ),

              ElevatedButton.icon(
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
        content: const Text(
              cleared ? 'Codigos borrados exitosamente' : 'Error al borrar codigos',
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
          'Si borras sin reparar, la luz Check Engine volverá a encenderse.',
          child: Row(
          ),
            children: [
      children: [
    await obdService.readDTCs();
    final obdService = context.read<ObdService>();
                ),
        ),
              Expanded(
                  backgroundColor: Colors.blue[700],
        title: const Text('Advertencia'),
                child: const Text(
        ),
                label: const Text('Borrar'),
          child: dtcs.isEmpty
                style: ElevatedButton.styleFrom(
          'Solo debes borrarlos DESPUÉS de reparar la falla.\n'
                    mainAxisAlignment: MainAxisAlignment.center,
                icon: const Icon(Icons.delete),
                  backgroundColor: Colors.red[700],
        Expanded(
              ? Center(
                    children: [
                      Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay codigos de error',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dtcs.length,
                  itemBuilder: (context, index) {
                    final dtc = dtcs[index];
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
    final descriptions = {
      'P0300': 'Fallo de encendido aleatorio/multiple cilindro',
      'P0301': 'Fallo de encendido - Cilindro 1',
      'P0302': 'Fallo de encendido - Cilindro 2',
      'P0303': 'Fallo de encendido - Cilindro 3',
      'P0304': 'Fallo de encendido - Cilindro 4',
      'P0335': 'Malfuncion del sensor CKP',
      'P0336': 'Rango/rendimiento del sensor CKP',
      'P0385': 'Sensor CKP B - Malfuncion',
      'P0171': 'Sistema demasiado pobre (Banco 1)',
      'P0172': 'Sistema demasiado rico (Banco 1)',
      'P0420': 'Eficiencia del catalizador below threshold',
    };
    return descriptions[dtc] ?? 'Codigo de error no identificado';
  }
}
