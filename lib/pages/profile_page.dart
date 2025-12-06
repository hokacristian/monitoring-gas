import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 20),
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFF00BFA5),
            child: Icon(Icons.person, size: 70, color: Colors.white),
          ),
          SizedBox(height: 20),
          // Nama
          Text('John Doe', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          // Email
          Text('johndoe@email.com', style: TextStyle(color: Colors.white70, fontSize: 16)),
          SizedBox(height: 30),
          // Info Cards
          _buildInfoCard(Icons.person_outline, 'Nama', 'John Doe'),
          _buildInfoCard(Icons.email_outlined, 'Email', 'johndoe@email.com'),
          _buildInfoCard(Icons.phone_outlined, 'Telepon', '+62 812 3456 7890'),
          _buildInfoCard(Icons.location_on_outlined, 'Lokasi', 'Jakarta, Indonesia'),
          SizedBox(height: 30),
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF00BFA5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
