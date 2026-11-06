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

  final String? requestReference;
  final String? blockId;
  final String? blockLabel;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  final String? organizationId;
  final DateTime? clockInAt;
  final DateTime? clockOutAt;
  final double? clockedHours;

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
    this.requestReference,
    this.blockId,
    this.blockLabel,
    this.periodStart,
    this.periodEnd,
    this.organizationId,
    this.clockInAt,
    this.clockOutAt,
    this.clockedHours,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime(2000);
      return DateTime.tryParse(value.toString()) ?? DateTime(2000);
    }

    DateTime? parseOptionalDate(dynamic value) {
      if (value == null || value is Map || value is List) return null;

      final text = value.toString().trim();
      if (text.isEmpty) return null;

      return DateTime.tryParse(text);
    }

    double parseDouble(dynamic value, {double fallback = 0}) {
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? fallback;
      }
      return fallback;
    }

    int parseInt(dynamic value, {int fallback = 1}) {
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? fallback;
      }
      return fallback;
    }

    return MissionModel(
      id: json['id']?.toString() ?? '',
      client: json['client']?.toString() ?? '',
      clientShort: json['clientShort']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employee: json['employee']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      date: parseDate(json['date']),
      dateLabel: json['dateLabel']?.toString() ?? '',
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      duration: parseDouble(json['duration']),
      status: json['status']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      headcount: parseInt(json['headcount']),
      instructions: json['instructions']?.toString(),
      source: json['source']?.toString(),
      reference: json['reference']?.toString(),

      requestReference: json['requestReference']?.toString(),
      blockId: json['blockId']?.toString(),
      blockLabel: json['blockLabel']?.toString(),
      periodStart: parseOptionalDate(json['periodStart']),
      periodEnd: parseOptionalDate(json['periodEnd']),

      organizationId: json['organizationId']?.toString(),
      clockInAt: parseOptionalDate(json['clockInAt']),
      clockOutAt: parseOptionalDate(json['clockOutAt']),
      clockedHours: json['clockedHours'] == null
          ? null
          : parseDouble(json['clockedHours']),
    );
  }

  String get _normalizedStatus =>
      status.trim().toLowerCase().replaceAll('é', 'e');

  bool get isAccepted => _normalizedStatus == 'acceptee';

  bool get isProposed =>
      _normalizedStatus == 'nouvelle' ||
      _normalizedStatus == 'proposee';

  bool get isStarted =>
      _normalizedStatus == 'en cours' ||
      _normalizedStatus == 'en_cours';

  bool get isCompleted =>
      _normalizedStatus == 'terminee';

  bool get hasClockedIn => clockInAt != null;

  bool get hasClockedOut => clockOutAt != null;

  bool isOnOrAfter(DateTime day) {
    final missionDay = DateTime(date.year, date.month, date.day);
    final targetDay = DateTime(day.year, day.month, day.day);
    return !missionDay.isBefore(targetDay);
  }
}