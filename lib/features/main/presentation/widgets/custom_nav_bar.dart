import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0214), // Negro/Morado muy oscuro del diseño
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent, // El color lo da el Container
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Mis Pagos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Mi perfil'),
        ],
      ),
    );
  }
}