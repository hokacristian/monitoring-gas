import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  User? _currentUser;
  String _location = 'Jakarta, Indonesia';

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  // Show edit dialog
  Future<void> _showEditDialog(String title, String currentValue, Function(String) onSave) async {
    final controller = TextEditingController(text: currentValue);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text('Edit $title', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Masukkan $title',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00BFA5)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00BFA5), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00BFA5),
            ),
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

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
          Text(
            _currentUser?.displayName ?? 'User',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          // Email
          Text(
            _currentUser?.email ?? '',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 30),
          // Info Cards
          _buildInfoCard(
            Icons.person_outline,
            'Nama',
            _currentUser?.displayName ?? 'User',
            onEdit: () => _showEditDialog('Nama', _currentUser?.displayName ?? '', (value) async {
              await _currentUser?.updateDisplayName(value);
              setState(() => _currentUser = _authService.currentUser);
            }),
          ),
          _buildInfoCard(
            Icons.email_outlined,
            'Email',
            _currentUser?.email ?? '',
            onEdit: null,
          ),
          _buildInfoCard(
            Icons.location_on_outlined,
            'Lokasi',
            _location,
            onEdit: () => _showEditDialog('Lokasi', _location, (value) {
              setState(() => _location = value);
            }),
          ),
          SizedBox(height: 30),
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Color(0xFF1E1E1E),
                    title: Text('Logout', style: TextStyle(color: Colors.white)),
                    content: Text(
                      'Apakah Anda yakin ingin keluar?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal', style: TextStyle(color: Colors.white70)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _authService.signOut();
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logout berhasil!'),
                                backgroundColor: Color(0xFF00BFA5),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
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

  Widget _buildInfoCard(IconData icon, String label, String value, {VoidCallback? onEdit}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF00BFA5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}
