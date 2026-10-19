import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email.trim(), 'password': password},
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final token = data['accessToken']?.toString();

      if (token == null || token.isEmpty) {
        throw Exception('Le serveur n’a pas retourné de token d’accès.');
      }

      await TokenStorage.saveTokens(accessToken: token);

      final userJson = Map<String, dynamic>.from(data['user'] as Map);
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiEndpoints.me);
      return UserModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException {
      await TokenStorage.clear();
      rethrow;
    } finally {
      await TokenStorage.clear();
    }
  }

  String _errorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      final message = data['message'];

      if (message is List) {
        return message.map((item) => item.toString()).join('\n');
      }

      return message.toString();
    }

    if (e.response?.statusCode == 401) {
      return 'E-mail ou mot de passe incorrect, ou session expirée.';
    }

    if (e.response == null) {
      return 'Impossible de joindre le serveur. Vérifie ta connexion Internet.';
    }

    return 'Une erreur est survenue (${e.response?.statusCode}).';
  }
}
