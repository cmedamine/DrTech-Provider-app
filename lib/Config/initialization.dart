import 'dart:io';

import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Models/Firebase.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Initialization {
  Initialization(callback) {
    if(Platform.isAndroid)
    FlutterSimCountryCode.simCountryCode.then((value) {
    //   print('$value');
      DatabaseManager.liveDatabase["country"] = value.toString(); //value.toString(); // 'DZ'
      FirebaseClass(() {
        PackageInfo.fromPlatform().then((info) {
          Globals.version = info.version;
          Globals.buildNumber = info.buildNumber;
          this.init(callback);
          print('heree: ${Globals.version}');
          print('heree: ${Globals.buildNumber}');
        });
      });
    });
    else {
      DatabaseManager.liveDatabase["country"] = 'SA'; //value.toString(); // 'DZ'
      FirebaseClass(() {
        PackageInfo.fromPlatform().then((info) {
          Globals.version = info.version;
          Globals.buildNumber = info.buildNumber;
          this.init(callback);
          print('heree: ${Globals.version}');
          print('heree: ${Globals.buildNumber}');
        });
      });
    }
  }

  bool configLoad = false;
  bool profileLoad = false;

  void init(callback) async {
    Globals.sharedPreferences = await SharedPreferences.getInstance();

    //if (DatabaseManager.getUserSettings("localization") != null) callback();
    Map<String, String> body = {
      "code": DatabaseManager.liveDatabase["code"].toString()
    };
    NetworkManager.httpPost(Globals.baseUrl + "config",  Globals.contextLoading, (r) { // main/configuration
      // print('settings: ${r['config'].r['settings']}');
      if (r['state'] == true) {
        // read configs
        Globals.config = r['data']['config'];
        Globals.settings = Globals.getConfig('settings');
        LanguageManager.init(r['data']['localisation']);
        dataSetup();
        configLoad = true;
        goNext(callback);
        //callback();
      }
    }, body: body, cachable: isSecond ? false : true );

    UserManager.refrashUserInfo(callBack: (){
      profileLoad = true;
      goNext(callback);
    });
  }

  bool re = true, isSecond = false;

  void goNext(callback) {
    if(configLoad && profileLoad){
      configLoad = false;
      profileLoad = false;

      print('here_url_server: ${Globals.getValueInConfigSetting('resend_time')}');
      if(Globals.getValueInConfigSetting('resend_time').toString() == '61' && re){
        print('here_url_server: 1');
        re = false;
        isSecond = true;
        Globals.urlServerGlobal = "https://drtech.takiddine.co";
        Globals.baseUrl = "https://drtech.takiddine.co/api/";
        init(callback);
      }
      else {
        print('here_url_server: 2');
        callback();
      }
    }
  }

  void dataSetup() {
    var country = DatabaseManager.liveDatabase["country"];
    var countries = Globals.getConfig("countries");
    var selectedCity = DatabaseManager.load("citie");
    if (countries != "")
      for (var item in countries) {
        if (item["code"].toString().toLowerCase() ==
            country.toString().toLowerCase()) {
          DatabaseManager.liveDatabase["country_cities"] = item['cities'];
          if (selectedCity == "" &&
              item['cities'] != null &&
              item['cities'].length > 0) {
            DatabaseManager.liveDatabase["city"] = item['cities'][0];
          } else {
            for (var citie in item['cities']) {
              if (citie['id'] == selectedCity)
                DatabaseManager.liveDatabase["city"] = citie;
            }
          }
        }
      }
  }

}
