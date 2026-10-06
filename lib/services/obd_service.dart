import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/obd_pid.dart';
import 'bluetooth_service.dart';

class SensorReading {
  final double value;
  final DateTime timestamp;
  SensorReading(this.value, this.timestamp);
}

class ObdService extends ChangeNotifier {
  final BluetoothService _btService = BluetoothService();
  final Map<String, double> _pidValues = {};
  final Map<String, List<SensorReading>> _pidHistory = {};
  Timer? _pollingTimer;
  bool _isPolling = false;
  String _connectionStatus = 'Desconectado';
  List<String> _dtcs = [];
  double _rpmStability = 100.0;
  List<double> _rpmHistory = [];
  int _missingPulses = 0;

  Map<String, double> get pidValues => _pidValues;
  Map<String, List<SensorReading>> get pidHistory => _pidHistory;
  bool get isPolling => _isPolling;
  String get connectionStatus => _connectionStatus;
  List<String> get dtcs => _dtcs;
  double get rpmStability => _rpmStability;
  List<double> get rpmHistory => _rpmHistory;
  int get missingPulses => _missingPulses;
  BluetoothService get btService => _btService;

  Future<bool> connectToDevice(dynamic device) async {
    _connectionStatus = 'Conectando...';
    notifyListeners();

    final connected = await _btService.connect(device);
    if (connected) {
      _connectionStatus = 'Conectado';
    } else {
      _connectionStatus = 'Error de conexión';
    }
    notifyListeners();
    return connected;
  }

  Future<double?> queryPid(ObdPid pid) async {
    final command = '${pid.mode}${pid.pid}';
    final response = await _btService.sendCommand(command);
    final parsed = _parseResponse(response, pid);
    if (parsed != null) {
      _pidValues[pid.name] = parsed;

      // Guardar histórico para gráficas
      if (!_pidHistory.containsKey(pid.name)) {
        _pidHistory[pid.name] = [];
      }
      _pidHistory[pid.name]!.add(
        SensorReading(parsed, DateTime.now()),
      );

      // Mantener solo últimos 60 puntos para las gráficas
      if (_pidHistory[pid.name]!.length > 60) {
        _pidHistory[pid.name]!.removeAt(0);
      }

      // Monitor de estabilidad de RPM (sensor CKP)
      if (pid.name == 'RPM') {
        _updateRpmStability(parsed);
      }

      notifyListeners();
    }
    return parsed;
  }

  void _updateRpmStability(double currentRpm) {
    _rpmHistory.add(currentRpm);
    if (_rpmHistory.length > 20) {
      _rpmHistory.removeAt(0);
    }

    if (_rpmHistory.length >= 5) {
      double avg = _rpmHistory.reduce((a, b) => a + b) / _rpmHistory.length;
      double maxDeviation = 0;
      for (double rpm in _rpmHistory) {
        double deviation = ((rpm - avg) / avg).abs();
        if (deviation > maxDeviation) maxDeviation = deviation;
      }

      _rpmStability = (100 - (maxDeviation * 100)).clamp(0, 100);

      // Detectar pulsos perdidos (variación mayor al 15%)
      if (maxDeviation > 0.15) {
        _missingPulses++;
      }
    }
  }

  double? _parseResponse(String response, ObdPid pid) {
    try {
      String clean = response
          .replaceAll(RegExp(r'\s+'), '')
          .replaceAll('SEARCHING...', '')
          .trim();

      if (clean.isEmpty || clean.contains('NODATA') ||
          clean.contains('ERROR') || clean.contains('UNABLE')) {
        return null;
      }
      if (!clean.startsWith('41')) return null;

      final expectedPrefix = '41${pid.pid}';
      if (!clean.toUpperCase().startsWith(expectedPrefix.toUpperCase())) {
        return null;
      }

      final dataHex = clean.substring(expectedPrefix.length);
      final bytes = <int>[];
      for (int i = 0; i < dataHex.length; i += 2) {
        if (i + 1 < dataHex.length) {
          bytes.add(int.parse(dataHex.substring(i, i + 2), radix: 16));
        }
      }

      if (bytes.isEmpty) return null;
      return pid.parser(bytes);
    } catch (e) {
      debugPrint('Error parseando: $e');
      return null;
    }
  }

  Future<List<String>> readDTCs() async {
    final response = await _btService.sendCommand('03');
    _dtcs = _parseDTCs(response);
    notifyListeners();
    return _dtcs;
  }

  Future<bool> clearDTCs() async {
    final response = await _btService.sendCommand('04');
    final cleared = response.contains('44');
    if (cleared) {
      _dtcs.clear();
      notifyListeners();
    }
    return cleared;
  }

  List<String> _parseDTCs(String response) {
    final dtcs = <String>[];
    String clean = response.replaceAll(RegExp(r'\s+'), '').trim();

    if (clean.startsWith('43')) {
      clean = clean.substring(2);
      final dtcPrefixes = ['P', 'C', 'B', 'U'];

      for (int i = 0; i < clean.length - 3; i += 4) {
        if (i + 4 <= clean.length) {
          final chunk = clean.substring(i, i + 4);
          final firstDigit = int.tryParse(chunk[0], radix: 16);
          if (firstDigit != null && firstDigit < 4) {
            final prefix = dtcPrefixes[firstDigit];
            dtcs.add('$prefix${chunk.substring(1)}');
          }
        }
      }
    }
    return dtcs;
  }

  void startPolling({Duration interval = const Duration(milliseconds: 1500)}) {
    if (_isPolling) return;
    _isPolling = true;

    _pollingTimer = Timer.periodic(interval, (_) async {
      for (final pid in ObdPids.dashboard) {
        await queryPid(pid);
        await Future.delayed(const Duration(milliseconds: 200));
      }
    });
    notifyListeners();
  }

  void stopPolling() {
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    notifyListeners();
  }

  void disconnect() {
    stopPolling();
    _btService.disconnect();
    _connectionStatus = 'Desconectado';
    _pidValues.clear();
    _pidHistory.clear();
    _rpmHistory.clear();
    _missingPulses = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _btService.dispose();
    super.dispose();
  }
}
