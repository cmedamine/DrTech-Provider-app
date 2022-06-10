import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/OnlineEngineerServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class OnlineServices extends StatefulWidget {
  const OnlineServices();

  @override
  _OnlineServicesState createState() => _OnlineServicesState();
}

class _OnlineServicesState extends State<OnlineServices> {
  bool isLoading = false;
  String search = "";
  List data = [];
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
        Globals.baseUrl + "/services/loadSubCatigories?search=$search",  context, (r) {
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          data = r['data'];
        });
      }
    }, cashable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          TitleBar(() {Navigator.pop(context);}, 273),
          getSearch(),
          Expanded(
              child: isLoading ? Center(child: CustomLoading()) : getBody())
        ]));
  }

  Widget getSearch() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      padding: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
          color: Converter.hexToColor("#F2F2F2"),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Expanded(
            child: TextField(
              onSubmitted: (t) {
                search = t;
                load();
              },
              textDirection: LanguageManager.getTextDirection(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                  hintText: LanguageManager.getText(102),
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  hintTextDirection: LanguageManager.getTextDirection(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
            ),
          ),
          Container(
            child: Icon(
              FlutterIcons.search_fea,
              size: 20,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget getBody() {
    List<Widget> items = [];

    for (var item in data) {
      items.add(InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      OnlineEngineerServices(item['id'], item['name'])));
        },
        child: Container(
          height: MediaQuery.of(context).size.width * 0.46,
          margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          alignment: Alignment.bottomRight,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 2),
                    color: Colors.black.withAlpha(20),
                    spreadRadius: 2,
                    blurRadius: 2)
              ],
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(Globals.correctLink(item['image'])))),
          child: Container(
            margin: EdgeInsets.all(10),
            child: Text(
              item["name"],
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Converter.hexToColor("#2094CD")),
            ),
          ),
        ),
      ));
    }

    return Container(
      child: ScrollConfiguration(
        behavior: CustomBehavior(),
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          children: items,
        ),
      ),
    );
  }
}
