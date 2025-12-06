import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/gas_provider.dart';
import '../models/gas_data.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GasProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallStatus(provider),
              SizedBox(height: 20),
              Text('GRAFIK 5 SENSOR GAS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ...provider.sensors.map((sensor) => _buildSensorChart(sensor)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverallStatus(GasProvider provider) {
    Color statusColor;
    switch (provider.overallStatus) {
      case GasStatus.normal: statusColor = Colors.green;
      case GasStatus.warning: statusColor = Colors.orange;
      case GasStatus.danger: statusColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            provider.overallStatus == GasStatus.danger ? Icons.warning : 
            provider.overallStatus == GasStatus.warning ? Icons.error_outline : Icons.check_circle,
            color: statusColor, size: 30,
          ),
          SizedBox(width: 12),
          Text(
            'STATUS: ${provider.overallStatusText}',
            style: TextStyle(color: statusColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorChart(SensorData sensor) {
    final threshold = GasThreshold.thresholds[sensor.gasType]!;
    Color chartColor;
    switch (sensor.status) {
      case GasStatus.normal: chartColor = Color(0xFF00E676); // Hijau terang
      case GasStatus.warning: chartColor = Colors.orange;
      case GasStatus.danger: chartColor = Colors.red;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF00BFA5), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sensor.gasName, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('${sensor.currentPpm.toStringAsFixed(1)} ppm', style: TextStyle(color: chartColor, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: chartColor, borderRadius: BorderRadius.circular(20)),
                child: Text(_getStatusText(sensor.status), style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Aman: <${threshold.safeMax.toInt()} | Waspada: ${threshold.safeMax.toInt()}-${threshold.warningMax.toInt()} | Bahaya: >${threshold.warningMax.toInt()}',
            style: TextStyle(color: Colors.white70, fontSize: 10)),
          SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white24, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(color: Colors.white70, fontSize: 9)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(sensor.history.length, (i) => FlSpot(i.toDouble(), sensor.history[i].ppm)),
                    isCurved: true,
                    color: chartColor,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: chartColor.withValues(alpha: 0.3)),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(y: threshold.safeMax, color: Colors.green.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [5, 5]),
                    HorizontalLine(y: threshold.warningMax, color: Colors.red.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [5, 5]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(GasStatus status) {
    switch (status) {
      case GasStatus.normal: return 'AMAN';
      case GasStatus.warning: return 'WASPADA';
      case GasStatus.danger: return 'BAHAYA';
    }
  }
}
