
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/LiveChat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Conversations extends StatefulWidget {
  final bool noheader;
  const Conversations({this.noheader = false});

  @override
  _ConversationsState createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations>   with WidgetsBindingObserver {
  Map<int, List> data = {};
  int page = 0;
  bool isLoading;
  var responseBody;

  _onLayoutDone(_) {
    //do your stuff
    print('here_: _onLayoutDone');
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_onLayoutDone);
    WidgetsBinding.instance.addObserver(this);
    print('here_not_seen: initState Conversations');
    Globals.updateConversationCount = (){print('here_not_seen: Conversations $mounted');if(mounted)load();};
    load();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      load();
    }
  }



  void load() {
    setState(() { isLoading = true; });

    NetworkManager.httpGet(Globals.baseUrl + "provider/convertations",  context, (r) { // chat/conversations?page=$page

      setState(() { isLoading = false; });

      if (r['state'] == true) {
        responseBody = r;
        setState(() {
          // page++;
          data[page] = r['data'];// data[r['page']] = r['data'];
        });
      }
    }, cashable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getChatConversations(),
    );
  }

  Widget getChatConversations() {
    List<Widget> items = [];
    for (var page in data.keys) {
      for (var item in data[page]) {
        items.add(getConversationItem(item, items.length));
      }
    }

    if (items.length == 0 && isLoading) {
      return Container(
        alignment: Alignment.center,
        child: CustomLoading(),
      );
    } else if (data[0].length == 0 && !isLoading) { // items.length > 0 && data[0].length == 0
      return EmptyPage("conversation", 97);
    }

    return Recycler(
      children: items,
      onScrollDown: () {
        // if (!isLoading) {
        //   if (data.length > 0 && data[0].length == 0) return;
        //   load();
        // }
      },
    );
  }

  Widget getConversationItem(item, int length) {
    return InkWell(
      onTap: () async {
        if (UserManager.currentUser("chat_not_seen").isNotEmpty && item['count_not_seen'] != null )
            UserManager.updateSp("chat_not_seen", (int.parse(UserManager.currentUser("chat_not_seen")) - item['count_not_seen']));
        Globals.updateBottomBarNotificationCount();
        item['count_not_seen'] = 0;
        setState(() {});
        responseBody['data'][length] = item;
        DatabaseManager.save(Globals.baseUrl + "provider/convertations", jsonEncode(responseBody));
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => LiveChat(item["user_id"].toString())));
        if(result == true)
          load();
      },
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 3),
                  color: Colors.black.withAlpha(10),
                  spreadRadius: 2,
                  blurRadius: 2)
            ]),
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              margin: EdgeInsets.all(10),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  image: DecorationImage(image: CachedNetworkImageProvider(Globals.correctLink(item['user']['image']))),
                  borderRadius: BorderRadius.circular(10)),
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Text(
                  item['user']['name']??'',
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Converter.hexToColor("#2094CD")),
                ),
                item['last_chat_date'] == false
                    ? Container()
                    : Text(
                        Converter.getRealTime(item['last_chat_date']),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Converter.hexToColor("#707070")),
                      )
              ],
            )),
            item['count_not_seen'] != null && item['count_not_seen'] > 0 ?
            Container(
              margin: EdgeInsets.only(top: 4, left: 5, right: 5),
              alignment: Alignment.center,
              width: 20,
              height: 20,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Colors.blue),
              child: Text(
                  item['count_not_seen'] > 99 ? '99+' : item['count_not_seen'].toString(),
                  style: TextStyle(fontSize: 10, color: Colors.white,fontWeight: FontWeight.w900 ),
                  textAlign: TextAlign.center),
            ): Container(),
            Container(
              child: Icon(
                LanguageManager.getDirection()
                    ? FlutterIcons.chevron_left_fea
                    : FlutterIcons.chevron_right_fea,
                color: Converter.hexToColor("#2094CD"),
                size: 24,
              ),
            ),
            Container(
              width: 15,
            )
          ],
        ),
      ),
    );
  }
}
