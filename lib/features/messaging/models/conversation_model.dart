class ConversationModel {
  final String id;
  final String employeeName;
  final String lastContent;
  final DateTime? lastAt;
  final int unread;

  ConversationModel({
    required this.id,
    required this.employeeName,
    required this.lastContent,
    required this.lastAt,
    required this.unread,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      lastContent: json['lastContent']?.toString() ?? '',
      lastAt: json['lastAt'] != null
          ? DateTime.tryParse(json['lastAt'].toString())
          : null,
      unread: json['unread'] is int
          ? json['unread']
          : int.tryParse(json['unread']?.toString() ?? '0') ?? 0,
    );
  }
}