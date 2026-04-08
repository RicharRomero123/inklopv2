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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
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
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black54,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            unselectedLabelStyle: const TextStyle(height: 1.2),
            items: [
              BottomNavigationBarItem(
                icon: _buildIcon('assets/images/ic_explore.png', isSelected: currentIndex == 0),
                activeIcon: _buildIcon('assets/images/ic_explore_filled.png', isSelected: true),
                label: 'Explorar',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon('assets/images/ic_dashboard.png', isSelected: currentIndex == 1),
                activeIcon: _buildIcon('assets/images/ic_dashboard_filled.png', isSelected: true),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon('assets/images/ic_wallet.png', isSelected: currentIndex == 2),
                activeIcon: _buildIcon('assets/images/ic_wallet_filled.png', isSelected: true),
                label: 'Mis Pagos',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon('assets/images/ic_profile.png', isSelected: currentIndex == 3),
                activeIcon: _buildIcon('assets/images/ic_profile_filled.png', isSelected: true),
                label: 'Mi perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String assetPath, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Image.asset(
        assetPath,
        width: 24,
        height: 24,
        color: isSelected ? Colors.black : Colors.black54,
      ),
    );
  }
}