import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/RateStarsStateless.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/EngineerRatings.dart';
import 'package:dr_tech/Pages/LiveChat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EngineerPage extends StatefulWidget {
  final id, serviceId;
  EngineerPage(this.id, this.serviceId);

  @override
  _EngineerPageState createState() => _EngineerPageState();
}

class _EngineerPageState extends State<EngineerPage> {
  bool isLoading;
  Map user = {};
  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(
        Globals.baseUrl +
            "user/engineer?id=${widget.id}&service_id=${widget.serviceId}",
         context, (r) {
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          user = r['user'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TitleBar(() {Navigator.pop(context);}, 118),
          Expanded(
              child: isLoading
                  ? Container(
                      child: CustomLoading(),
                      alignment: Alignment.center,
                    )
                  : Column(
                      textDirection: LanguageManager.getTextDirection(),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getEnginnerInfo(),
                        Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            textDirection: LanguageManager.getTextDirection(),
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: 45,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      textDirection:
                                          LanguageManager.getTextDirection(),
                                      children: [
                                        Icon(
                                          FlutterIcons.phone_faw,
                                          color: Colors.white,
                                        ),
                                        Container(
                                          width: 5,
                                        ),
                                        Text(
                                          LanguageManager.getText(96),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withAlpha(15),
                                              spreadRadius: 2,
                                              blurRadius: 2)
                                        ],
                                        borderRadius: BorderRadius.circular(12),
                                        color: Converter.hexToColor("#344f64")),
                                  ),
                                ),
                              ),
                              Container(
                                width: 10,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    startNewConversation(user['id']);
                                  },
                                  child: Container(
                                    height: 45,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      textDirection:
                                          LanguageManager.getTextDirection(),
                                      children: [
                                        Icon(
                                          Icons.chat,
                                          color:
                                              Converter.hexToColor("#344f64"),
                                          size: 20,
                                        ),
                                        Container(
                                          width: 5,
                                        ),
                                        Text(
                                          LanguageManager.getText(117),
                                          style: TextStyle(
                                              color: Converter.hexToColor(
                                                  "#344f64"),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withAlpha(15),
                                              spreadRadius: 2,
                                              blurRadius: 2)
                                        ],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Converter.hexToColor(
                                                "#344f64"))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            LanguageManager.getText(119),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            user['about'].toString(),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Converter.hexToColor("#727272")),
                          ),
                        ),
                        Container(
                          height: 10,
                        ),
                        Container(
                            height: 1,
                            margin: EdgeInsets.only(top: 2, bottom: 2),
                            color: Colors.black.withAlpha(
                              10,
                            )),
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            textDirection: LanguageManager.getTextDirection(),
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text(
                                  LanguageManager.getText(120),
                                  textDirection:
                                      LanguageManager.getTextDirection(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              EngineerRatings(widget.id)));
                                },
                                child: Text(
                                  LanguageManager.getText(121),
                                  textDirection:
                                      LanguageManager.getTextDirection(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey),
                                ),
                              )
                            ],
                          ),
                        ),
                        getComments(),
                      ],
                    ))
        ],
      ),
    );
  }

  Widget getComments() {
    List<Widget> items = [];
    for (var item in user['ratings']) {
      items.add(Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: Colors.grey,
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(Globals.correctLink(item['image'])))),
                ),
                Container(
                  width: 10,
                ),
                Column(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Row(
                      textDirection: LanguageManager.getTextDirection(),
                      children: [
                        Icon(
                          int.tryParse(item['stars']) > 2
                              ? FlutterIcons.like_fou
                              : FlutterIcons.dislike_fou,
                          color: Colors.grey,
                          size: 24,
                        ),
                        Container(
                          width: 5,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text(
                            item['name'].toString(),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Converter.hexToColor("#727272")),
                          ),
                        )
                      ],
                    ),
                    Row(
                      textDirection: LanguageManager.getTextDirection(),
                      children: [
                        Icon(
                          FlutterIcons.clock_fea,
                          color: Colors.grey,
                          size: 18,
                        ),
                        Container(
                          width: 5,
                        ),
                        Text(
                          Converter.getRealTime(item['created_at']),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Converter.hexToColor("#727272")),
                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
            Text(
              item['comment'].toString(),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Converter.hexToColor("#727272")),
            )
          ],
        ),
      ));
    }
    return Column(
      children: items,
    );
  }

  Widget getEnginnerInfo() {
    return Container(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              width: 150,
              margin: EdgeInsets.all(5),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    alignment: !LanguageManager.getDirection()
                        ? Alignment.bottomRight
                        : Alignment.bottomLeft,
                    child: user['verified'] == true
                        ? Container(
                            width: 20,
                            height: 20,
                            child: Icon(
                              FlutterIcons.check_fea,
                              color: Colors.white,
                              size: 15,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue),
                          )
                        : Container(),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(Globals.correctLink(user['image']))),
                        borderRadius: BorderRadius.circular(10),
                        color: Converter.hexToColor("#F2F2F2")),
                  ),
                ],
              ),
            ),
            Container(
              width: 10,
            ),
            Expanded(
                child: Column(
              textDirection: LanguageManager.getTextDirection(),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Expanded(
                        child: Text(
                      user['name'],
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: Converter.hexToColor("#2094CD"),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
                Text(
                  LanguageManager.getText(98) +
                      " " +
                      user['service_name'].toString(),
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                ),
                Container(
                  height: 5,
                ),
                RateStarsStateless(
                  13,
                  stars: user['rating'],
                ),
                Container(
                  height: 5,
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    SvgPicture.asset(
                      "assets/icons/services.svg",
                      width: 15,
                      height: 15,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          LanguageManager.getText(99) +
                              " " +
                              user['service_name'].toString(),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Icon(
                      FlutterIcons.location_oct,
                      size: 15,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 0),
                        child: Text(
                          user['city_name'].toString() +
                              "  - " +
                              user['street_name'].toString(),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 10,
                ),
              ],
            )),
            Container(
              height: 10,
            ),
          ],
        ));
  }

  void startNewConversation(id) {
    Alert.startLoading(context);
    NetworkManager.httpGet(Globals.baseUrl + "chat/add?id=$id",  context, (r) {
      Alert.endLoading();
      if (r['state'] == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => LiveChat(r['id'].toString())));
      }
    });
  }
}
