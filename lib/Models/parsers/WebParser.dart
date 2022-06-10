import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebParser extends StatefulWidget {
  final arg;
  WebParser(this.arg);
  @override
  _WebParserState createState() => _WebParserState();
}

class _WebParserState extends State<WebParser> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    String url = widget.arg['url'] != null ? widget.arg['url'] : null;
    return Stack(
      children: <Widget>[
        WebView(
          /* javascriptChannels: Set.from([
                      JavascriptChannel(
                          name: "MitdoneApp",
                          onMessageReceived: (JavascriptMessage e) {
                            try {
                              var reponce = json.decode(e.message);
                              if (reponce['state'] == true)
                                Navigator.of(context).pop(reponce['token']);
                            } catch (e) {
                              // error
                            }
                          })
                    ]),*/
          navigationDelegate: (n) {
            setState(() {
              loading = true;
            });
            return NavigationDecision.navigate;
          },
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: this.onPageFinished,
          onPageStarted: this.onPageStarted,
        ),
        loading
            ? Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: 50,
                  height: 50,
                  child: CustomLoading(),
                ),
              )
            : Container(),
      ],
    );
  }

  void onPageFinished(a) {
    setState(() {
      loading = false;
    });
  }

  void onPageStarted(a) {
    setState(() {
      loading = true;
    });
  }
}
