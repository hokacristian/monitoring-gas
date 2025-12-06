import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/gas_provider.dart';
import 'pages/dashboard_page.dart';
import 'pages/chart_page.dart';
import 'pages/history_page.dart';
import 'pages/profile_page.dart';
import 'pages/sensor_list_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GasProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gas Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ChartPage(),
    const SensorListPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00796B),
        leading: IconButton(icon: Icon(Icons.menu, color: Colors.white), onPressed: () {}),
        title: Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('GASKEUN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.settings, color: Colors.white), onPressed: () {}),
          IconButton(icon: Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF00796B),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Chart'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Sensor'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
