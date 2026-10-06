import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          child: Column(
            children: [
              _header(),

              const SizedBox(height: 10),

              _statistics(),

              const SizedBox(height: 14),

              _menuItem(
                icon: Icons.person_outline,
                title: 'Informations personnelles',
              ),

              const SizedBox(height: 7),

              _menuItem(
                icon: Icons.business_center_outlined,
                title: 'Mes métiers',
              ),

              const SizedBox(height: 7),

              _menuItem(
                icon: Icons.calendar_month_outlined,
                title: 'Préférences de missions',
              ),

              const SizedBox(height: 7),

              _menuItem(
                icon: Icons.support_outlined,
                title: 'Aide et assistance',
              ),

              const SizedBox(height: 28),

              TextButton(
                onPressed: () {},
                child: const Text(
                  'Se déconnecter',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 145,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.cyanLight,
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: const Text(
              'FD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROFIL ACTIF',
                  style: TextStyle(
                    color: AppColors.orange,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Fatou DIOP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Réceptionniste · Night Auditor',
                  style: TextStyle(color: Colors.white60, fontSize: 7),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.verified_outlined,
            color: AppColors.orange,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _statistics() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _Stat(value: '64', label: 'Missions'),
          ),

          _VerticalDivider(),

          Expanded(
            child: _Stat(value: '487 h', label: 'Heures'),
          ),

          _VerticalDivider(),

          Expanded(
            child: _Stat(value: '4.6 ⭐', label: 'Note'),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.navy),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: const TextStyle(fontSize: 7, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.border);
  }
}
