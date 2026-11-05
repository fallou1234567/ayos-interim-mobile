class MessageModel {
  final int id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final DateTime? createdAt;
  final bool unreadForViewer;
  final bool read;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.createdAt,
    required this.unreadForViewer,
    required this.read,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      senderRole: json['senderRole']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      unreadForViewer: json['unreadForViewer'] == true,
      read: json['read'] == true,
    );
  }
}