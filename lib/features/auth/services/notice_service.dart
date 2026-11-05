import '../../../core/api/api_client.dart';
import '../models/legal_document_model.dart';

class NoticeService {
  NoticeService._();

  static final _dio = ApiClient.instance.dio;

  /// Récupère les documents juridiques destinés aux salariés.
  static Future<List<LegalDocumentModel>> getLegalDocuments() async {
    final response = await _dio.get(
      '/legal/documents',
      queryParameters: {'role': 'EMPLOYEE'},
    );

    final data = response.data;

    if (data is! List) {
      throw Exception('Format de réponse des documents invalide.');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(LegalDocumentModel.fromJson)
        .toList();
  }

  /// Vérifie le statut juridique de l'utilisateur connecté.
  static Future<Map<String, dynamic>> getLegalStatus() async {
    final response = await _dio.get('/legal/status');

    if (response.data is! Map) {
      throw Exception('Format du statut juridique invalide.');
    }

    return Map<String, dynamic>.from(response.data);
  }

  /// Enregistre uniquement l'acceptation des CGU.
  static Future<void> acceptTerms(String documentId) async {
    await _dio.post(
      '/legal/acceptances',
      data: {'documentId': documentId, 'accepted': true},
    );
  }

  /// Enregistre la prise de connaissance de la notice d'information.
  static Future<void> acknowledgeNotice(String documentId) async {
    await _dio.post(
      '/legal/information-receipts',
      data: {'documentId': documentId},
    );
  }
}
