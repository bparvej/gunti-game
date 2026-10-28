import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static const key = 'bangla_guti_v2';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? read() {
    return _prefs?.getString(key);
  }

  static void write(String value) {
    _prefs?.setString(key, value);
  }
}

