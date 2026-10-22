
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/missions/screens/missions_screen.dart';
import '../../features/planning/screens/planning_screen.dart';
import '../../features/documents/screens/documents_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../navigation/app_navigation.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<AppNavigation>();
    final currentIndex = navigation.currentTab;

    final screens = <Widget>[
      const HomeScreen(),
      MissionsScreen(
        initialTab: navigation.missionsTab,
        key: ValueKey(navigation.missionsTab),
      ),
      const PlanningScreen(),
      const DocumentsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                context,
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Accueil',
                currentIndex: currentIndex,
              ),
              _navItem(
                context,
                index: 1,
                icon: Icons.business_center_outlined,
                activeIcon: Icons.business_center,
                label: 'Missions',
                currentIndex: currentIndex,
              ),
              _navItem(
                context,
                index: 2,
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month,
                label: 'Planning',
                currentIndex: currentIndex,
              ),
              _navItem(
                context,
                index: 3,
                icon: Icons.description_outlined,
                activeIcon: Icons.description,
                label: 'Documents',
                currentIndex: currentIndex,
              ),
              _navItem(
                context,
                index: 4,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
                currentIndex: currentIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int currentIndex,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<AppNavigation>().selectTab(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: 7,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.lightBlue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 19,
                color: isSelected
                    ? AppColors.navy
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isSelected
                      ? AppColors.navy
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
