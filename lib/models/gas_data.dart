class GasData {
  final double ppm;
  final DateTime timestamp;

  GasData(this.ppm, this.timestamp);
}

enum GasType { co, lpg, nh3, ch4, h2s }

class GasThreshold {
  final double safeMax;
  final double warningMax;
  
  const GasThreshold({required this.safeMax, required this.warningMax});
  
  static const Map<GasType, GasThreshold> thresholds = {
    GasType.co: GasThreshold(safeMax: 34, warningMax: 199),    // CO: AMAN <34, WASPADA 35-199, BAHAYA >200
    GasType.lpg: GasThreshold(safeMax: 999, warningMax: 1599), // LPG: AMAN <999, WASPADA 1000-1599, BAHAYA >1600
    GasType.nh3: GasThreshold(safeMax: 24, warningMax: 49),    // NH3: AMAN <24, WASPADA 25-49, BAHAYA >50
    GasType.ch4: GasThreshold(safeMax: 1000, warningMax: 4999),// CH4: AMAN <1000, WASPADA 1001-4999, BAHAYA >5000
    GasType.h2s: GasThreshold(safeMax: 1, warningMax: 9),      // H2S: AMAN <1, WASPADA 2-9, BAHAYA >10
  };
}

enum GasStatus { normal, warning, danger }

class SensorData {
  final String id;
  final String name;
  final GasType gasType;
  final String unit;
  double currentPpm;
  GasStatus status;
  List<GasData> history;

  SensorData({
    required this.id,
    required this.name,
    required this.gasType,
    this.unit = 'ppm',
    required this.currentPpm,
    required this.status,
    required this.history,
  });

  GasStatus calculateStatus() {
    final threshold = GasThreshold.thresholds[gasType]!;
    if (currentPpm <= threshold.safeMax) return GasStatus.normal;
    if (currentPpm <= threshold.warningMax) return GasStatus.warning;
    return GasStatus.danger;
  }

  String get gasName {
    switch (gasType) {
      case GasType.co: return 'CO (Carbon Monoxide)';
      case GasType.lpg: return 'LPG (Propane/Butane)';
      case GasType.nh3: return 'NH3 (Ammonia)';
      case GasType.ch4: return 'CH4 (Metana)';
      case GasType.h2s: return 'H2S (Hydrogen Sulfide)';
    }
  }

  String get shortName {
    switch (gasType) {
      case GasType.co: return 'CO';
      case GasType.lpg: return 'LPG';
      case GasType.nh3: return 'NH3';
      case GasType.ch4: return 'CH4';
      case GasType.h2s: return 'H2S';
    }
  }
}

class HistoryEvent {
  final String sensorName;
  final String gasName;
  final double ppm;
  final GasStatus status;
  final DateTime timestamp;

  HistoryEvent({
    required this.sensorName,
    required this.gasName,
    required this.ppm,
    required this.status,
    required this.timestamp,
  });
}
