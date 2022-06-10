import 'dart:convert';

import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:intl/intl.dart';

class ServerLogger {
  static void flush() {
    Map<String, String> body = {};
    body['error'] = DatabaseManager.load("errors_log");

    NetworkManager.httpPost(Globals.baseUrl + "AppLogger/flush",  null, (r) {
      if (r['state'] == true) {
        DatabaseManager.unset("errors_log");
      }
    });
  }

  static void push(String error) {
    var saved = {};
    var savedData = DatabaseManager.load("errors_log");
    try {
      if (savedData != "") {
        saved = json.decode(savedData);
      } else {
        saved = {};
      }
    } catch (e) {
      saved = {};
    }
    String formattedDate = DateFormat('Y-m-d kk:mm:ss').format(DateTime.now());
    if (!saved.values.contains(error)) {
      saved[formattedDate] = error;
    }

    var maxLog = Globals.getConfig("max_log");
    if (maxLog == "" || maxLog.runtimeType != null) {
      maxLog = 5;
    }

    DatabaseManager.save("errors_log", json.encode(saved));

    if (saved.length > maxLog) {
      ServerLogger.flush();
    }
  }
}
