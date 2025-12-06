import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gas_provider.dart';
import '../models/gas_data.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GasProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            _buildStatusIndicators(provider.overallStatus),
            SizedBox(height: 20),
            Text('RIWAYAT KEJADIAN', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: provider.historyEvents.isEmpty
                  ? Center(child: Text('Belum ada riwayat kejadian', style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: provider.historyEvents.length,
                      itemBuilder: (context, index) => _buildEventCard(provider.historyEvents[index]),
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

  Widget _buildEventCard(HistoryEvent event) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF00BFA5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: _getStatusColor(event.status).withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(_getStatusIcon(event.status), color: _getStatusColor(event.status), size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${event.gasName} - ${_getStatusText(event.status)}', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text('${event.ppm.toStringAsFixed(1)} PPM', style: TextStyle(color: _getStatusColor(event.status), fontSize: 12, fontWeight: FontWeight.bold)),
                Text(DateFormat('d MMM yyyy, HH:mm').format(event.timestamp), style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
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
