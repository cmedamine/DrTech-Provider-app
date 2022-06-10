import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/RateStarsStateless.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/ShareManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/AddServices.dart';
import 'package:dr_tech/Pages/EngineerRatings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';

import 'AddRemoveOffers.dart';

class ServicePage extends StatefulWidget {
  final id;
  ServicePage(this.id);

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> with TickerProviderStateMixin {
  bool isLoading;
  Map data = {};
  TabController controller;
  bool returnResult = false;

  @override
  void initState() {
    Globals.reloadPageServiceDetails = () {
      if (mounted) load();
    };
    load();
    super.initState();
  }

  void load() {
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "provider/service/${widget.id}",  context, (r) { // user/service?id=${widget.id}
      setState(() {isLoading = false;});
      if (r['state'] == true) {
        setState(() {
          data = r['data'];
          controller = new TabController(length: (data['images'] as String).split('||').length , vsync: this);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('here_WillPopScope: $returnResult');
        Navigator.of(context).pop(true);
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            TitleBar(() {Navigator.pop(context);}, 265),
            Expanded(
                child: isLoading
                    ? Container(
                        child: CustomLoading(),
                        alignment: Alignment.center,
                      )
                    : data['status'] == 'ACCEPTED'?
                SingleChildScrollView(
                        child: Column(
                          textDirection: LanguageManager.getTextDirection(),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getServiceInfo(),
                            Container(
                              height: 10,
                            ),
                            Row(
                              textDirection: LanguageManager.getTextDirection(),
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Text(
                                    data['name'].toString(),
                                    textDirection:
                                        LanguageManager.getTextDirection(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                ),
                                Row(
                                  textDirection:
                                      LanguageManager.getTextDirection(),
                                  children: [
                                    RateStarsStateless(
                                      14,
                                      stars: data['rate']?? 5,
                                    ),
                                    Container(
                                      width: 5,
                                    ),
                                    Text(
                                      (Converter.format(data['rate']?? 5)).toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.grey),
                                    ),
                                    Container(
                                      width: 15,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Container(
                              height: 10,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                data['about'].toString(),
                                textDirection: LanguageManager.getTextDirection(),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Converter.hexToColor("#727272")),
                              ),
                            ),
                            // Container(
                            //   height: 25,
                            // ),
                            // Row(
                            //   textDirection: LanguageManager.getTextDirection(),
                            //   children: [
                            //     Container(
                            //       width: 10,
                            //     ),
                            //     Container(
                            //       height: 36,
                            //       width: 160,
                            //       child: Row(
                            //           textDirection:
                            //               LanguageManager.getTextDirection(),
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             Container(
                            //               margin: EdgeInsets.only(
                            //                   left: 10, right: 10),
                            //               child: Icon(
                            //                 FlutterIcons.tag_ant,
                            //                 color:
                            //                     Converter.hexToColor("#344F64"),
                            //                 size: 18,
                            //               ),
                            //             ),
                            //             Text(
                            //               LanguageManager.getText(141),
                            //               textDirection:
                            //                   LanguageManager.getTextDirection(),
                            //               textAlign: TextAlign.center,
                            //               style: TextStyle(
                            //                 fontWeight: FontWeight.w600,
                            //                 fontSize: 16,
                            //                 color:
                            //                     Converter.hexToColor("#344F64"),
                            //               ),
                            //             ),
                            //             Container(
                            //               width: 40,
                            //             )
                            //           ]),
                            //       decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(15),
                            //         /*border: Border.all(
                            //               width: 1.6,
                            //               color: Converter.hexToColor("#344F64"))*/
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // data['offers'].length == 0
                            //     ? Container(
                            //         width:
                            //             MediaQuery.of(context).size.width * 0.9,
                            //         margin: EdgeInsets.all(10),
                            //         decoration: BoxDecoration(
                            //             border: Border.all(
                            //                 color: Colors.grey.withAlpha(50),
                            //                 width: 1),
                            //             borderRadius: BorderRadius.circular(15)),
                            //         padding: EdgeInsets.all(25),
                            //         child: Text(
                            //           LanguageManager.getText(267),
                            //           textAlign: TextAlign.center,
                            //         ),
                            //       )
                            //     : Container(
                            //         child: Column(
                            //           textDirection:
                            //               LanguageManager.getTextDirection(),
                            //           mainAxisSize: MainAxisSize.min,
                            //           children: (data['offers'] as List).map((e) {
                            //             return Container(
                            //               margin: EdgeInsets.all(15),
                            //               padding: EdgeInsets.all(10),
                            //               decoration: BoxDecoration(
                            //                   color: Colors.white,
                            //                   boxShadow: [
                            //                     BoxShadow(
                            //                         color: Colors.black
                            //                             .withAlpha(15),
                            //                         blurRadius: 2,
                            //                         spreadRadius: 2)
                            //                   ],
                            //                   borderRadius:
                            //                       BorderRadius.circular(15)),
                            //               child: Column(
                            //                 textDirection: LanguageManager
                            //                     .getTextDirection(),
                            //                 crossAxisAlignment:
                            //                     CrossAxisAlignment.start,
                            //                 children: [
                            //                   Row(
                            //                     textDirection: LanguageManager.getTextDirection(),
                            //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //                     children: [
                            //                       Text(
                            //                         e["price"].toString() + " " + Globals.getUnit(),
                            //                         textDirection: LanguageManager.getTextDirection(),
                            //                         style: TextStyle(
                            //                             color: Converter.hexToColor("#2094CD"),
                            //                             fontSize: 16,
                            //                             fontWeight: FontWeight.bold),
                            //                       )
                            //                     ],
                            //                   ),
                            //                   Text(
                            //                     e["description"].toString(),
                            //                     textDirection: LanguageManager.getTextDirection(),
                            //                     style: TextStyle(
                            //                         color: Converter.hexToColor("#727272"),
                            //                         fontSize: 16,
                            //                         fontWeight: FontWeight.normal),
                            //                   ),
                            //                 ],
                            //               ),
                            //             );
                            //           }).toList(),
                            //         ),
                            //       ),
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
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => EngineerRatings(widget.id)));
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
                        ),
                      )
                    :getFormContent()
            ),
            isLoading
            ? Container()
            : Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      returnResult = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddRemoveOffers(data: data)));
                      if (returnResult == true) {
                        load();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(141),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                ),

                Expanded(
                  child: InkWell(
                    onTap: () async {
                      returnResult = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddServices(data: data)));
                      if (returnResult == true) {
                        load();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(170),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                ),

                Expanded(
                  child: InkWell(
                    onTap: confirmDelete,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(169),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(15),
                                spreadRadius: 2,
                                blurRadius: 2)
                          ],
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.red),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getComments() {
    print('here_getComments : ${data['ratings']}');
    List<Widget> items = [];
    for (var item in data['ratings']) {
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
                          item['stars'] > 2
                              ? FlutterIcons.like_fou
                              : FlutterIcons.dislike_fou,
                          color: item['stars'] > 2 ? Colors.orange : Colors.grey,
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
            Container(height: 10,),
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

  Widget getServiceInfo() {
    double size = MediaQuery.of(context).size.width;
    return Container(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: LanguageManager.getTextDirection(),
      children: [
        Container(
          width: size,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: EdgeInsets.all(5),
                width: size - 20,
                height: size * 0.5 - 10,
                child: TabBarView(
                    controller: controller,
                  children: (data['images'] as String)
                      .split('||')
                      .map<Widget>((String url) => Container(
                            width: size - 20,
                            height: size * 0.5 - 10,
                            decoration: BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(Globals.correctLink(url)))),
                          ))
                      .toList(),
                  // (data['images'] as List).map((e) =>
                  // Container(
                    //           width: size - 20,
                    //           height: size * 0.5 - 10,
                    //           decoration: BoxDecoration(
                    //               image: DecorationImage(
                    //                   image: CachedNetworkImageProvider(
                    //                       e['name']))),
                    //         ))
                  //         .toList()
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Converter.hexToColor("#F2F2F2")),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Container(),
                    Row(
                        textDirection: LanguageManager.getTextDirection(),
                        children:
                        (data['images'] as String).split('||')                       // split the text into an array
                            .map<Widget>((String url) =>
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: controller.index == (data['images'] as String).split('||') .indexOf(url)
                                      ? Colors.white
                                      : Converter.hexToColor("#344F64")),
                            )) // put the text inside a widget
                            .toList(),

                        // (data['images'] as List)
                        //     .map((e) => Container(
                        //           width: 7,
                        //           height: 7,
                        //           decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(20),
                        //               color: controller.index ==
                        //                       (data['images'] as List)
                        //                           .indexOf(e)
                        //                   ? Colors.white
                        //                   : Converter.hexToColor("#344F64")),
                        //         ))
                        //     .toList()
                    ),
                    Container(
                      child: InkWell(
                        onTap: () {
                          ShareManager.shearService(data['id'], data['name']);
                        },
                        child: Icon(
                          Icons.share,
                          color: Converter.hexToColor("#344F64"),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    ));
  }

  Widget getFormContent() {
    return Column(
      children: [
        Container(height: 70),
        SvgPicture.asset("assets/illustration/join.svg", width: 120, height: 120),
        Container(height: 10),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
          child: Text(
            LanguageManager.getText(data['in_update'] == 1 ? 322 : 214) + ':\n\"${data['name']}\"',
            textDirection: LanguageManager.getTextDirection(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Converter.hexToColor("#2094CD")),
          ),
        ),
        Container(height: 10),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
          child: Row(
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LanguageManager.getText(215),
                textDirection: LanguageManager.getTextDirection(),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Converter.hexToColor("#344F64")),
              ),
              Container(width: 10),
              getStatusText(),
            ],
          ),
        )
      ],
    );
  }

  Widget getStatusText() {
    var map = {
      'PENDING': {"text": 217, "color": "#DFC100"}, // 216, #000000
      'PROCESSING': {"text": 217, "color": "#DFC100"},
      'ACCEPTED': {"text": 218, "color": "#00710B"},
      'REJECTED': {"text": 219, "color": "#F00000"}
    };
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Converter.hexToColor(map[data['status']]["color"]).withAlpha(15)),
      child: Text(
        LanguageManager.getText(map[data['status']]["text"]),
        textDirection: LanguageManager.getTextDirection(),
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Converter.hexToColor(map[data['status']]["color"])),
      ),
    );
  }

  void confirmDelete() {
    Alert.show(
        context,
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      FlutterIcons.x_fea,
                      size: 24,
                    ),
                  )
                ],
              ),
              Container(
                child: Icon(
                  FlutterIcons.trash_faw,
                  size: 50,
                  color: Converter.hexToColor("#707070"),
                ),
              ),
              Container(
                height: 30,
              ),
              Text(
                LanguageManager.getText(363),
                style: TextStyle(
                    color: Converter.hexToColor("#707070"),
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 30,
              ),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: delete,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(169),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(15),
                                spreadRadius: 2,
                                blurRadius: 2)
                          ],
                          borderRadius: BorderRadius.circular(8),
                          color: Converter.hexToColor("#FF0000")),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Alert.publicClose();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(172),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                  )
                ],
              )
            ],
          ),
        ),
        type: AlertType.WIDGET);
  }

  void delete() {
    Navigator.pop(context);
    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "provider/service/delete/${widget.id}", context, (r) { // services/add
      Alert.endLoading();
      if (r['state'] == true) {
        Navigator.of(context, rootNavigator: true)..pop(true)..pop(true);
      }
    }, body: {});
  }
}
