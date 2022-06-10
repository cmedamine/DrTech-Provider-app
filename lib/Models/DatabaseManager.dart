import 'dart:convert';

import 'package:dr_tech/Config/Globals.dart';

class DatabaseManager {
  static Map<String, dynamic> liveDatabase = {};

  static void save(key, val) {

    if(val.runtimeType.toString() == 'List<dynamic>')
      Globals.sharedPreferences.setString(key, json.encode(val));

    if(val.runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>')
      Globals.sharedPreferences.setString(key, json.encode(val));

    if (val.runtimeType.toString() == "List<String>")
      Globals.sharedPreferences.setStringList(key, val);

    if (val is String) Globals.sharedPreferences.setString(key, val);

    if (val is bool) Globals.sharedPreferences.setBool(key, val);

    if (val is double) Globals.sharedPreferences.setDouble(key, val);

    if (val is int) Globals.sharedPreferences.setInt(key, val);
  }

  static void setUserSettings(key, value) {
    var a = DatabaseManager.load("_userSettings");
    List<String> userSettings =
        a.runtimeType == String ? [] : List<String>.from(a);
    if (!userSettings.contains(key)) userSettings.add(key);

    DatabaseManager.save("_userSettings", userSettings);
    DatabaseManager.save("settings_" + key, value);
  }

  static void removeUserSettings(key) {
    List userSettings = DatabaseManager.load("_userSettings");
    userSettings = userSettings.runtimeType == String ? [] : userSettings;
    if (userSettings.contains(key)) userSettings.remove(key);

    DatabaseManager.save("_userSettings", userSettings);
    DatabaseManager.unset("settings_" + key);
  }

  static String getUserSettings(key) {
    // print('getUserSettings: ${DatabaseManager.load("settings_" + key)}');
    return DatabaseManager.load("settings_" + key);
  }

  static Map getUserSettinsgAsMap() {
    Map<String, String> data = {};
    var userSettings = DatabaseManager.load("_userSettings");
    userSettings = userSettings.runtimeType == String ? [] : userSettings;

    for (var i = 0; i < userSettings.length; i++)
      data["x-user-" + userSettings[i]] =
          DatabaseManager.load("settings_" + userSettings[i]);

    return data;
  }

  static void clear() {
    Globals.sharedPreferences.clear();
  }

  static void unset(key) {
    Globals.sharedPreferences.remove(key);
  }

  static dynamic load(key) {
    return Globals.sharedPreferences == null
        ? ""
        : (Globals.sharedPreferences.get(key) ?? "");
  }
}
