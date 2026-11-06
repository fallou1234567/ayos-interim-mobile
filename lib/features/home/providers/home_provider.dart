import 'package:flutter/foundation.dart';

import '../../missions/data/mission_service.dart';
import '../../missions/models/mission_model.dart';

class HomeProvider extends ChangeNotifier {
  final MissionService _missionService = MissionService();

  List<MissionModel> _missions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MissionModel> get missions => List.unmodifiable(_missions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isUpcoming(MissionModel mission) {
    final date = DateTime(
      mission.date.year,
      mission.date.month,
      mission.date.day,
    );

    return !date.isBefore(_today);
  }

  // Missions proposées, regroupées par demande.
  List<List<MissionModel>> get opportunityGroups {
    final proposed = _missions
        .where((mission) => mission.isProposed && _isUpcoming(mission))
        .toList();

    proposed.sort((a, b) => a.date.compareTo(b.date));

    final Map<String, List<MissionModel>> groups = {};

    for (final mission in proposed) {
      final reference = mission.requestReference?.trim();

      // Sans requestReference, on conserve une carte individuelle.
      final key = reference == null || reference.isEmpty
          ? 'MISSION_${mission.id}'
          : reference;

      groups.putIfAbsent(key, () => []).add(mission);
    }

    return groups.values.map((group) {
      group.sort((a, b) => a.date.compareTo(b.date));
      return List<MissionModel>.unmodifiable(group);
    }).toList();
  }

  // Conservé si d'autres widgets utilisent encore opportunities.
  List<MissionModel> get opportunities =>
      opportunityGroups.map((group) => group.first).toList();

  MissionModel? get nextMission {
    final accepted = _missions
        .where((mission) => mission.isAccepted && _isUpcoming(mission))
        .toList();

    accepted.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      return a.start.compareTo(b.start);
    });

    return accepted.isEmpty ? null : accepted.first;
  }

  int get opportunitiesCount => opportunityGroups.length;

  Future<void> loadMissions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _missions = await _missionService.getMissions();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadMissions();
}