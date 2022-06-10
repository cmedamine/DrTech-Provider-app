import 'package:dr_tech/Pages/WebBrowser/BaseWebview.dart';
import 'package:dr_tech/Pages/WebBrowser/PluginWebView.dart';
import 'package:flutter/material.dart';

class WebBrowser extends StatefulWidget {
  final String url, title;
  WebBrowser(this.url, this.title);
  @override
  State<WebBrowser> createState() {
    if (url.contains("wp=true")) return PluginWebView();
    return BaseWebview();
  }
}
