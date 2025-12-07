import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/gas_provider.dart';
import '../models/gas_data.dart';

class SensorListPage extends StatelessWidget {
  const SensorListPage({super.key});

  // Fungsi untuk membuka Google Maps
  Future<void> _openGoogleMaps(BuildContext context) async {
    final url = Uri.parse('https://maps.app.goo.gl/nF5JmxUwTZHU2Bkj9?g_st=ipc');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GasProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            _buildStatusIndicators(provider.overallStatus),
            SizedBox(height: 20),
            Text('DAFTAR SENSOR', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: provider.sensors.length,
                itemBuilder: (context, index) => _buildSensorCard(context, provider.sensors[index]),
              ),
            ),
          ],
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

  Widget _buildSensorCard(BuildContext context, SensorData sensor) {
    final threshold = GasThreshold.thresholds[sensor.gasType]!;
    Color statusColor = _getStatusColor(sensor.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF00BFA5), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(_getStatusIcon(sensor.status), color: statusColor, size: 24),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sensor.shortName, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(sensor.gasName, style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(_getStatusText(sensor.status), style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nilai Saat Ini:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${sensor.currentPpm.toStringAsFixed(1)} ppm', style: TextStyle(color: statusColor, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Divider(color: Colors.white24),
          SizedBox(height: 8),
          Text('Threshold (NIOSH Standard):', style: TextStyle(color: Colors.white70, fontSize: 11)),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildThresholdChip('AMAN', '<${threshold.safeMax.toInt()}', Colors.green),
              _buildThresholdChip('WASPADA', '${threshold.safeMax.toInt()}-${threshold.warningMax.toInt()}', Colors.orange),
              _buildThresholdChip('BAHAYA', '>${threshold.warningMax.toInt()}', Colors.red),
            ],
          ),
          SizedBox(height: 12),
          // Tombol Lokasi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openGoogleMaps(context),
              icon: Icon(Icons.location_on, size: 18),
              label: Text('Lihat Lokasi Sensor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF00BFA5),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 11)),
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

  IconData _getStatusIcon(GasStatus status) {
    switch (status) {
      case GasStatus.normal: return Icons.check_circle;
      case GasStatus.warning: return Icons.warning;
      case GasStatus.danger: return Icons.dangerous;
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
