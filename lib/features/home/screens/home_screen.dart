import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/greeting_section.dart';
import '../widgets/new_proposal_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildMissionStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'en cours':
        backgroundColor = AppColors.lightBlue;
        textColor = AppColors.navy;
        break;

      case 'confirmée':
        backgroundColor = AppColors.cyanLight;
        textColor = AppColors.green;
        break;

      case 'terminée':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = AppColors.green;
        break;

      case 'annulée':
        backgroundColor = const Color(0xFFFFEAEA);
        textColor = AppColors.red;
        break;

      default:
        backgroundColor = AppColors.lightBlue;
        textColor = AppColors.navy;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const String missionStatus = 'En cours';

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),

              const SizedBox(height: 25),

              const GreetingSection(),

              const SizedBox(height: 18),

              const NewProposalCard(),

              const SizedBox(height: 25),

              const Text(
                'PROCHAINE MISSION',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Votre journée en un coup d’œil',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  _buildMissionStatusBadge(missionStatus),
                ],
              ),

              const SizedBox(height: 12),

              // _buildMissionCard(),
              _buildMissionCard(missionStatus: missionStatus),

              const SizedBox(height: 10),

              _buildEstablishmentCard(),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'OPPORTUNITÉS',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'Nouvelles propositions',
                style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
              ),

              const SizedBox(height: 12),

              _buildOpportunity(
                initials: 'PU',
                title: 'Pullman Paris Tour Eiffel',
                subtitle: 'Serveur · Mar. 18 août',
                time: '17:00',
              ),

              const SizedBox(height: 8),

              _buildOpportunity(
                initials: 'NO',
                title: 'Novotel Paris Les Halles',
                subtitle: 'Commis de cuisine · Sam. 22 août',
                time: '10:00',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionCard({required String missionStatus}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business_center_outlined,
                size: 12,
                color: AppColors.orange,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Campanile Paris Est',
                  style: TextStyle(color: Colors.white70, fontSize: 9),
                ),
              ),
              Text(
                '4,2 km',
                style: TextStyle(color: Colors.white70, fontSize: 8),
              ),
            ],
          ),

          SizedBox(height: 20),

          Text(
            'Réceptionniste',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 18),

          Divider(color: Colors.white24, height: 1),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _MissionInfo(
                  label: 'Date',
                  value: '15 août 2026',
                  icon: Icons.calendar_month_outlined,
                ),
              ),
              Expanded(
                child: _MissionInfo(
                  label: 'Horaires',
                  value: '07:00 — 15:00',
                  icon: Icons.access_time,
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.orange,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '28 avenue du Général de Gaulle, Bagnolet',
                      style: TextStyle(color: Colors.white70, fontSize: 8),
                    ),
                  ],
                ),
              ),

              Text(
                '8 heures',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstablishmentCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.cyanLight,
            child: Icon(Icons.check, size: 12, color: AppColors.green),
          ),

          SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Établissement familial',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Vous avez déjà réalisé 8 missions ici.',
                style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunity({
    required String initials,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.white,
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
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Text(
            time,
            style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MissionInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MissionInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.orange),

        const SizedBox(width: 6),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 7),
            ),

            const SizedBox(height: 2),

            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
