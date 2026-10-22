import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../missions/models/mission_model.dart';
import '../providers/home_provider.dart';
// import '../widgets/home_header.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../widgets/new_proposal_card.dart';
import '../../missions/screens/mission_detail_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().loadMissions();
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildStatusBadge(String status) {
    final normalized = status.trim().toLowerCase();

    final Color background;
    final Color foreground;

    switch (normalized) {
      case 'acceptée':
        background = AppColors.cyanLight;
        foreground = AppColors.green;
        break;
      case 'proposée':
        background = AppColors.lightBlue;
        foreground = AppColors.navy;
        break;
      case 'terminée':
        background = const Color(0xFFE8F5E9);
        foreground = AppColors.green;
        break;
      case 'annulée':
        background = const Color(0xFFFFEAEA);
        foreground = AppColors.red;
        break;
      default:
        background = AppColors.lightBlue;
        foreground = AppColors.navy;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }

  Widget _buildMissionCard(MissionModel mission) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business_center_outlined,
                size: 14,
                color: AppColors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mission.client,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            mission.role,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _missionInfo(
                  'Date',
                  _formatDate(mission.date),
                  Icons.calendar_month_outlined,
                ),
              ),
              Expanded(
                child: _missionInfo(
                  'Horaires',
                  '${mission.start} — ${mission.end}',
                  Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.orange,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  mission.address.isEmpty
                      ? 'Adresse non renseignée'
                      : mission.address,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${mission.duration} h',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _missionInfo(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.orange),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 9),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpportunity(MissionModel mission) {
    final initials = mission.clientShort.isNotEmpty
        ? mission.clientShort
        : mission.client.isNotEmpty
        ? mission.client
              .substring(0, mission.client.length >= 2 ? 2 : 1)
              .toUpperCase()
        : 'AY';

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _showMissionDetails(mission),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
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
                      mission.client,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${mission.role} · ${_formatDate(mission.date)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _buildStatusBadge(mission.status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                mission.start,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(HomeProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.errorMessage ?? 'Impossible de charger les missions.',
            style: const TextStyle(color: AppColors.red, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: provider.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _showMissionDetails(MissionModel mission) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (_) => MissionDetailSheet(
        mission: mission,
        onUpdated: () => context.read<HomeProvider>().refresh(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final homeProvider = context.watch<HomeProvider>();
    final user = authProvider.user;

    final firstName = user?.firstName.trim() ?? '';
    final greetingName = firstName.isNotEmpty ? firstName : 'Utilisateur';

    final nextMission = homeProvider.nextMission;
    final opportunities = homeProvider.opportunities;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: homeProvider.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPageHeader(
                  title: 'Bonjour $greetingName 👋',
                  description: 'Vos missions et votre planning vous attendent.',
                ),
                const SizedBox(height: 25),

                // Text(
                //   'Bonjour $greetingName 👋',
                //   style: const TextStyle(
                //     fontSize: 22,
                //     fontWeight: FontWeight.w700,
                //     color: AppColors.navy,
                //   ),
                //),
                // const SizedBox(height: 6),
                // const Text(
                //   'Vos missions et votre planning vous attendent.',
                //   style: TextStyle(
                //     fontSize: 13,
                //     color: AppColors.textSecondary,
                //   ),
                // ),
                const SizedBox(height: 18),
                const NewProposalCard(),
                const SizedBox(height: 25),

                const Text(
                  'PROCHAINE MISSION',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Votre journée en un coup d’œil',
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),

                if (homeProvider.isLoading && homeProvider.missions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (homeProvider.errorMessage != null &&
                    homeProvider.missions.isEmpty)
                  _buildError(homeProvider)
                else if (nextMission != null) ...[
                  _buildStatusBadge(nextMission.status),
                  const SizedBox(height: 10),
                  _buildMissionCard(nextMission),
                ] else
                  _emptyMessage(
                    'Aucune mission acceptée à venir pour le moment.',
                  ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'OPPORTUNITÉS',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${homeProvider.opportunitiesCount}',
                        style: const TextStyle(
                          fontSize: 10,
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

                if (homeProvider.isLoading && homeProvider.missions.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (homeProvider.errorMessage != null &&
                    homeProvider.missions.isEmpty)
                  _buildError(homeProvider)
                else if (opportunities.isEmpty)
                  _emptyMessage('Aucune nouvelle proposition pour le moment.')
                else
                  ...opportunities.map(
                    (mission) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildOpportunity(mission),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}
