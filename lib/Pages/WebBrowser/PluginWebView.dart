import 'dart:async';
import 'dart:convert';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Pages/WebBrowser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class PluginWebView extends State<WebBrowser> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  bool willTakeLongTime = false, isPageLoading = false;

  @override
  void initState() {
    print(widget.url);
    isPageLoading = true;
    startTimer();
    super.initState();

    flutterWebviewPlugin.onStateChanged.listen((state) {
      if (state.type == WebViewState.finishLoad) {
        isPageLoading = false;
        flutterWebviewPlugin.evalJavascript("");
      }
    });
  }

  void startTimer() {
    Timer(Duration(seconds: 5), () {
      if (isPageLoading == true)
        setState(() {
          willTakeLongTime = true;
        });
    });
  }

  @override
  void dispose() {
    // flutterWebviewPlugin.dispose();

    super.dispose();
  }

//206
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.url,
      appBar: new AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            textDirection: LanguageManager.getTextDirection(),
            size: 26,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(widget.title, style: Theme.of(context).textTheme.headline6),
        ),
        actions: [
          Container(
            width: 24,
          )
        ],
      ),
      withZoom: false,
      withLocalStorage: true,
      hidden: true,
      withJavascript: true,
      javascriptChannels: Set.from([
        JavascriptChannel(
            name: "MitdoneApp",
            onMessageReceived: (JavascriptMessage e) {
              try {
                var reponce = json.decode(e.message);
                Navigator.of(context).pop(reponce);
              } catch (er) {
                Alert.show(context, er.toString());
              }
            })
      ]),
      initialChild: Container(
        color: Colors.white,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: willTakeLongTime
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomLoading(),
                      Container(
                        height: 20,
                      ),
                      Text(LanguageManager.getText(206),
                          style: Theme.of(context).textTheme.headline6),
                    ],
                  )
                : CustomLoading(),
          ),
        ),
      ),
    );
  }
}
