import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';

class UserManager {
  static bool checkLogin() {
    return DatabaseManager.load(Globals.authoKey).isNotEmpty;
  }

  static void proccess(dynamic data) {
    DatabaseManager.save("user_keys", data.keys.toList());
    for (var key in data.keys) {
      DatabaseManager.save(key, data[key]);
    }
  }

  static String currentUser(key) {
    if (!UserManager.checkLogin()) return "";
    var v = DatabaseManager.load(key).toString();
    return v ?? "";
  }

  static void updateSp(key, value) {
    DatabaseManager.save(key, value);
    if(key == 'not_seen' && value > 0){
      print('here_play: updateSp');
      // AssetsAudioPlayer.newPlayer().open(Audio("assets/sounds/received.mp3"));
    }
  }


  static void logout(callback) {
    NetworkManager.httpGet(Globals.baseUrl + "users/logout", null, (userInfo) {
      DatabaseManager.unset("current_panel");
      DatabaseManager.unset(Globals.authoKey);
      var dbData = DatabaseManager.load('user_keys');
      List userKeys = dbData != "" ? dbData : [];
      for (var key in userKeys) {
        DatabaseManager.unset(key);
      }
      callback();
    });
  }

  static void refrashUserInfo({callBack}) {
    if (!UserManager.checkLogin()) {if (callBack != null) callBack(); return;}
    NetworkManager.httpGet(Globals.baseUrl + "users/profile", null, (userInfo) { // user/info
      try {
        if (userInfo['state'] == true) {
          UserManager.proccess(userInfo['data']);
          Globals.updateBottomBarNotificationCount();
          if (callBack != null) callBack();
        } else
          UserManager.logout((){if (callBack != null) callBack();});
      } catch (e) {
        // error loading info log the user out ..
      }
    });
  }

  static void update(key, value, context, callback) {
    Map<String, String> body = {key: value};

    var url =  'users/account/update';
    if(key == 'active')
      url = 'provider/status/update';

    NetworkManager.httpPost(Globals.baseUrl + url,  context, (r) { // user/update
      callback(r);
      if (r['state'] == true && key != 'active') {
        UserManager.proccess(r['data']);
      }
    }, body: body);
  }

  static void updateBody(body, context,callback) {
    NetworkManager.httpPost(Globals.baseUrl + "users/account/update",  context, (r) { // user/update
      callback(r['state']);
      if (r['state'] == true) {
        UserManager.proccess(r['data']);
      }
    }, body: body);
  }
}
