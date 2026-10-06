class MissionModel {
  final int id;
  final String establishment;
  final String position;
  final String location;
  final String date;
  final String startTime;
  final String endTime;
  final String distance;
  final String duration;
  final String status;

  const MissionModel({
    required this.id,
    required this.establishment,
    required this.position,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.duration,
    required this.status,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] as int,
      establishment: json['establishment'] ?? '',
      position: json['position'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      distance: json['distance'] ?? '',
      duration: json['duration'] ?? '',
      status: json['status'] ?? '',
    );
  }
}