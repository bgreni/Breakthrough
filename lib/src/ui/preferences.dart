import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {

  static const String BOARD_TYPE = "BOARD_TYPE";
  static const String DEFAULT_BOARD_TYPE = "Brown";

  static const String A1DIFFICULTY = "A1DIFFICULTY";
  static const String A2DIFFICULTY = "A2DIFFICULTY";
  static const int DEFAULT_DIFFICULTY = 1;

  static Future<String> getBoardType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(BOARD_TYPE) ?? DEFAULT_BOARD_TYPE;
  }

  static Future<bool> setBoardType(String type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(BOARD_TYPE, type);
  }

  static Future<int> getA1Difficulty() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(A1DIFFICULTY) ?? DEFAULT_DIFFICULTY;
  }

  static Future<bool> setA1Difficulty(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(A1DIFFICULTY, value);
  }

  static Future<int> getA2Difficulty() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(A2DIFFICULTY) ?? DEFAULT_DIFFICULTY;
  }

  static Future<bool> setA2Difficulty(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(A2DIFFICULTY, value);
  }
}