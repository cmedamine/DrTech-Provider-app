
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/RateStarsStateless.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/ShareManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/LiveChat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Service extends StatefulWidget {
  final target, title;
  const Service(this.target, this.title);

  @override
  _ServiceState createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  Map<String, String> filters = {};
  Map<String, dynamic> selectedFilters = {};
  Map<String, dynamic> configFilters;
  int page = 0;
  Map<int, List> data = {};
  bool isLoading = false, isFilterOpen = false;

  ScrollController controller = ScrollController();

  @override
  void initState() {
    getConfig();
    load();
    super.initState();
  }

  void getConfig() {
    NetworkManager.httpGet(
        Globals.baseUrl + "services/filters?target=${widget.target}",  context, (r) {
      if (r['state'] == true) {
        setState(() {
          configFilters = r['data'];
        });
      }
    }, cashable: true);
  }

  void load() {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    NetworkManager.httpGet(
        Globals.baseUrl + "services/load?target=${widget.target}&page$page",
         context, (r) {
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          data[r['page']] = r['data'];
        });
      }
    }, body: filters, cashable: true);
  }

  void startNewConversation(id) {
    Alert.startLoading(context);
    NetworkManager.httpGet(
        Globals.baseUrl + "chat/add?id=$id&service_id=${widget.target}",  context, (r) {
      Alert.endLoading();
      if (r['state'] == true) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => LiveChat(r['id'].toString())));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('id: ${widget.target}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              TitleBar(() {Navigator.pop(context);}, widget.title),
              getSearchAndFilter(),
              Expanded(
                child: getEngineersList(),
              )
            ],
          ),
          !isFilterOpen
              ? Container()
              : SafeArea(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    color: Colors.black.withAlpha(isFilterOpen ? 85 : 0),
                    width: MediaQuery.of(context).size.width,
                    alignment: !LanguageManager.getDirection()
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(10),
                              spreadRadius: 2,
                              blurRadius: 2)
                        ],
                        borderRadius: !LanguageManager.getDirection()
                            ? BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10))
                            : BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                        color: Colors.white,
                      ),
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              textDirection: LanguageManager.getTextDirection(),
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isFilterOpen = !isFilterOpen;
                                    });
                                  },
                                  child: Icon(
                                    FlutterIcons.close_ant,
                                    size: 20,
                                  ),
                                ),
                                Text(
                                  LanguageManager.getText(106),
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  width: 20,
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: Colors.black.withAlpha(15),
                          ),
                          ...(configFilters == null
                              ? [
                                  Container(
                                    height: 150,
                                    alignment: Alignment.center,
                                    child: CustomLoading(),
                                  )
                                ]
                              : getFilters()),
                        ],
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  List<Widget> getFilters() {
    List<Widget> items = [];
    items.add(getFilterOption(107, configFilters['city'], "city"));
    items.add(getFilterOption(
        108,
        selectedFilters['city'] != null
            ? selectedFilters['city']['children']
            : LanguageManager.getText(113),
        "street",
        message: LanguageManager.getText(113)));
    items.add(getFilterOption(109, configFilters['device'], "device"));
    items.add(getFilterOption(
        110,
        selectedFilters['device'] != null
            ? selectedFilters['device']['children']
            : LanguageManager.getText(114),
        "brand",
        message: LanguageManager.getText(114)));
    items.add(getFilterOption(
        111,
        selectedFilters['brand'] != null
            ? selectedFilters['brand']['children']
            : LanguageManager.getText(115),
        "model",
        message: LanguageManager.getText(115)));

    items.add(Expanded(child: Container()));
    items.add(Container(
      margin: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            isFilterOpen = false;
            load();
          });
        },
        child: Container(
          width: 190,
          height: 45,
          alignment: Alignment.center,
          child: Text(
            LanguageManager.getText(116),
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
    ));
    return items;
  }

  Widget getSearchAndFilter() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Container(
            height: 10,
          ),
          // Container(
          //   decoration: BoxDecoration(
          //       color: Converter.hexToColor("#F2F2F2"),
          //       borderRadius: BorderRadius.circular(10)),
          //   margin: EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 5),
          //   padding: EdgeInsets.only(left: 14, right: 14),
          //   child: Row(
          //     textDirection: LanguageManager.getTextDirection(),
          //     children: [
          //       Expanded(
          //         child: TextField(
          //           textInputAction: TextInputAction.search,
          //           textDirection: LanguageManager.getTextDirection(),
          //           keyboardType: TextInputType.text,
          //           decoration: InputDecoration(
          //               hintTextDirection: LanguageManager.getTextDirection(),
          //               border: InputBorder.none,
          //               hintText: LanguageManager.getText(102)),
          //         ),
          //       ),
          //       Icon(
          //         FlutterIcons.magnifier_sli,
          //         color: Colors.grey,
          //         size: 20,
          //       )
          //     ],
          //   ),
          // ),
          // Container(
          //   height: 10,
          // ),
          // Container(
          //   padding: EdgeInsets.only(left: 15, right: 15),
          //   child: Row(
          //     textDirection: LanguageManager.getTextDirection(),
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         LanguageManager.getText(104),
          //         style: TextStyle(
          //             fontSize: 14, color: Converter.hexToColor("#707070")),
          //       ),
          //       InkWell(
          //         onTap: () {
          //           setState(() {
          //             isFilterOpen = true;
          //           });
          //         },
          //         child: Row(
          //           textDirection: LanguageManager.getTextDirection(),
          //           children: [
          //             SvgPicture.asset(
          //               "assets/icons/filter.svg",
          //               width: 18,
          //               height: 18,
          //             ),
          //             Text(
          //               LanguageManager.getText(103),
          //               style: TextStyle(fontSize: 14, color: Colors.blue),
          //             ),
          //           ],
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          selectedFilters.keys.length > 0
              ? Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Expanded(
                        child: Text(
                          selectedFilters.values
                              .map((e) => e["text"])
                              .toList()
                              .join(" , "),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedFilters = {};
                            filters = {};
                            load();
                          });
                        },
                        child: Icon(
                          FlutterIcons.close_ant,
                          color: Colors.red,
                        ),
                      )
                    ],
                  ))
              : Container()
        ],
      ),
    );
  }

  Widget getEngineersList() {
    List<Widget> items = [];

    for (var page in data.keys) {
      for (var item in data[page]) {
        items.add(getEngineerUi(item));
      }
    }
    if(items.length == 1)
    items.add(getEngineerUi({
      "id": "2",
      "name": "\u0645\u0632\u0648\u062f \u062e\u062f\u0645\u0629",
      "image": "https:\/\/server.drtechapp.com\/storage\/images\/610fb357ecdf7.jpg",
      "service_name": "\u0627\u0635\u0644\u0627\u062d \u0627\u0644\u062c\u0648\u0644\u0627\u062a",
      "city_id": "8363",
      "street_id": "633",
      "phone":"+966573284334",
      "rating": 5,
      "city_name": " جدة",
      "street_name": "المدينة المنورة",
      "verified": true,
      "available": true
    }));

    return widget.target == '2' || widget.target == '3'?Center(child: Text('قريبا...', textDirection: TextDirection.rtl,)):Recycler(
      onScrollDown: load,
      children: items,
    );
  }

  Widget getEngineerUi(item) {
    return Container(
      padding: EdgeInsets.all(7),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(15), spreadRadius: 2, blurRadius: 2)
      ], borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: InkWell(
        onTap: () {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (_) => EngineerPage(item['id'], widget.target)));
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              width: 90,
              margin: EdgeInsets.all(5),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    alignment: !LanguageManager.getDirection()
                        ? Alignment.bottomRight
                        : Alignment.bottomLeft,
                    child: item['verified'] == true
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
                            image: CachedNetworkImageProvider(Globals.correctLink(item['image']))),
                        borderRadius: BorderRadius.circular(10),
                        color: Converter.hexToColor("#F2F2F2")),
                  ),
                  Container(
                    height: 30,
                  ),
                  item['available'] == true
                      ? Text(
                          LanguageManager.getText(100),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.normal),
                        )
                      : Text(
                          LanguageManager.getText(101),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.normal),
                        )
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
                      item['name'],
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: Converter.hexToColor("#2094CD"),
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
                    InkWell(
                      onTap: () {
                        ShareManager.shearEngineer(
                            item['id'], item['name'], item['service_name']);
                      },
                      child: Icon(
                        FlutterIcons.share_2_fea,
                        color: Converter.hexToColor("#344F64"),
                      ),
                    )
                  ],
                ),
                Text(
                  LanguageManager.getText(98) +
                      " " +
                      item['service_name'].toString(),
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                ),
                Container(
                  height: 5,
                ),
                RateStarsStateless(
                  13,
                  stars: item['rating'].toInt(),
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
                              item['service_name'].toString(),
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
                          item['city_name'].toString() +
                              "  - " +
                              item['street_name'].toString(),
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
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Expanded(
                      child: InkWell(
                        onLongPress: () async {
                          // if (Platform.isIOS) {
                          // iOS
                          var mess  = "السلام عليكم ورحمة الله \n أنا ${UserManager.currentUser("name")}\nأريد...";
                          var whatsappUrl2 ="https:wa.me/?phone=${item['phone']}&text=$mess";//$phone
                          var whatsappUrl ="whatsapp://send?phone=${item['phone']}&text=$mess";//$phone
                          whatsappUrl = Uri.encodeFull(whatsappUrl);
                          whatsappUrl2 = Uri.encodeFull(whatsappUrl2);



                          //   var mess  = "السلام عليكم ورحمة الله \n أنا ${UserManager.currentUser("name")}\nأريد...";
                          //   var whatsappUrl ="whatsapp://send?phone=${item['phone']}&text=$mess";//$phone
                                  var txtControll = TextEditingController();
                                Alert.show(
                                    context,
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(left: 10, right: 10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Converter.hexToColor("#F2F2F2")),
                                            child: TextField(
                                              controller: txtControll,
                                              onChanged:  (r) {r == "aaa"? r=whatsappUrl:whatsappUrl = r;},
                                              textDirection: LanguageManager.getTextDirection(),
                                              textAlign: LanguageManager.getDirection()
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: LanguageManager.getText(33)),

                                            ),
                                          ),
                                          Container(height: 15,),
                                          InkWell(
                                            onTap: () async{
                                              if(txtControll.text.isEmpty)
                                                txtControll.text= whatsappUrl;
                                              else if(txtControll.text == "aaa")
                                                txtControll.text = whatsappUrl2;
                                              else {
                                            Navigator.pop(context);
                                            await canLaunch(whatsappUrl)
                                                ? launch(whatsappUrl)
                                                : await canLaunch(whatsappUrl2)
                                                ? launch(whatsappUrl2)
                                                : Alert.show(context,
                                                "تعذر الوصول إلى تطبيق الواتس أب");
                                          }
                                        },
                                            child: Container(
                                              height: 45,
                                              alignment: Alignment.center,
                                              child: Text(
                                                LanguageManager.getText(34),
                                                style: TextStyle(color: Colors.white),
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
                                        ],
                                      ),
                                    ),
                                    type: AlertType.WIDGET);


                        },
                        onTap: () async {
                            // if (Platform.isIOS) {
                              // iOS
                                var url = 'http://maps.apple.com/';
                                var mess  = "السلام عليكم ورحمة الله \n أنا ${UserManager.currentUser("name")}\nأريد...";
                                var whatsappUrl2 ="https:wa.me/?phone=${item['phone']}&text=$mess";//$phone
                                var whatsappUrl ="whatsapp://send?phone=${item['phone']}&text=$mess";//$phone
                                whatsappUrl = Uri.encodeFull(whatsappUrl);
                                whatsappUrl2 = Uri.encodeFull(whatsappUrl2);
                                await canLaunch(whatsappUrl)
                              ? launch(whatsappUrl)
                              : await canLaunch(whatsappUrl2)
                                  ? launch(whatsappUrl2)
                                  : Alert.show(context,
                                      "تعذر الوصول إلى تطبيق الواتس أب");
                          

                          },
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            textDirection: LanguageManager.getTextDirection(),
                            children: [
                              Icon(
                                FlutterIcons.whatsapp_faw,
                                color: Colors.white,
                              ),
                              Container(
                                width: 5,
                              ),
                              Text(
                                LanguageManager.getText(117),
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
                              color: Colors.green),
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: InkWell(
                    //     onTap: () {},
                    //     child: Container(
                    //       height: 40,
                    //       alignment: Alignment.center,
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         textDirection: LanguageManager.getTextDirection(),
                    //         children: [
                    //           Icon(
                    //             FlutterIcons.phone_faw,
                    //             color: Colors.white,
                    //           ),
                    //           Container(
                    //             width: 5,
                    //           ),
                    //           Text(
                    //             LanguageManager.getText(96),
                    //             style: TextStyle(
                    //                 color: Colors.white,
                    //                 fontSize: 15,
                    //                 fontWeight: FontWeight.w600),
                    //           ),
                    //         ],
                    //       ),
                    //       decoration: BoxDecoration(
                    //           boxShadow: [
                    //             BoxShadow(
                    //                 color: Colors.black.withAlpha(15),
                    //                 spreadRadius: 2,
                    //                 blurRadius: 2)
                    //           ],
                    //           borderRadius: BorderRadius.circular(12),
                    //           color: Converter.hexToColor("#344f64")),
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   width: 10,
                    // ),
                    // Expanded(
                    //   child: InkWell(
                    //     onTap: () {
                    //       startNewConversation(item['id']);
                    //     },
                    //     child: Container(
                    //       height: 40,
                    //       alignment: Alignment.center,
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         textDirection: LanguageManager.getTextDirection(),
                    //         children: [
                    //           Icon(
                    //             Icons.chat,
                    //             color: Converter.hexToColor("#344f64"),
                    //             size: 20,
                    //           ),
                    //           Container(
                    //             width: 5,
                    //           ),
                    //           Text(
                    //             LanguageManager.getText(117),
                    //             style: TextStyle(
                    //                 color: Converter.hexToColor("#344f64"),
                    //                 fontSize: 15,
                    //                 fontWeight: FontWeight.w600),
                    //           ),
                    //         ],
                    //       ),
                    //       decoration: BoxDecoration(
                    //           color: Colors.white,
                    //           boxShadow: [
                    //             BoxShadow(
                    //                 color: Colors.black.withAlpha(15),
                    //                 spreadRadius: 2,
                    //                 blurRadius: 2)
                    //           ],
                    //           borderRadius: BorderRadius.circular(12),
                    //           border: Border.all(
                    //               color: Converter.hexToColor("#344f64"))),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                Container(
                  height: 10,
                ),
              ],
            )),
            Container(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget getFilterOption(title, options, key, {message}) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        textDirection: LanguageManager.getTextDirection(),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LanguageManager.getText(title),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Container(
            height: 2,
          ),
          InkWell(
            onTap: () {
              if (options.runtimeType == String) {
                if (selectedFilters[options] != null &&
                    selectedFilters[options]['children'] != null) {
                  Alert.show(context, options, type: AlertType.SELECT);
                } else {
                  Alert.show(context, message);
                }
              } else
                Alert.show(context, options, type: AlertType.SELECT,
                    onSelected: (item) {
                  setState(() {
                    selectedFilters[key] = item;
                    filters[key] = item['id'];
                  });
                });
            },
            child: Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Converter.hexToColor("#F2F2F2")),
                child: Row(
                  textDirection: LanguageManager.getTextDirection(),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      selectedFilters[key] == null
                          ? LanguageManager.getText(112)
                          : selectedFilters[key]["text"],
                      textDirection: LanguageManager.getTextDirection(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    )),
                    Icon(FlutterIcons.chevron_down_fea,
                        size: 20, color: Colors.grey),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
