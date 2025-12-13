import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTap;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final User? currentUser = authService.currentUser;

    return Drawer(
      backgroundColor: Color(0xFF1E1E1E),
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00796B), Color(0xFF004D40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFF00796B),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  currentUser?.displayName ?? 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  currentUser?.email ?? '',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Chart',
                  index: 1,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.camera_alt,
                  title: 'Sensor',
                  index: 2,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.history,
                  title: 'History',
                  index: 3,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  index: 4,
                ),
                Divider(color: Colors.grey[700], thickness: 1, height: 32),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Informasi Gas',
                  index: 5,
                  isSpecial: true,
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Divider(color: Colors.grey[700], thickness: 1),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'GASKEUN',
                      style: TextStyle(
                        color: Color(0xFF00BFA5),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Gas Monitoring System v1.0',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    bool isSpecial = false,
  }) {
    final isSelected = currentIndex == index;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF00796B).withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Color(0xFF00BFA5), width: 1)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Color(0xFF00BFA5)
              : isSpecial
                  ? Colors.orange
                  : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSpecial
            ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange)
            : null,
        onTap: () {
          Navigator.pop(context); // Close drawer
          onItemTap(index);
        },
      ),
    );
  }
}
