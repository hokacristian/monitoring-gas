import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/gas_provider.dart';
import 'pages/dashboard_page.dart';
import 'pages/chart_page.dart';
import 'pages/history_page.dart';
import 'pages/profile_page.dart';
import 'pages/sensor_list_page.dart';
import 'pages/login_page.dart';
import 'pages/information_page.dart';
import 'widgets/app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00796B),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return MainPage();
          }

          return LoginPage();
        },
      ),
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

  void _handleDrawerItemTap(int index) {
    if (index == 5) {
      // Navigate to Information Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InformationPage()),
      );
    } else {
      // Navigate to main pages (0-4)
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00796B),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('GASKEUN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
        ],
      ),
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onItemTap: _handleDrawerItemTap,
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
