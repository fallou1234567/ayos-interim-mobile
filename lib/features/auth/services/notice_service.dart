import 'package:shared_preferences/shared_preferences.dart';

class NoticeService {
  NoticeService._();

  static const String _key = 'ayos_staff_notice_v1_accepted';

  static Future<bool> hasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markAsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
