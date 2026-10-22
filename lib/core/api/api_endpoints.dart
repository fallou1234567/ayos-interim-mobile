
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.ayostaff.com/api';

  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String updateProfile = '/users/me';
  static const String missions = '/missions';
}
