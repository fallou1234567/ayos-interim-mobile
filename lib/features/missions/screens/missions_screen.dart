import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  int selectedTab = 1;

  final List<String> tabs = [
    'Propositions',
    'À venir',
    'Passées',
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
              // Header
              Row(
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
              ),

              const SizedBox(height: 26),

              const Text(
                'MON ACTIVITÉ',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Mes missions',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Retrouvez vos propositions, vos missions à venir et votre historique.',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 18),

              // Tabs
              Container(
                height: 42,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Row(
                  children: List.generate(
                    tabs.length,
                    (index) {
                      final selected = selectedTab == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 180,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.navy
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              if (selectedTab == 0)
                _buildProposal(),

              if (selectedTab == 1)
                _buildUpcomingMission(),

              if (selectedTab == 2)
                _buildPastMission(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingMission() {
    return _missionCard(
      initials: 'CP',
      establishment: 'Campanile Paris Est',
      position: 'Réceptionniste',
      date: '15 août 2026',
      hours: '07:00 — 15:00',
      status: 'En cours',
    );
  }

  Widget _buildProposal() {
    return _missionCard(
      initials: 'PU',
      establishment: 'Pullman Paris Tour Eiffel',
      position: 'Serveur',
      date: '18 août 2026',
      hours: '17:00 — 01:00',
      status: 'Proposition',
    );
  }

  Widget _buildPastMission() {
    return _missionCard(
      initials: 'NO',
      establishment: 'Novotel Paris Les Halles',
      position: 'Commis de cuisine',
      date: '22 août 2026',
      hours: '10:00 — 18:00',
      status: 'Terminée',
    );
  }

  Widget _missionCard({
    required String initials,
    required String establishment,
    required String position,
    required String date,
    required String hours,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  establishment,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  position,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 10,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 7,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Icon(
                      Icons.access_time,
                      size: 10,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      hours,
                      style: const TextStyle(
                        fontSize: 7,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _statusBadge(status),

          const SizedBox(width: 5),

          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final bool active = status == 'En cours';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.lightBlue
            : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w600,
          color: active
              ? AppColors.navy
              : AppColors.textSecondary,
        ),
      ),
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