
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  String _formatDate(DateTime date) {
    const days = [
      'LUNDI', 'MARDI', 'MERCREDI', 'JEUDI',
      'VENDREDI', 'SAMEDI', 'DIMANCHE',
    ];

    const months = [
      'JANVIER', 'FÉVRIER', 'MARS', 'AVRIL',
      'MAI', 'JUIN', 'JUILLET', 'AOÛT',
      'SEPTEMBRE', 'OCTOBRE', 'NOVEMBRE', 'DÉCEMBRE',
    ];

    return '${days[date.weekday - 1]} '
        '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final firstName = user?.firstName.trim().isNotEmpty == true
        ? user!.firstName.trim()
        : (user?.fullName.trim().isNotEmpty == true
            ? user!.fullName.trim().split(' ').first
            : 'utilisateur');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(DateTime.now()),
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bonjour $firstName',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Une nouvelle mission vous attend.',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
