import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/obd_service.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    try {
      final devices = await FlutterBluetoothSerial.instance
          .startDiscovery()
          .timeout(const Duration(seconds: 8))
          .map((result) => result.device)
          .toList();

      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escanear: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final obdService = context.read<ObdService>();
    final connected = await obdService.connectToDevice(device);

    if (connected && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo conectar al adaptador'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD2 Scanner Pro'),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header con estado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[900],
            child: Column(
              children: [
                const Icon(Icons.bluetooth, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                const Text(
                  'Conecta tu adaptador ELM327',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isScanning ? 'Buscando dispositivos...' : '${_devices.length} dispositivos encontrados',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Botón re-escanear
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isScanning ? null : _scanDevices,
              icon: _isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isScanning ? 'Escaneando...' : 'Buscar de nuevo'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue[700],
              ),
            ),
          ),

          // Lista de dispositivos
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bluetooth_disabled,
                            size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron dispositivos',
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Asegúrate de que el ELM327 esté encendido',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final isObd = device.name?.toUpperCase().contains('OBD') ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            isObd ? Icons.car_repair : Icons.bluetooth,
                            color: isObd ? Colors.green : Colors.blue,
                          ),
                          title: Text(
                            device.name ?? 'Dispositivo desconocido',
                            style: TextStyle(
                              fontWeight: isObd ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(device.address),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _connectToDevice(device),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
