import 'package:flutter/material.dart';
import 'package:inklop_v1/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:inklop_v1/features/payments/presentation/screens/payments_screen.dart';
import 'widgets/custom_nav_bar.dart';
import 'screens/dashboard_page.dart';
import 'screens/payments_page.dart';

// 🚀 IMPORTAMOS LAS PANTALLAS REALES
import '../../campaigns/presentation/screens/explore_campaigns_screen.dart';
import '../../profile/presentation/screens/profile_page.dart';

class MainScreen extends StatefulWidget {
  final String accessToken;
  const MainScreen({super.key, required this.accessToken});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Lista de páginas principal
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 🔗 Inicializamos las páginas inyectando el token donde corresponde
    _pages = [
      // 1. Nueva pantalla de campañas (Reemplaza a la anterior ExplorePage)
      ExploreCampaignsScreen(accessToken: widget.accessToken),

      DashboardScreen(accessToken: widget.accessToken),

      PaymentsScreen(accessToken: widget.accessToken),

      // 2. Pantalla de perfil real
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
      // Usamos IndexedStack para mantener el estado de las páginas al navegar
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