import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/Product.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/AddProduct.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Store extends StatefulWidget {
  const Store();

  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  ScrollController sliderController = ScrollController(),
      mainController = ScrollController();
  Map selectedFilters = {},
      filters = {},
      data = {},
      config,
      selectedCatigory,
      selectedSubCatigory = {};
  bool isFilterOpen = false, isConfigLoading = false, isLoading = false;
  int sliderSelectedIndex = -1, pageIndex = 0;
  @override
  void initState() {
    loadConfig();
    super.initState();
  }

  void loadConfig() {
    setState(() {
      isConfigLoading = true;
    });

    NetworkManager.httpGet(Globals.baseUrl + "store/configuration",  context, (r) {
      setState(() {
        isConfigLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          config = r;
          selectedCatigory = config['catigories'][0];
          selectedSubCatigory['id'] = '_ALL';
          init();
          load();
        });
      }
    }, cashable: true);
  }

  void init() {
    if (sliderSelectedIndex == -1) initSliderLoop();
  }

  void initSliderLoop() {
    Timer(Duration(seconds: 5), () {
      if (!mounted) return;
      initSliderLoop();
    });
    setState(() {
      sliderSelectedIndex++;
      if (sliderSelectedIndex > config['sliders'].length - 1)
        sliderSelectedIndex = 0;
      double size = MediaQuery.of(context).size.width * 0.95;
      sliderController.animateTo(size * sliderSelectedIndex,
          duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
    });
  }

  void load() {
    setState(() {
      isLoading = true;
    });
    Map<String, String> body = {
      "catigory_id": selectedCatigory['id'],
      "product_type_id": selectedSubCatigory['id'],
      "page": pageIndex.toString()
    };
    NetworkManager.httpGet(Globals.baseUrl + "store/load",  context, (r) {
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          if (data[r['catigory_id']] == null) data[r['catigory_id']] = {};
          if (data[r['catigory_id']][r['product_type_id']] == null)
            data[r['catigory_id']][r['product_type_id']] = {};
          data[r['catigory_id']][r['product_type_id']][r['page']] = r['data'];
        });
      }
    }, body: body, cashable: true);
  }

  void setSelectedCatigory(item) {
    setState(() {
      selectedCatigory = item;
      selectedSubCatigory = {"id": '_ALL'};
      pageIndex = 0;
      load();
    });
  }

  void setSelectedSubCatigory(item) {
    setState(() {
      selectedSubCatigory = item;
      pageIndex = 0;
      load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TitleBar(() {Navigator.pop(context);}, 138),
          isConfigLoading
              ? Expanded(
                  child: Center(
                  child: CustomLoading(),
                ))
              : Expanded(
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      ScrollConfiguration(
                        behavior: CustomBehavior(),
                        child: ListView(
                          padding: EdgeInsets.symmetric(vertical: 0),
                          children: [
                            getSearchAndFilter(),
                            Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                textDirection:
                                    LanguageManager.getTextDirection(),
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LanguageManager.getText(139),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Converter.hexToColor("#2094CD")),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 5,
                            ),
                            getSlider(),
                            getCatigories(),
                            getSubCatigories(),
                            Wrap(
                              children: getProducts(),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => AddProduct()));
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 15),
                          padding: EdgeInsets.only(
                              left: LanguageManager.getDirection() ? 20 : 12,
                              right: LanguageManager.getDirection() ? 12 : 20,
                              top: 5,
                              bottom: 7),
                          child: Icon(
                            FlutterIcons.plus_circle_fea,
                            size: 22,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                              borderRadius: LanguageManager.getDirection()
                                  ? BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20))
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20)),
                              color: Converter.hexToColor("#344F64")),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  List<Widget> getProducts() {
    List<Widget> products = [];
    if (data[selectedCatigory['id']] != null) if (data[selectedCatigory['id']]
            [selectedSubCatigory['id']] !=
        null)
      for (var page
          in data[selectedCatigory['id']][selectedSubCatigory['id']].keys) {
        for (var item in data[selectedCatigory['id']][selectedSubCatigory['id']]
            [page]) {
          products.add(Product(item));
        }
      }
    if (isLoading) {
      products.add(Container(
        width: MediaQuery.of(context).size.width,
        child: CustomLoading(),
        alignment: Alignment.center,
      ));
    }
    return products;
  }

  Widget getSubCatigories() {
    List<Widget> catigories = [];
    catigories.add(createSubCatigory(
        {"id": "_ALL", "name": LanguageManager.getText(140)}));
    catigories.add(createSubCatigory(
        {"id": "_OFFERS", "name": LanguageManager.getText(141)}));
    for (var item in selectedCatigory['children']) {
      catigories.add(createSubCatigory(item));
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: LanguageManager.getDirection(),
        children: catigories,
      ),
    );
  }

  Widget createSubCatigory(item) {
    bool selected = selectedSubCatigory['id'] == item['id'];
    return InkWell(
        onTap: () {
          setSelectedSubCatigory(item);
        },
        child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
            margin: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
                color: selected
                    ? Converter.hexToColor("#2094CD")
                    : Converter.hexToColor("#F2F2F2"),
                borderRadius: BorderRadius.circular(15)),
            child: Text(
              item["name"].toString(),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.white : Colors.black,
              ),
            )));
  }

  Widget getCatigories() {
    List<Widget> catigories = [];
    for (var item in config['catigories']) {
      bool selected = selectedCatigory == item;
      catigories.add(InkWell(
        onTap: () {
          setSelectedCatigory(item);
        },
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left: 5, right: 5),
          decoration: BoxDecoration(
              border: Border.all(
                  color: selected
                      ? Converter.hexToColor("#2094CD")
                      : Converter.hexToColor("#EFEFEF"),
                  width: 1),
              color: selected ? Converter.hexToColor("#2094CD") : Colors.white,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: LanguageManager.getTextDirection(),
            children: [
              item["icon"] != null && item["icon"].toString().isNotEmpty
                  ? SvgPicture.network(
                      item['icon'],
                      width: 20,
                      height: 20,
                      color: selected ? Colors.white : Colors.grey,
                    )
                  : Container(),
              Container(
                width: 10,
              ),
              Text(
                item["name"].toString(),
                textDirection: LanguageManager.getTextDirection(),
                style: TextStyle(
                  fontSize: 16,
                  color: selected ? Colors.white : Colors.grey,
                ),
              )
            ],
          ),
        ),
      ));
    }

    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: LanguageManager.getDirection(),
        children: catigories,
      ),
    );
  }

  Widget getSlider() {
    double size = MediaQuery.of(context).size.width * 0.95;
    return Center(
      child: Container(
        width: size,
        height: size * 0.45,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(color: Converter.hexToColor("#F2F2F2")),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListView(
                  scrollDirection: Axis.horizontal,
                  controller: sliderController,
                  children: getSliderContent(Size(size, size * 0.45)),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: getSliderDots(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getSliderContent(Size size) {
    List<Widget> sliders = [];
    for (var item in config['sliders']) {
      sliders.add(Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(Globals.correctLink(item['image'])))),
      ));
    }
    return sliders;
  }

  List<Widget> getSliderDots() {
    List<Widget> sliders = [];
    for (var i = 0; i < config['sliders'].length; i++) {
      bool selected = sliderSelectedIndex == i;
      sliders.add(Container(
        width: selected ? 14 : 8,
        height: 8,
        margin: EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Converter.hexToColor(selected ? "#ffffff" : "#344F64")),
      ));
    }
    return sliders;
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
          Row(
            textDirection: LanguageManager.getTextDirection(),
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Converter.hexToColor("#F2F2F2"),
                      borderRadius: BorderRadius.circular(10)),
                  margin:
                      EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 5),
                  padding: EdgeInsets.only(left: 14, right: 14),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Expanded(
                        child: TextField(
                          textInputAction: TextInputAction.search,
                          textDirection: LanguageManager.getTextDirection(),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              hintTextDirection:
                                  LanguageManager.getTextDirection(),
                              border: InputBorder.none,
                              hintText: LanguageManager.getText(102)),
                        ),
                      ),
                      Icon(
                        FlutterIcons.magnifier_sli,
                        color: Colors.grey,
                        size: 20,
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isFilterOpen = true;
                  });
                },
                child: Column(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    SvgPicture.asset(
                      "assets/icons/filter.svg",
                      width: 24,
                      height: 24,
                    ),
                    Text(
                      LanguageManager.getText(103),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Converter.hexToColor("#2094CD")),
                    ),
                  ],
                ),
              ),
              Container(
                width: 10,
              ),
            ],
          ),
          Container(
            height: 10,
          ),
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
                              color: Converter.hexToColor("#2094CD"),
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
}
