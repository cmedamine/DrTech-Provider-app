import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Components/NotificationIcon.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/OrderDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'LiveChat.dart';

class Orders extends StatefulWidget {
    final status = ['PENDING', 'COMPLETED', 'CANCELED'];
  final bool noheader;
  Orders({this.noheader = false});

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController tabController;
  // Map<String, Map<int, List>> data = {};
  // Map<String, int> pages = {};
  List data = [];
  bool isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener((){
      print('here_listener_index: ${tabController.index}');
      print('here_listener_index: indexIsChanging ${tabController.indexIsChanging}');

     if (tabController.indexIsChanging) {
       load();
     } else {
       setState(() {
         tabController.animateTo(tabController.index);
         data = [];
         load();
       });
     }
    });
    print('here_initState_index: ${tabController.index}');
    Globals.reloadPageOrder = () {
      if (mounted) load();
    };
    load();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('here_resumed_from: Orders');
      load();
    }
  }

  void load({index}) {
    setState(() {
      print('here_setState: from here 2');
      isLoading = true;
    });
    var status = widget.status[index != null ? index : tabController.index].toLowerCase();
    // data['filter'] = status;
    // int page = 0;
    // if (pages.containsKey(status)) {
    //   page = pages[status] + 1;
    // }
    Function callback =  (r) {
      if (r['state'] == true) {
          data = r['data'];
          print('here_callback: ${data.runtimeType}');
          // pages[r['filter']] = r['page'];
          // if (!data.containsKey(r['filter'])) {
          //   data[r['filter']] = {r["page"]: r['data']};
          // } else {
          //   data[r['filter']][r["page"]] = r['data'];
          // }
      }
      setState(() {
        print('here_setState: from here 3');
        isLoading = false;
      });
    } ;
    NetworkManager.httpGet(Globals.baseUrl + "orders/?status=$status", context, callback,// orders/load?page=$page&status=$status
        cashable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          widget.noheader == true
              ? Container()
              : Container(
                  decoration:
                      BoxDecoration(color: Converter.hexToColor("#2094cd")),
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                          left: 25, right: 25, bottom: 10, top: 25),
                      child: Row(
                        textDirection: LanguageManager.getTextDirection(),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                LanguageManager.getDirection()
                                    ? FlutterIcons.chevron_right_fea
                                    : FlutterIcons.chevron_left_fea,
                                color: Colors.white,
                                size: 26,
                              )),
                          Text(
                            LanguageManager.getText(35),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          NotificationIcon(),
                        ],
                      ))),
          Row(
            textDirection: LanguageManager.getTextDirection(),
            children: [
              getTabTitle(88, 0),// LanguageManager.getTextDirection() == TextDirection.rtl? 2 : 0
              getTabTitle(89, 1),
              getTabTitle(90, 2),// LanguageManager.getTextDirection() == TextDirection.rtl? 0 : 2
            ],
          ),
          Expanded(
              child: TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            children: widget.status.map((e) {
              print('here_TabBarView: $e , arrayIndex: ${widget.status.indexOf('$e')}');

              return getPage(e.toLowerCase());
            }).toList(),
          ))
        ],
      ),
    );
  }

  Widget getPage(String status) {
    print('here_getPage: $status , currentIndex ${tabController.index}, ${widget.status[tabController.index].toLowerCase()}');
    print('here_getPage: data.length, ${data.length}');
    List<Widget> items = [];

    if(status == widget.status[tabController.index].toLowerCase())
    // if (data[status] != null) {
    //   for (var pageIndex in data[status].keys) {
        for (var item in data) {
          print('here_loop: $item');
          items.add(createOrderItem(item));
        }
    //   }
    // }

    if (data.isEmpty && isLoading) {
      return Container(
        alignment: Alignment.center,
        child: CustomLoading(),
      );
    } else if (data.isEmpty && data.length == 0) { // items.isEmpty && data[status] != null
      return EmptyPage("orders", 91);
    }
    return NotificationListener(
        child: ScrollConfiguration(
            behavior: CustomBehavior(), child: ListView(
            padding: EdgeInsets.symmetric(vertical: 0),
            children: items
        )));
  }

  Widget getTabTitle(title, index) {
    print('here_getTabTitle: title: $title, index: $index');

    // if (data[widget.status[index].toLowerCase()] == null) {
    //   load(index: index);
    // }
    return Expanded(
      child: InkWell(
          onTap: () {
            setState(() {
              print('here_setState: from here 4');
              data.clear();
              tabController.animateTo(index);
            });
          },
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(top: 15, bottom: 2),
                  child: Text(
                    LanguageManager.getText(title),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: tabController.index == index
                            ? Converter.hexToColor("#2094CD")
                            : Converter.hexToColor("#707070")),
                    textAlign: TextAlign.center,
                  )),
              Container(
                height: 1.5,
                color: tabController.index == index
                    ? Converter.hexToColor("#2094CD")
                    : Colors.transparent,
                margin: EdgeInsets.only(left: 15, right: 15),
              )
            ],
          )),
    );
  }

  Widget createOrderItem(item) {
    print('here_createOrderItem: $item');
    double size = 90;
    return InkWell(
      onTap: () async {
        var results = await Navigator.push(context, MaterialPageRoute(settings: RouteSettings(name: 'OrderDetails'), builder: (_) => OrderDetails(item)));
        print('here_setState_results: $results');
        if (results == true) {
          setState(() {
            print('here_setState: from here 1');
            // pages = {};
            data = [];
            load();
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 0),
        padding: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 2),
                  color: Colors.black.withAlpha(20),
                  spreadRadius: 2,
                  blurRadius: 4)
            ]),
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Converter.hexToColor("#F2F2F2"),
                image: DecorationImage(
                    // fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(Globals.correctLink(item['service_icon']))))
            ),
            Expanded(
              child: Column(
                textDirection: LanguageManager.getTextDirection(),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Expanded(
                        child: Text(
                          item["service_name"].toString(),
                          textDirection:
                          LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Converter.hexToColor("#2094CD")),
                        ),
                      ),
                      Container(
                        width: LanguageManager.getDirection()? 5 : 10,
                      ),
                      Row(
                        children: [
                          Container(
                            // height: 30,
                            // width: 60,
                            padding: EdgeInsets.only(left: 5, right: 7.5, top:2.5, bottom: 2.5),
                            margin: EdgeInsets.only(top: 5),
                            alignment: Alignment.center,
                            child: Text(
                              getStatusText(item["status"]),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            decoration: BoxDecoration(
                                color: Converter.hexToColor(
                                    item["status"] == 'CANCELED' || item["status"] == 'ONE_SIDED_CANCELED'
                                        ? "#f00000"
                                        : item["status"] == 'WAITING'
                                        ? "#0ec300"
                                        : "#2094CD"),
                                borderRadius: LanguageManager.getDirection()
                                    ? BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15))
                                    : BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15))),
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(
                    height: 4,
                  ),
                  Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Text(
                        LanguageManager.getText(95),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Converter.hexToColor("#2094CD")),
                      ),
                      Container(
                        width: 10,
                      ),
                      Container(
                        child: item['price'] == 0
                            ? Text(
                          LanguageManager.getText(405),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Converter.hexToColor("#2094CD")),
                        )
                      : Row(
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            Text(
                              item["price"].toString(),
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Converter.hexToColor("#2094CD")),
                            ),
                            Container(
                              width: 5,
                            ),
                            Text(
                              Globals.getUnit(isUsd: item["service_target"]),
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Converter.hexToColor("#2094CD")),
                            )
                          ],
                        ),
                        padding: EdgeInsets.only(
                            top: 2, bottom: 2, right: 10, left: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Converter.hexToColor("#F2F2F2")),
                      )
                    ],
                  ),
                  Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Icon(
                        Icons.person,
                        color: Converter.hexToColor("#C4C4C4"),
                        size: 20,
                      ),
                      Container(
                        width: 7,
                      ),
                      Text(
                        item['name'].toString(),
                        style: TextStyle(
                            color: Converter.hexToColor("#707070"),
                            fontWeight: FontWeight.normal,
                            fontSize: 14),
                        textDirection: LanguageManager.getTextDirection(),
                      )
                    ],
                  ),
                  Container(
                    height: 7,
                  ),
                  Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Icon(
                        Icons.assignment_late_outlined,
                        color: Converter.hexToColor("#C4C4C4"),
                        size: 20,
                      ),
                      Container(
                        width: 7,
                      ),
                      Text(
                        '${LanguageManager.getText(426)}${item['id'].toString()}',
                        style: TextStyle(
                            color: Converter.hexToColor("#707070"),
                            fontWeight: FontWeight.normal,
                            //height: 1.6,
                            fontSize: 14),
                        textDirection: LanguageManager.getTextDirection(),
                      ),
                    ],
                  ),

                  Container(
                    height: 7,
                  ),
                  Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Icon(
                        Icons.access_time_sharp,
                        color: Converter.hexToColor("#C4C4C4"),
                        size: 20,
                      ),
                      Container(
                        width: 7,
                      ),
                      Text(
                        Converter.getRealTime(item['created_at'].toString()),
                        style: TextStyle(
                            color: Converter.hexToColor("#707070"),
                            fontWeight: FontWeight.normal,
                            fontSize: 14),
                        textDirection: LanguageManager.getTextDirection(),
                      )
                    ],
                  ),
                  Container(
                    height: 7,
                  ),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 10), //item["service_target"] == 'online_services' ? 0 :
                        Container(width: 10),
                        (item["status"] == 'PENDING' || item["status"] == 'WAITING' || item["status"] == 'ONE_SIDED_CANCELED') //&& item["service_target"] != 'online_services'
                        ? customButton(96, () {// Call Action
                              launch('tel:${item['number_phone']}');
                            }, FlutterIcons.phone_in_talk_mco, FlutterIcons.phone_in_talk_mco)
                        : Container(),
                        Container(width: 10),
                        // item["service_target"] != 'online_services' ? Container() :
                        customButton(117, () {// Chat Action
                          Navigator.push(context, MaterialPageRoute(builder: (_) => LiveChat(item['user_id'].toString())));
                        }, FlutterIcons.message_text_mco, FlutterIcons.message_reply_text_mco),
                        Container(width: 10),
                      ]),

                  Container(
                    height: 10,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  customButton(int text, Function() onTap, IconData arIc, IconData enIc) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: (LanguageManager.getText(text).length * (LanguageManager.getDirection()? 15 : 10)).toDouble(),
          height: 34,
          alignment: Alignment.center,
          child: Row(
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LanguageManager.getDirection()? arIc:enIc,
                size: 18,
                color: Colors.white,
              ),
              Container(width: 7.5),
              Text(
                LanguageManager.getText(text),
                style: TextStyle(color: Colors.white),
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
              borderRadius: BorderRadius.circular(8),
              color: Converter.hexToColor("#344f64")),
        ),
      ),
    );
  }

  String getStatusText(status) {
    print('here_status: $status');
    return LanguageManager.getText({
          'PENDING': 93,
          'WAITING': 92,
          'COMPLETED': 94,
          'CANCELED': 184,
          'ONE_SIDED_CANCELED': 389,
        }[status.toString().toUpperCase()] ??
        92);
  }
}
