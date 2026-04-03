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
      height: 90,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0], // negro hasta la mitad, luego abre a morado
          colors: [
            Color(0xFF080808), // negro puro arriba
            Color(0xFF150428), // empieza a cambiar en la mitad
            Color(0xFF4A0E8F), // morado claro al fondo
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            unselectedLabelStyle: const TextStyle(height: 1.2),
            items: [
              BottomNavigationBarItem(
                icon: _buildIcon('assets/images/ic_explore.png'),
                activeIcon: _buildIcon('assets/images/ic_explore_filled.png'),
                label: 'Explorar',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon('assets/images/ic_dashboard.png'),
                activeIcon: _buildIcon('assets/images/ic_dashboard_filled.png'),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon('assets/images/ic_wallet.png'),
                activeIcon: _buildIcon('assets/images/ic_wallet_filled.png'),
                label: 'Mis Pagos',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon('assets/images/ic_profile.png'),
                activeIcon: _buildIcon('assets/images/ic_profile_filled.png'),
                label: 'Mi perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String assetPath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Image.asset(
        assetPath,
        width: 24,
        height: 24,
        color: Colors.white,
      ),
    );
  }
}