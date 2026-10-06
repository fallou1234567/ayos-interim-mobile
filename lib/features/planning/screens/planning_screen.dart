import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  int selectedDay = 0;

  final List<String> days = [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim',
  ];

  final List<String> dates = [
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            16,
            18,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),

              const SizedBox(height: 25),

              const Text(
                'SEMAINE DU 17 AU 23 AOÛT',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Mon planning',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Vos missions confirmées, sans chevauchement.',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 18),

              _daySelector(),

              const SizedBox(height: 20),

              _planningContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo2.png',
          width: 70,
        ),

        const Spacer(),

        _headerIcon(Icons.wb_sunny_outlined),
        const SizedBox(width: 8),
        _headerIcon(Icons.notifications_none),

        const SizedBox(width: 8),

        const CircleAvatar(
          radius: 19,
          backgroundColor: AppColors.navy,
          child: Text(
            'FD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _daySelector() {
    return SizedBox(
      height: 64,
      child: Row(
        children: List.generate(
          days.length,
          (index) {
            final selected = selectedDay == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDay = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == days.length - 1
                        ? 0
                        : 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.navy
                        : AppColors.white,
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.navy
                          : AppColors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          fontSize: 7,
                          color: selected
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        dates[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),

                      if (selected)
                        Container(
                          margin:
                              const EdgeInsets.only(top: 3),
                          width: 3,
                          height: 3,
                          decoration:
                              const BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _planningContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 42,
          child: Column(
            children: const [
              Text(
                '07:00',
                style: TextStyle(
                  fontSize: 7,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 105),

              Text(
                '15:00',
                style: TextStyle(
                  fontSize: 7,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 1,
          height: 145,
          color: AppColors.orange,
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'MISSION CONFIRMÉE',
                  style: TextStyle(
                    fontSize: 7,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Campanile Paris Est',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Réceptionniste',
                  style: TextStyle(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 18),

                Divider(
                  height: 1,
                  color: AppColors.border,
                ),

                SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: AppColors.orange,
                    ),

                    SizedBox(width: 4),

                    Text(
                      'Bagnolet',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    Spacer(),

                    Text(
                      '07:00 — 15:00',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Icon(
        icon,
        size: 17,
        color: AppColors.textSecondary,
      ),
    );
  }
}