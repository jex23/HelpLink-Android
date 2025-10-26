import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isGuest;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isGuest = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: isGuest
                ? [
                    // Guest mode: Only Home and Nearby
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                      isActive: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _buildNavItem(
                      icon: Icons.location_on_rounded,
                      label: 'Nearby',
                      index: 1,
                      isActive: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                  ]
                : [
                    // Logged in mode: All tabs
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                      isActive: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _buildNavItem(
                      icon: Icons.article_rounded,
                      label: 'My Posts',
                      index: 1,
                      isActive: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    _buildNavItem(
                      icon: Icons.add_circle_rounded,
                      label: 'Post',
                      index: 2,
                      isActive: currentIndex == 2,
                      onTap: () => onTap(2),
                      isCenter: true,
                    ),
                    _buildNavItem(
                      icon: Icons.location_on_rounded,
                      label: 'Nearby',
                      index: 3,
                      isActive: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                    _buildNavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      index: 4,
                      isActive: currentIndex == 4,
                      onTap: () => onTap(4),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
    bool isCenter = false,
  }) {
    final Color activeColor = const Color(0xFF1976D2);
    final Color inactiveColor = Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: isCenter ? 32 : 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
