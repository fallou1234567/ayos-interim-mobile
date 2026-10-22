
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../home/providers/home_provider.dart';
import '../../missions/models/mission_model.dart';
import '../../missions/screens/mission_detail_sheet.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  late DateTime selectedDate;

  static const List<String> _days = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim',
  ];

  static const List<String> _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<HomeProvider>();
      if (provider.missions.isEmpty && !provider.isLoading) {
        provider.loadMissions();
      }
    });
  }

  DateTime get _weekStart {
    final mondayOffset = selectedDate.weekday - DateTime.monday;
    return selectedDate.subtract(Duration(days: mondayOffset));
  }

  DateTime _dateForDay(int index) {
    return _weekStart.add(Duration(days: index));
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  String _normalizeStatus(String status) {
    return status.trim().toLowerCase();
  }

  bool _isAccepted(MissionModel mission) {
    final status = _normalizeStatus(mission.status);
    return status == 'acceptée' || status == 'acceptee';
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  List<MissionModel> _missionsForSelectedDay(HomeProvider provider) {
    final missions = provider.missions.where((mission) {
      return _isAccepted(mission) &&
          _sameDay(mission.date, selectedDate);
    }).toList();

    // Les heures au format HH:mm se trient chronologiquement.
    missions.sort((a, b) => a.start.compareTo(b.start));

    return missions;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final missions = _missionsForSelectedDay(provider);

    final weekStart = _weekStart;
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              AppPageHeader(
                sectionLabel:
                    'SEMAINE DU ${weekStart.day} AU ${weekEnd.day} '
                    '${_months[weekEnd.month - 1].toUpperCase()}',
                title: 'Mon planning',
                description:
                    'Vos missions confirmées, classées par horaire.',
              ),

              const SizedBox(height: 24),

              _buildWeekSelector(),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(selectedDate),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${missions.length} mission${missions.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (provider.isLoading && provider.missions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.errorMessage != null &&
                  provider.missions.isEmpty)
                _buildError(provider)
              else if (missions.isEmpty)
                _buildEmptyState()
              else
                ...missions.map(
                  (mission) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildMissionTimelineCard(mission),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    final today = DateTime.now();

    return SizedBox(
      height: 76,
      child: Row(
        children: List.generate(7, (index) {
          final date = _dateForDay(index);
          final selected = _sameDay(date, selectedDate);
          final isToday = _sameDay(date, today);

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 6 ? 0 : 5),
              child: Material(
                color: selected ? AppColors.navy : AppColors.white,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: selected
                            ? AppColors.navy
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _days[index],
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? Colors.white70
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? AppColors.orange
                                : isToday
                                    ? AppColors.orange
                                    : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMissionTimelineCard(MissionModel mission) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 57,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mission.start,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                mission.end,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 3,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(3),
          ),
        ),

        Expanded(
          child: Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _showMissionDetails(mission),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.green,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'MISSION CONFIRMÉE',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 0.7,
                              fontWeight: FontWeight.w700,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 19,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      mission.client,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),

                    Text(
                      mission.role,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.orange,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            mission.address.isEmpty
                                ? 'Adresse non renseignée'
                                : mission.address,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 15,
                          color: AppColors.orange,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${mission.start} — ${mission.end}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${mission.duration} h',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 36,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'Aucune mission confirmée',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Aucune mission acceptée n’est prévue pour cette journée.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(HomeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            provider.errorMessage ?? 'Impossible de charger le planning.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.red,
              fontSize: 12,
            ),
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
