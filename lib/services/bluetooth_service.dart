import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  BluetoothConnection? _connection;
  final StreamController<String> _dataController =
      StreamController<String>.broadcast();

  Stream<String> get dataStream => _dataController.stream;
  bool get isConnected => _connection?.isConnected ?? false;

  Future<List<BluetoothDevice>> scanDevices() async {
    final List<BluetoothDevice> devices = [];
    final subscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      if (!devices.contains(result.device)) {
        devices.add(result.device);
      }
    });

    await Future.delayed(const Duration(seconds: 5));
    await subscription.cancel();
    return devices;
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);

      _connection!.input!.listen((Uint8List data) {
        final String response = ascii.decode(data);
        _dataController.add(response);
      }, onDone: () {
        _dataController.add('DISCONNECTED');
      });

      await _initializeElm327();
      return true;
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  Future<void> _initializeElm327() async {
    final commands = [
      'ATZ',
      'ATE0',
      'ATL0',
      'ATS0',
      'ATH0',
      'ATSP0',
    ];

    for (final cmd in commands) {
      await sendCommand(cmd);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<String> sendCommand(String command) async {
    if (_connection == null || !_connection!.isConnected) {
      return 'ERROR: No conectado';
    }

    final completer = Completer<String>();
    final buffer = StringBuffer();

    final subscription = _dataController.stream.listen((data) {
      buffer.write(data);
      final response = buffer.toString().trim();
      if (response.endsWith('>') || response.contains('ERROR') ||
          response.contains('NO DATA')) {
        if (!completer.isCompleted) {
          completer.complete(response.replaceAll('>', '').trim());
        }
      }
    });

    _connection!.output.add(ascii.encode('$command\r'));
    await _connection!.output.allSent;

    final result = await completer.future
        .timeout(const Duration(seconds: 5), onTimeout: () => 'TIMEOUT');

    await subscription.cancel();
    return result;
  }

  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
  }

  void dispose() {
    _dataController.close();
    disconnect();
  }
}
