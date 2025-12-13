import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/gas_data.dart';

// Data untuk tracking siklus masing-masing sensor
class SensorCycle {
  double phase; // Current phase (0 to 2π)
  double period; // Periode dalam detik (berapa lama 1 siklus penuh)
  double phaseOffset; // Offset awal agar tidak sinkron

  SensorCycle({
    required this.phase,
    required this.period,
    required this.phaseOffset,
  });
}

class GasProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  bool _isAlarmPlaying = false;
  GasStatus? _currentAlarmStatus;

  // Tracking siklus untuk setiap sensor
  final Map<String, SensorCycle> _sensorCycles = {};

  // 5 Sensor untuk 5 jenis gas
  List<SensorData> sensors = [
    SensorData(
      id: '1',
      name: 'Sensor CO',
      gasType: GasType.co,
      currentPpm: 20,
      status: GasStatus.normal,
      history: [],
    ),
    SensorData(
      id: '2',
      name: 'Sensor LPG',
      gasType: GasType.lpg,
      currentPpm: 500,
      status: GasStatus.normal,
      history: [],
    ),
    SensorData(
      id: '3',
      name: 'Sensor NH3',
      gasType: GasType.nh3,
      currentPpm: 15,
      status: GasStatus.normal,
      history: [],
    ),
    SensorData(
      id: '4',
      name: 'Sensor CH4',
      gasType: GasType.ch4,
      currentPpm: 600,
      status: GasStatus.normal,
      history: [],
    ),
    SensorData(
      id: '5',
      name: 'Sensor H2S',
      gasType: GasType.h2s,
      currentPpm: 0.5,
      status: GasStatus.normal,
      history: [],
    ),
  ];

  List<HistoryEvent> historyEvents = [];

  GasProvider() {
    _initializeSensorCycles();
    _initializeHistory();
    _startSimulation();
  }

  void _initializeSensorCycles() {
    // Inisialisasi siklus untuk setiap sensor
    // SEMUA periode SAMA (60 detik) agar bisa sync kembali ke AMAN bersamaan
    // Tapi phase offset BERBEDA agar bergantian

    const commonPeriod = 60.0; // 1 menit - SAMA untuk semua

    // Phase offset: 0, 1/5, 2/5, 3/5, 4/5 dari siklus (2π)
    // Ini membuat sensor bergantian setiap 12 detik
    // Setelah 60 detik, semua kembali ke AMAN bersamaan

    _sensorCycles['1'] = SensorCycle(
      phase: 0,                    // Start: AMAN
      period: commonPeriod,
      phaseOffset: 0,
    );
    _sensorCycles['2'] = SensorCycle(
      phase: 2 * pi * 0.2,         // Start: offset 12 detik (20%)
      period: commonPeriod,
      phaseOffset: 2 * pi * 0.2,
    );
    _sensorCycles['3'] = SensorCycle(
      phase: 2 * pi * 0.4,         // Start: offset 24 detik (40%)
      period: commonPeriod,
      phaseOffset: 2 * pi * 0.4,
    );
    _sensorCycles['4'] = SensorCycle(
      phase: 2 * pi * 0.6,         // Start: offset 36 detik (60%)
      period: commonPeriod,
      phaseOffset: 2 * pi * 0.6,
    );
    _sensorCycles['5'] = SensorCycle(
      phase: 2 * pi * 0.8,         // Start: offset 48 detik (80%)
      period: commonPeriod,
      phaseOffset: 2 * pi * 0.8,
    );
  }

  void _initializeHistory() {
    final random = Random();
    for (var sensor in sensors) {
      final threshold = GasThreshold.thresholds[sensor.gasType]!;
      for (int j = 0; j < 24; j++) {
        // Generate dummy data dalam range aman
        double value = threshold.safeMax * 0.5 + random.nextDouble() * threshold.safeMax * 0.4;
        sensor.history.add(GasData(value, DateTime.now().subtract(Duration(hours: 24 - j))));
      }
    }
  }

  void _startSimulation() {
    const updateInterval = 2; // Update setiap 2 detik
    final random = Random();

    _timer = Timer.periodic(Duration(seconds: updateInterval), (timer) {
      for (var sensor in sensors) {
        final cycle = _sensorCycles[sensor.id]!;
        final threshold = GasThreshold.thresholds[sensor.gasType]!;

        // Update phase berdasarkan periode
        // phase bertambah dari 0 ke 2π dalam waktu period detik
        cycle.phase += (2 * pi * updateInterval) / cycle.period;
        if (cycle.phase >= 2 * pi) {
          cycle.phase -= 2 * pi; // Reset ke 0 setelah 1 siklus penuh
        }

        // Gunakan sine wave untuk transisi smooth
        // sin(phase) menghasilkan nilai -1 to 1
        // Kita mapping:
        // -1 to -0.5 => AMAN
        // -0.5 to 0.5 => WASPADA (naik)
        // 0.5 to 1 => BAHAYA
        // 1 to 0.5 => BAHAYA (turun)
        // 0.5 to -0.5 => WASPADA (turun)
        // -0.5 to -1 => AMAN

        double sineValue = sin(cycle.phase);
        double targetPpm;

        if (sineValue < -0.3) {
          // Kondisi AMAN
          // Map dari -1 to -0.3 => 0% to 80% dari safeMax
          double t = (sineValue + 1) / 0.7; // normalize to 0-1
          targetPpm = threshold.safeMax * (0.2 + t * 0.6);
          // Tambahkan sedikit variasi random
          targetPpm += (random.nextDouble() - 0.5) * threshold.safeMax * 0.1;
        } else if (sineValue < 0.5) {
          // Transisi AMAN ke WASPADA atau WASPADA ke AMAN
          // Map dari -0.3 to 0.5 => safeMax to warningMax
          double t = (sineValue + 0.3) / 0.8; // normalize to 0-1
          targetPpm = threshold.safeMax + t * (threshold.warningMax - threshold.safeMax);
          // Tambahkan sedikit variasi random
          targetPpm += (random.nextDouble() - 0.5) * (threshold.warningMax - threshold.safeMax) * 0.1;
        } else {
          // Kondisi BAHAYA atau transisi WASPADA ke BAHAYA
          // Map dari 0.5 to 1 => warningMax to dangerLevel
          double t = (sineValue - 0.5) / 0.5; // normalize to 0-1
          double dangerLevel = threshold.warningMax * 1.5;
          targetPpm = threshold.warningMax + t * (dangerLevel - threshold.warningMax);
          // Tambahkan sedikit variasi random
          targetPpm += (random.nextDouble() - 0.5) * (dangerLevel - threshold.warningMax) * 0.1;
        }

        // Pastikan tidak melebihi batas maksimal
        targetPpm = targetPpm.clamp(0, threshold.warningMax * 2);

        sensor.currentPpm = targetPpm;
        sensor.history.add(GasData(sensor.currentPpm, DateTime.now()));
        if (sensor.history.length > 50) sensor.history.removeAt(0);

        GasStatus oldStatus = sensor.status;
        sensor.status = sensor.calculateStatus();

        if (oldStatus != sensor.status) {
          historyEvents.insert(0, HistoryEvent(
            sensorName: sensor.name,
            gasName: sensor.shortName,
            ppm: sensor.currentPpm,
            status: sensor.status,
            timestamp: DateTime.now(),
          ));
        }
      }

      _checkAlarm();
      notifyListeners();
    });
  }

  void _checkAlarm() async {
    // WORST CASE: Cek status dari semua sensor
    bool hasDanger = sensors.any((s) => s.status == GasStatus.danger);
    bool hasWarning = sensors.any((s) => s.status == GasStatus.warning);

    GasStatus targetStatus = hasDanger
        ? GasStatus.danger
        : hasWarning
            ? GasStatus.warning
            : GasStatus.normal;

    // Jika status berubah atau audio belum dimulai, update audio
    if (_currentAlarmStatus != targetStatus) {
      _currentAlarmStatus = targetStatus;

      await _audioPlayer.stop();

      if (targetStatus == GasStatus.danger) {
        // Status BAHAYA: putar bahaya.mp3
        _isAlarmPlaying = true;
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        try {
          await _audioPlayer.play(AssetSource('bahaya.mp3'));
        } catch (e) {
          debugPrint('Error playing bahaya alarm: $e');
        }
      } else if (targetStatus == GasStatus.warning) {
        // Status WASPADA: putar waspada.mp3
        _isAlarmPlaying = true;
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        try {
          await _audioPlayer.play(AssetSource('waspada.mp3'));
        } catch (e) {
          debugPrint('Error playing waspada alarm: $e');
        }
      } else {
        // Status NORMAL: stop audio
        _isAlarmPlaying = false;
      }
    }
  }

  // Overall status: WORST CASE dari semua sensor
  GasStatus get overallStatus {
    if (sensors.any((s) => s.status == GasStatus.danger)) return GasStatus.danger;
    if (sensors.any((s) => s.status == GasStatus.warning)) return GasStatus.warning;
    return GasStatus.normal;
  }

  String get overallStatusText {
    switch (overallStatus) {
      case GasStatus.normal: return 'AMAN';
      case GasStatus.warning: return 'WASPADA';
      case GasStatus.danger: return 'BAHAYA';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
