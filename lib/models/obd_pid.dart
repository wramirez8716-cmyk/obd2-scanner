class ObdPid {
  final String name;
  final String mode;
  final String pid;
  final String unit;
  final double Function(List<int>) parser;
  final double? minValue;
  final double? maxValue;
  final String? description;

  const ObdPid({
    required this.name,
    required this.mode,
    required this.pid,
    required this.unit,
    required this.parser,
    this.minValue,
    this.maxValue,
    this.description,
  });
}

class ObdPids {
  static const List<ObdPid> dashboard = [
    ObdPid(
      name: 'RPM',
      mode: '01',
      pid: '0C',
      unit: 'rpm',
      minValue: 0,
      maxValue: 8000,
      description: 'Sensor de cigüeñal',
      parser: _parseRpm,
    ),
    ObdPid(
      name: 'Velocidad',
      mode: '01',
      pid: '0D',
      unit: 'km/h',
      minValue: 0,
      maxValue: 255,
      description: 'Velocidad del vehículo',
      parser: _parseSpeed,
    ),
    ObdPid(
      name: 'Temp. Motor',
      mode: '01',
      pid: '05',
      unit: '°C',
      minValue: -40,
      maxValue: 215,
      description: 'Temperatura del refrigerante',
      parser: _parseTemp,
    ),
    ObdPid(
      name: 'MAF',
      mode: '01',
      pid: '10',
      unit: 'g/s',
      minValue: 0,
      maxValue: 655.35,
      description: 'Sensor de flujo de aire',
      parser: _parseMaf,
    ),
    ObdPid(
      name: 'TPS',
      mode: '01',
      pid: '11',
      unit: '%',
      minValue: 0,
      maxValue: 100,
      description: 'Posición del acelerador',
      parser: _parsePercentage,
    ),
  ];

  static const List<ObdPid> oxygenSensors = [
    ObdPid(
      name: 'O2 Banco 1 Sensor 1',
      mode: '01',
      pid: '14',
      unit: 'V',
      minValue: 0,
      maxValue: 1.275,
      description: 'Sensor O2 antes del catalizador',
      parser: _parseO2Voltage,
    ),
    ObdPid(
      name: 'O2 Banco 1 Sensor 2',
      mode: '01',
      pid: '15',
      unit: 'V',
      minValue: 0,
      maxValue: 1.275,
      description: 'Sensor O2 después del catalizador',
      parser: _parseO2Voltage,
    ),
  ];

  // Parsers
  static double _parseRpm(List<int> bytes) {
    return ((bytes[0] * 256) + bytes[1]) / 4.0;
  }

  static double _parseSpeed(List<int> bytes) {
    return bytes[0].toDouble();
  }

  static double _parseTemp(List<int> bytes) {
    return bytes[0] - 40.0;
  }

  static double _parseMaf(List<int> bytes) {
    return ((bytes[0] * 256) + bytes[1]) / 100.0;
  }

  static double _parsePercentage(List<int> bytes) {
    return (bytes[0] * 100.0) / 255.0;
  }

  static double _parseO2Voltage(List<int> bytes) {
    return (bytes[0] * 2) / 255.0;
  }
}
