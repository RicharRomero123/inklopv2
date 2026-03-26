import 'package:flutter/material.dart';
import 'widgets/custom_nav_bar.dart';
import 'screens/explore_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/payments_page.dart';
// 🚀 IMPORTA LA PANTALLA REAL (la de la carpeta profile)
import '../../profile/presentation/screens/profile_page.dart';

class MainScreen extends StatefulWidget {
  final String accessToken; // Necesitamos el token para el perfil
  const MainScreen({super.key, required this.accessToken});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Usamos 'late' porque necesitamos inicializar la lista con el token del widget
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ExplorePage(),
      const DashboardPage(),
      const PaymentsPage(),
      // 🚀 ENLAZAMOS LA PANTALLA REAL PASANDO EL TOKEN
      ProfilePage(accessToken: widget.accessToken),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}