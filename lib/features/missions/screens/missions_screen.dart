import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/providers/home_provider.dart';
import '../models/mission_model.dart';
import 'mission_detail_sheet.dart';
import '../../../shared/widgets/app_page_header.dart';

class MissionsScreen extends StatefulWidget {
  final int initialTab;

  const MissionsScreen({super.key, this.initialTab = 1});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  late int selectedTab;

  final List<String> tabs = [
    'Propositions',
    'À venir',
    'En cours',
    'Passées',
    'Annulées',
    'Terminé',
  ];

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab.clamp(0, 5);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<HomeProvider>();

      if (provider.missions.isEmpty && !provider.isLoading) {
        provider.loadMissions();
      }
    });
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isPast(MissionModel mission) {
    final date = DateTime(
      mission.date.year,
      mission.date.month,
      mission.date.day,
    );

    return date.isBefore(_today);
  }

  List<MissionModel> _missionsForTab(HomeProvider provider) {
    final missions = provider.missions.where((mission) {
      final status = mission.status.trim().toLowerCase();

      switch (selectedTab) {
        case 0: // Propositions
          return status == 'proposée' || status == 'proposee';

        case 1: // À venir
          return (status == 'acceptée' || status == 'acceptee') &&
              !_isPast(mission);

        case 2: // En cours
          return status == 'en cours' || status == 'en_cours';

        case 3: // Passées
          return status == 'terminée' ||
              status == 'terminee' ||
              status == 'completed';

        case 4: // Annulées
          return status == 'annulée' ||
              status == 'annulee' ||
              status == 'cancelled' ||
              status == 'canceled';

        case 5: // Terminé : missions à valider
          return status == 'à valider' ||
              status == 'a valider' ||
              status == 'à_valider' ||
              status == 'a_valider';

        default:
          return false;
      }
    }).toList();

    missions.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return a.start.compareTo(b.start);
    });

    return missions;
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

  String _initials(MissionModel mission) {
    if (mission.clientShort.trim().isNotEmpty) {
      return mission.clientShort.trim().toUpperCase();
    }

    final words = mission.client
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'AY';
    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length > 1 ? 2 : 1)
          .toUpperCase();
    }

    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final missions = _missionsForTab(provider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppPageHeader(
  sectionLabel: 'MON ACTIVITÉ',
  title: 'Mes missions',
  description:
      'Retrouvez vos propositions, vos missions à venir et votre historique.',
),
                // Row(
                //   children: [
                //     Image.asset('assets/images/logo2.png', width: 70),
                //     const Spacer(),
                //     _headerIcon(Icons.wb_sunny_outlined),
                //     const SizedBox(width: 8),
                //     _headerIcon(Icons.notifications_none),
                //     const SizedBox(width: 8),
                //     const CircleAvatar(
                //       radius: 19,
                //       backgroundColor: AppColors.navy,
                //       child: Text(
                //         'AY',
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 11,
                //           fontWeight: FontWeight.w700,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 26),
                // const Text(
                //   'MON ACTIVITÉ',
                //   style: TextStyle(
                //     fontSize: 9,
                //     letterSpacing: 1.5,
                //     fontWeight: FontWeight.w700,
                //     color: AppColors.navy,
                //   ),
                // ),
                // const SizedBox(height: 8),
                // const Text(
                //   'Mes missions',
                //   style: TextStyle(
                //     fontSize: 21,
                //     fontWeight: FontWeight.w400,
                //     color: AppColors.textPrimary,
                //   ),
                // ),
                // const SizedBox(height: 7),
                // const Text(
                //   'Retrouvez vos propositions, vos missions à venir et votre historique.',
                //   style: TextStyle(
                //     fontSize: 10,
                //     color: AppColors.textSecondary,
                //   ),
                // ),
                // const SizedBox(height: 18),
                Container(
                  height: 42,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(tabs.length, (index) {
                        final selected = selectedTab == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.navy
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                if (provider.isLoading && provider.missions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.errorMessage != null &&
                    provider.missions.isEmpty)
                  _errorView(provider)
                else if (missions.isEmpty)
                  _emptyView()
                else
                  ...missions.map(
                    (mission) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _missionCard(mission),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _missionCard(MissionModel mission) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _showMissionDetails(mission),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
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
                  _initials(mission),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
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
                      mission.role,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 11,
                          color: AppColors.orange,
                        ),
                        Text(
                          _formatDate(mission.date),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Icon(
                          Icons.access_time,
                          size: 11,
                          color: AppColors.orange,
                        ),
                        Text(
                          '${mission.start} — ${mission.end}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(child: _statusBadge(mission.status)),
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

  Widget _statusBadge(String status) {
    final accepted = status.trim().toLowerCase() == 'acceptée';
    final proposed = status.trim().toLowerCase() == 'proposée';

    final color = accepted
        ? AppColors.navy
        : proposed
        ? AppColors.orange
        : AppColors.textSecondary;

    final background = accepted
        ? AppColors.lightBlue
        : proposed
        ? const Color(0xFFFFF0D5)
        : const Color(0xFFF5F6F8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }


  Widget _emptyView() {
    final messages = [
      'Aucune proposition à afficher pour le moment.',
      'Aucune mission à venir pour le moment.',
      'Aucune mission en cours pour le moment.',
      'Aucune mission passée à afficher.',
      'Aucune mission annulée à afficher.',
      'Aucune mission à valider pour le moment.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.business_center_outlined,
            size: 30,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            messages[selectedTab],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView(HomeProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            provider.errorMessage ?? 'Impossible de charger les missions.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.red, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
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
}
