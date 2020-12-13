import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {

  static const String BOARD_TYPE = "BOARD_TYPE";
  static const String DEFAULT_BOARD_TYPE = "Brown";

  static const String DIFFICULTY = "DIFFICULTY";
  static const int DEFAULT_DIFFICULTY = 1;

  static Future<String> getBoardType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(BOARD_TYPE) ?? DEFAULT_BOARD_TYPE;
  }

  static Future<bool> setBoardType(String type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(BOARD_TYPE, type);
  }

  static Future<int> getDifficulty() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(DIFFICULTY) ?? DEFAULT_DIFFICULTY;
  }

  static Future<bool> setDifficulty(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(DIFFICULTY, value);
  }
}