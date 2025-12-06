import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gas_provider.dart';
import '../models/gas_data.dart';
import 'dart:math' as math;

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GasProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildStatusIndicators(provider.overallStatus),
              SizedBox(height: 20),
              Text('GAS MONITORING', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildOverallStatusBadge(provider),
              SizedBox(height: 20),
              _buildSensorCards(provider.sensors),
              SizedBox(height: 20),
              _buildQuickStats(provider.sensors),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicators(GasStatus status) {
    return Row(
      children: [
        SizedBox(width: 16),
        Container(width: 20, height: 20, decoration: BoxDecoration(color: status == GasStatus.danger ? Colors.red : Colors.red.withValues(alpha: 0.3), shape: BoxShape.circle)),
        SizedBox(width: 8),
        Container(width: 20, height: 20, decoration: BoxDecoration(color: status == GasStatus.warning ? Colors.orange : Colors.orange.withValues(alpha: 0.3), shape: BoxShape.circle)),
        SizedBox(width: 8),
        Container(width: 20, height: 20, decoration: BoxDecoration(color: status == GasStatus.normal ? Colors.green : Colors.green.withValues(alpha: 0.3), shape: BoxShape.circle)),
      ],
    );
  }

  Widget _buildOverallStatusBadge(GasProvider provider) {
    Color statusColor;
    IconData statusIcon;
    switch (provider.overallStatus) {
      case GasStatus.normal:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      case GasStatus.warning:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
      case GasStatus.danger:
        statusColor = Colors.red;
        statusIcon = Icons.dangerous;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 40),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STATUS KESELURUHAN', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(provider.overallStatusText, style: TextStyle(color: statusColor, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCards(List<SensorData> sensors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Pembacaan 5 Sensor Gas', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3),
          itemCount: sensors.length,
          itemBuilder: (context, index) {
            var sensor = sensors[index];
            Color statusColor = _getStatusColor(sensor.status);
            return Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Color(0xFF00BFA5), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(sensor.shortName, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                        child: Text(_getStatusText(sensor.status), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Text('${sensor.currentPpm.toStringAsFixed(1)} ppm', style: TextStyle(color: statusColor, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(sensor.gasName.split('(')[1].replaceAll(')', ''), style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickStats(List<SensorData> sensors) {
    int safeCount = sensors.where((s) => s.status == GasStatus.normal).length;
    int warningCount = sensors.where((s) => s.status == GasStatus.warning).length;
    int dangerCount = sensors.where((s) => s.status == GasStatus.danger).length;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF00BFA5), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Status', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('AMAN', safeCount, Colors.green),
              _buildStatItem('WASPADA', warningCount, Colors.orange),
              _buildStatItem('BAHAYA', dangerCount, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  String _getStatusText(GasStatus status) {
    switch (status) {
      case GasStatus.normal: return 'AMAN';
      case GasStatus.warning: return 'WASPADA';
      case GasStatus.danger: return 'BAHAYA';
    }
  }

  Color _getStatusColor(GasStatus status) {
    switch (status) {
      case GasStatus.normal: return Color(0xFF00E676); // Hijau terang
      case GasStatus.warning: return Colors.orange;
      case GasStatus.danger: return Colors.red;
    }
  }
}
