import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Placeholder data
  String _name = 'John Doe';
  String _email = 'johndoe@email.com';
  String _phone = '+62 812 3456 7890';
  String _location = 'Jakarta, Indonesia';
  String? _profileImagePath;

  final ImagePicker _picker = ImagePicker();

  // Request permission and pick image from gallery
  Future<void> _pickImage() async {
    try {
      // Request permission terlebih dahulu
      PermissionStatus status;

      // Cek Android version untuk menentukan permission yang tepat
      if (Platform.isAndroid) {
        final androidInfo = await getAndroidVersion();
        if (androidInfo >= 33) {
          // Android 13+ menggunakan photos permission
          status = await Permission.photos.request();
        } else {
          // Android 12 ke bawah menggunakan storage permission
          status = await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        status = await Permission.photos.request();
      } else {
        status = PermissionStatus.granted;
      }

      if (status.isGranted) {
        // Permission diberikan, lanjut pick image
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _profileImagePath = image.path;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Foto profil berhasil diubah!'),
                backgroundColor: Color(0xFF00BFA5),
              ),
            );
          }
        } else {
          // User cancelled the picker
          debugPrint('User cancelled image picker');
        }
      } else if (status.isDenied) {
        // Permission ditolak
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Izin akses galeri diperlukan untuk mengubah foto profil'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else if (status.isPermanentlyDenied) {
        // Permission ditolak permanen, arahkan ke settings
        if (mounted) {
          _showPermissionDialog();
        }
      }
    } on Exception catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Get Android version
  Future<int> getAndroidVersion() async {
    if (Platform.isAndroid) {
      var androidInfo = await Permission.photos.status;
      // Asumsi Android 13+ jika photos permission tersedia
      return 33;
    }
    return 0;
  }

  // Dialog untuk membuka settings jika permission ditolak permanen
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text('Izin Diperlukan', style: TextStyle(color: Colors.white)),
        content: Text(
          'Aplikasi membutuhkan izin akses galeri untuk mengubah foto profil. Silakan buka Settings dan berikan izin.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00BFA5),
            ),
            child: Text('Buka Settings'),
          ),
        ],
      ),
    );
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
          // Avatar with edit button
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF00BFA5),
                backgroundImage: _profileImagePath != null
                    ? FileImage(File(_profileImagePath!))
                    : null,
                child: _profileImagePath == null
                    ? Icon(Icons.person, size: 70, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF00BFA5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF121212), width: 2),
                    ),
                    child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Nama
          Text(_name, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          // Email
          Text(_email, style: TextStyle(color: Colors.white70, fontSize: 16)),
          SizedBox(height: 30),
          // Info Cards
          _buildInfoCard(
            Icons.person_outline,
            'Nama',
            _name,
            onEdit: () => _showEditDialog('Nama', _name, (value) {
              setState(() => _name = value);
            }),
          ),
          _buildInfoCard(
            Icons.email_outlined,
            'Email',
            _email,
            onEdit: () => _showEditDialog('Email', _email, (value) {
              setState(() => _email = value);
            }),
          ),
          _buildInfoCard(
            Icons.phone_outlined,
            'Telepon',
            _phone,
            onEdit: () => _showEditDialog('Telepon', _phone, (value) {
              setState(() => _phone = value);
            }),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout berhasil! Data akan reset saat aplikasi ditutup.'),
                    backgroundColor: Color(0xFF00BFA5),
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

  Widget _buildInfoCard(IconData icon, String label, String value, {required VoidCallback onEdit}) {
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
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
