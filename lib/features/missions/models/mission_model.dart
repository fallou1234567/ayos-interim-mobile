class MissionModel {
  final String id;
  final String client;
  final String clientShort;
  final String employeeId;
  final String employee;
  final String role;
  final DateTime date;
  final String dateLabel;
  final String start;
  final String end;
  final double duration;
  final String status;
  final String address;
  final int headcount;
  final String? instructions;
  final String? source;
  final String? reference;

  const MissionModel({
    required this.id,
    required this.client,
    required this.clientShort,
    required this.employeeId,
    required this.employee,
    required this.role,
    required this.date,
    required this.dateLabel,
    required this.start,
    required this.end,
    required this.duration,
    required this.status,
    required this.address,
    required this.headcount,
    this.instructions,
    this.source,
    this.reference,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id']?.toString() ?? '',
      client: json['client']?.toString() ?? '',
      clientShort: json['clientShort']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employee: json['employee']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      date: DateTime.parse(json['date'].toString()),
      dateLabel: json['dateLabel']?.toString() ?? '',
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      headcount: (json['headcount'] as num?)?.toInt() ?? 1,
      instructions: json['instructions']?.toString(),
      source: json['source']?.toString(),
      reference: json['reference']?.toString(),
    );
  }

  bool get isAccepted => status.trim().toLowerCase() == 'acceptée';

  bool get isProposed => status.trim().toLowerCase() == 'proposée';

  bool isOnOrAfter(DateTime day) {
    final missionDay = DateTime(date.year, date.month, date.day);

    final targetDay = DateTime(day.year, day.month, day.day);

    return !missionDay.isBefore(targetDay);
  }
}
