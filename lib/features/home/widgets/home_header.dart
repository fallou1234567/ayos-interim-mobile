import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo2.png',
          width: 70,
          fit: BoxFit.contain,
        ),

        const Spacer(),

        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: const Icon(
            Icons.wb_sunny_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(width: 8),

        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: const Icon(
            Icons.notifications_none,
            size: 19,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(width: 8),

        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            'FD',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}