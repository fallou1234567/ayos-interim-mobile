
import 'package:flutter/foundation.dart';

import '../../missions/data/mission_service.dart';
import '../../missions/models/mission_model.dart';

class HomeProvider extends ChangeNotifier {
  final MissionService _missionService;

  HomeProvider({MissionService? missionService})
      : _missionService = missionService ?? MissionService();

  bool _isLoading = false;
  String? _errorMessage;
  List<MissionModel> _missions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  List<MissionModel> get _upcomingMissions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _missions.where((mission) {
      return mission.isOnOrAfter(today);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  MissionModel? get nextMission {
    final accepted = _upcomingMissions
        .where((mission) => mission.isAccepted)
        .toList();

    return accepted.isEmpty ? null : accepted.first;
  }

  List<MissionModel> get opportunities {
    return _upcomingMissions
        .where((mission) => mission.isProposed)
        .toList();
  }

  int get opportunityCount => opportunities.length;
}
