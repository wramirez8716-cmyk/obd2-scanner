import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/obd_service.dart';
import 'dashboard_tab.dart';
import 'ckp_monitor_tab.dart';
import 'oxygen_sensors_tab.dart';
import 'dtc_screen.dart';

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
