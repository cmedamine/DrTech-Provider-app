import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Pages/WebBrowser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/*
 * Router will open and manager app pages 
 * @context  as BuildCContext
 * @params url as path with page/arg1/arg2/
 */

class Router {
  static dynamic navigate(BuildContext context, String path,
      {String title: ""}) async {
    //check path type

    //Url inside app
    if (path.startsWith("app"))
      return Router.innerUrlNavigate(context, path.replaceAll("app", "http"),
          title.isNotEmpty ? context : LanguageManager.getText(0));
    // url outside app
    if (await canLaunch(path)) return Router.outerUrlNavigate(path);
    // app page

    return innerNavigate(context, path, title);
  }

  static dynamic innerNavigate(
      BuildContext context, String path, String title) {
    Map<String, String> urlParams = {};
    if (path.contains('?')) {
      String params = path.split("?")[1];
      List<String> args = params.split("&");
      for (var arg in args) {
        if (arg.contains("=")) {
          String key = arg.split("=")[0];
          String value = arg.split("=")[1];
          urlParams[key] = value;
        }
      }
      path = path.split("?")[0];
    }
    List url = path.split("/");
    if (url.length == 0) return false;

    String page = url[0];

    if (urlParams['page_title'] != null) title = urlParams['page_title'];

    title = Converter.getRealText(title);
  }

  static dynamic innerUrlNavigate(
      BuildContext context, String url, String title) {
    return Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebBrowser(url, title)));
  }

  static dynamic outerUrlNavigate(path) {
    launch(path);
  }
}
