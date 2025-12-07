import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/gas_data.dart';

class GasProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  bool _isAlarmPlaying = false;
  GasStatus? _currentAlarmStatus;
  int _cycleCounter = 0;

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
    _initializeHistory();
    _startSimulation();
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
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _cycleCounter++;
      final random = Random();

      for (var sensor in sensors) {
        final threshold = GasThreshold.thresholds[sensor.gasType]!;
        double targetPpm;

        // Simulasi: 15 detik aman, 10 detik waspada, 5 detik bahaya
        if (_cycleCounter <= 15) {
          targetPpm = threshold.safeMax * 0.6 + random.nextDouble() * threshold.safeMax * 0.3;
        } else if (_cycleCounter <= 25) {
          targetPpm = threshold.safeMax + (threshold.warningMax - threshold.safeMax) * 0.5;
          targetPpm += random.nextDouble() * (threshold.warningMax - threshold.safeMax) * 0.3;
        } else if (_cycleCounter <= 30) {
          targetPpm = threshold.warningMax + random.nextDouble() * threshold.warningMax * 0.2;
        } else {
          _cycleCounter = 0;
          targetPpm = threshold.safeMax * 0.5;
        }

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
