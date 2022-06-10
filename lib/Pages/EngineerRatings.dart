import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class EngineerRatings extends StatefulWidget {
  final id;
  EngineerRatings(this.id);

  @override
  _EngineerRatingsState createState() => _EngineerRatingsState();
}

class _EngineerRatingsState extends State<EngineerRatings> {
  Map<int, List<dynamic>> data = {};
  int page = 0;
  bool isLoading = false;
  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    //   setState(() {isLoading = false;});
    //   setState(() {
    //       data[0] = [
    //     {
    //         "name": "مزود خدمة",
    //         "image": "https://server.drtechapp.com/storage/images/60daf872ea0f0.jpg",
    //         "created_at": "2021-07-06 10:31:47",
    //         "comment": "شخص متعاون و خلوق . شكرا",
    //         "stars": "1"
    //     },
    //     {
    //         "name": "هاني القحطاني",
    //         "image": "https://server.drtechapp.com/storage/images/default.jpg",
    //         "created_at": "2021-07-27 09:56:28",
    //         "comment": "dvsdvsdv",
    //         "stars": "5"
    //     },
    //     {
    //         "name": "hani",
    //         "image": "https://server.drtechapp.com/storage/images/612929053654d.jpg",
    //         "created_at": "2021-08-27 22:26:30",
    //         "comment": "ممتاز جدا",
    //         "stars": "5"
    //     }
    // ];
    //   });
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(
        Globals.baseUrl + "provider/service/ratings/${widget.id}" ,  context, (r) { // user/ratings?id=${widget.id}&page$page
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          page++;
          data[r["pgae"]] = r['data'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
          TitleBar(() {Navigator.pop(context);}, 120),
          data[0] != null && data[0].isEmpty
              ? EmptyPage("reviews", LanguageManager.getText(122))
              : Expanded(
                  child: isLoading && data.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          child: CustomLoading(),
                        )
                      : Recycler(children: getComments()))
    ]));
  }

  List<Widget> getComments() {
    List<Widget> items = [];
    for (var page in data.keys)
      for (var item in data[page]) {
        items.add(Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    spreadRadius: 2,
                    blurRadius: 2,
                    color: Colors.black.withAlpha(15))
              ]),
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
                            item['stars'] > 2
                                ? FlutterIcons.like_fou
                                : FlutterIcons.dislike_fou,
                            color: item['stars'] > 2 ? Colors.orange : Colors.grey ,
                            size: 20,
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
              Container(
                margin: EdgeInsets.only(top: 15, left: 15, right: 10, bottom: 10),
                child: Text(
                  item['comment'].toString(),
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Converter.hexToColor("#727272")),
                ),
              )
            ],
          ),
        ));
      }
    return items;
  }
}
