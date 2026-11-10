import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/mission_model.dart';
import 'package:flutter/foundation.dart';

class MissionService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<MissionModel>> getMissions() async {
    try {
      final response = await _dio.get(ApiEndpoints.missions);

      final data = response.data;

      if (data is! List) {
        throw Exception(
          'Le format des missions retourné par le serveur est invalide.',
        );
      }

      return data
          .map(
            (item) =>
                MissionModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;

      if (e.response?.statusCode == 401) {
        throw Exception('Votre session a expiré. Veuillez vous reconnecter.');
      }

      if (data is Map && data['message'] != null) {
        final message = data['message'];

        if (message is List) {
          throw Exception(message.map((item) => item.toString()).join('\n'));
        }

        throw Exception(message.toString());
      }

      if (e.response == null) {
        throw Exception(
          'Impossible de joindre le serveur. Vérifiez votre connexion Internet.',
        );
      }

      throw Exception(
        'Erreur lors du chargement des missions '
        '(${e.response?.statusCode}).',
      );
    } on FormatException {
      throw Exception('Les données des missions reçues sont invalides.');
    }
  }

  Future<void> acceptMission(String reference) async {
    await _postAction('/missions/$reference/accept');
  }

  Future<void> declineMission({
    required String reference,
    required String reason,
    String? comment,
  }) async {
    await _postAction(
      '/missions/$reference/decline',
      data: {
        'reason': reason,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
    );
  }

  Future<void> cancelMission(String reference) async {
    await _postAction('/missions/$reference/cancel');
  }

  String _normalizeQrToken(String value) {
    const prefix = 'ayos:clocking:v1:';

    final token = value.trim();

    if (token.startsWith(prefix)) {
      return token.substring(prefix.length).trim();
    }

    if (token.isEmpty) {
      throw Exception('Le QR Code est invalide.');
    }

    return token;
  }

  Future<void> startMission({
    required String reference,
    required String qrToken,
  }) async {
    final token = _normalizeQrToken(qrToken);

    debugPrint('========== POINTAGE ENTREE ==========');
    debugPrint('MISSION : $reference');
    debugPrint('QR TOKEN : $token');

    await _postAction('/missions/$reference/start', data: {'qrToken': token});
  }

  Future<void> submitMissionHours({
    required String reference,
    required String qrToken,
  }) async {
    final token = _normalizeQrToken(qrToken);

    debugPrint('========== POINTAGE SORTIE ==========');
    debugPrint('MISSION : $reference');
    debugPrint('QR TOKEN : $token');

    await _postAction('/missions/$reference/hours', data: {'qrToken': token});
  }

  Future<void> _postAction(String path, {Map<String, dynamic>? data}) async {
    try {
      debugPrint('API POST : $path');
      debugPrint('BODY : $data');

      final response = await _dio.post(path, data: data);

      debugPrint('HTTP STATUS : ${response.statusCode}');
      debugPrint('HTTP RESPONSE : ${response.data}');
    } on DioException catch (e) {
      debugPrint('DIO ERROR : ${e.message}');
      debugPrint('HTTP STATUS ERROR : ${e.response?.statusCode}');
      debugPrint('HTTP RESPONSE ERROR : ${e.response?.data}');

      final responseData = e.response?.data;

      if (responseData is Map && responseData['message'] != null) {
        final message = responseData['message'];

        if (message is List) {
          throw Exception(message.map((item) => item.toString()).join('\n'));
        }

        throw Exception(message.toString());
      }

      if (e.response == null) {
        throw Exception(
          'Impossible de joindre le serveur. Vérifiez votre connexion.',
        );
      }

      throw Exception('L’action a échoué (${e.response?.statusCode}).');
    }
  }
}
