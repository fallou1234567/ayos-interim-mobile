import '../../models/mission_model.dart';

class MockHomeService {
  Future<MissionModel> getCurrentMission() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    return const MissionModel(
      id: 1,
      establishment: 'Campanile Paris Est',
      position: 'Réceptionniste',
      location: '28 avenue du Général de Gaulle, Bagnolet',
      date: '15 août 2026',
      startTime: '07:00',
      endTime: '15:00',
      distance: '4,2 km',
      duration: '8 heures',
      status: 'En cours',
    );
  }
}