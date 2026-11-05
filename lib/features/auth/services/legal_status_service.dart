import '../../../core/api/api_client.dart';

class LegalStatusService {
  static final _dio = ApiClient.instance.dio;

  static Future<Map<String, dynamic>> getStatus() async {
    final response = await _dio.get('/legal/status');

    return Map<String, dynamic>.from(response.data);
  }
}