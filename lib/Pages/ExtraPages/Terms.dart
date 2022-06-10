import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';

class Terms extends StatefulWidget {
  const Terms();

  @override
  _TermsState createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  bool isLoading = false;
  var data;
  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "privacy/policy",  context, (r) { // information/terms
      setState(() {
        isLoading = false;
        data = r['data'];
      });
    }, cashable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          TitleBar((){Navigator.pop(context);}, 59, without: true),
          Expanded(
              child: isLoading
                  ? Center(
                      child: CustomLoading(),
                    )
                  : ScrollConfiguration(
                      behavior: CustomBehavior(),
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: ListView(
                          padding: EdgeInsets.symmetric(vertical: 0),
                          children: data.toString().split("\n").map((e) {
                            bool isTitel = e.startsWith("*");
                            return Text(
                              isTitel ? e.replaceFirst("*", "") : e.toString(),
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  fontSize: isTitel ? 16 : 14,
                                  fontWeight: isTitel
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isTitel ? Colors.blue : Colors.black),
                            );
                          }).toList(),
                        ),
                      ),
                    ))
        ]));
  }
}
