import '../../../core/api/api_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  MessagingService._();

  static final _dio = ApiClient.instance.dio;

  /// Récupérer les conversations
  static Future<Map<String, dynamic>> getConversations() async {
    final response = await _dio.get('/messaging/conversations');

    final data = Map<String, dynamic>.from(response.data);

    final conversations = (data['conversations'] as List? ?? [])
        .map(
          (item) => ConversationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    return {
      'conversations': conversations,
      'unread': data['unread'] ?? 0,
      'ownId': data['ownId']?.toString(),
      'canSend': data['canSend'] == true,
    };
  }

  /// Récupérer les messages d'une conversation
  static Future<List<MessageModel>> getMessages(String conversationId) async {
    final response = await _dio.get(
      '/messaging/conversations/$conversationId/messages',
    );

    final data = Map<String, dynamic>.from(response.data);

    return (data['messages'] as List? ?? [])
        .map((item) => MessageModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Envoyer un message
/// Envoyer un message
static Future<void> sendMessage({
  required String conversationId,
  required String clientId,
  required String content,
}) async {
  final payload = {
    'clientId': clientId,
    'content': content,
  };

  try {
    debugPrint('========== ENVOI MESSAGE ==========');
    debugPrint('Conversation ID : $conversationId');
    debugPrint('Client ID       : $clientId');
    debugPrint('Contenu         : $content');
    debugPrint('Payload         : $payload');

    final response = await _dio.post(
      '/messaging/conversations/$conversationId/messages',
      data: payload,
    );

    debugPrint('========== MESSAGE ENVOYÉ ==========');
    debugPrint('STATUS  : ${response.statusCode}');
    debugPrint('REPONSE : ${response.data}');
  } on DioException catch (e) {
    debugPrint('========== ERREUR MESSAGERIE ==========');
    debugPrint('STATUS          : ${e.response?.statusCode}');
    debugPrint('REPONSE SERVEUR : ${e.response?.data}');
    debugPrint('REQUETE         : ${e.requestOptions.data}');
    debugPrint('URL             : ${e.requestOptions.uri}');
    debugPrint('HEADERS         : ${e.requestOptions.headers}');
    rethrow;
  } catch (e, stackTrace) {
    debugPrint('ERREUR INATTENDUE : $e');
    debugPrint('$stackTrace');
    rethrow;
  }
}

  /// Marquer des messages comme lus.
  static Future<void> markAsRead({
    required String conversationId,
    required List<int> messageIds,
  }) async {
    if (messageIds.isEmpty) return;

    await _dio.post(
      '/messaging/conversations/$conversationId/read',
      data: {'messageIds': messageIds},
    );
  }
}
