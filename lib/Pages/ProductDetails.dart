import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ProductDetails extends StatefulWidget {
  final args;
  const ProductDetails(this.args);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  bool isLoading = false;
  ScrollController sliderController = ScrollController();
  int sliderSelectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
          TitleBar(() {Navigator.pop(context);}, 162),
          isLoading
              ? Expanded(child: Center(child: CustomLoading()))
              : Expanded(
                  child: ScrollConfiguration(
                  behavior: CustomBehavior(),
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    children: [
                      getSlider(),
                      Container(
                        padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                        child: Row(
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            Expanded(
                                child: Text(
                              widget.args['name'],
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )),
                            Text(
                              widget.args['price'],
                              textDirection: LanguageManager.getTextDirection(),
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      createInfoIcon(FlutterIcons.calendar_faw,
                          Converter.getRealTime(widget.args["created_at"])),
                      createInfoIcon(FlutterIcons.location_on_mdi,
                          widget.args["location"]),
                      createInfoIcon(
                          FlutterIcons.user_faw, widget.args["user"]["name"]),
                      createInfoIcon(
                          FlutterIcons.phone_faw, widget.args["user"]["phone"]),
                      Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 2, bottom: 0),
                        child: Text(
                          LanguageManager.getText(163),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Wrap(
                          textDirection: LanguageManager.getTextDirection(),
                          children: getProductSpecifications(),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 2, bottom: 0),
                        child: Text(
                          LanguageManager.getText(165),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 2, bottom: 0),
                        child: Text(
                          widget.args["description"].toString(),
                          textDirection: LanguageManager.getTextDirection(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 20, top: 5),
                        padding: EdgeInsets.all(7),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    textDirection:
                                        LanguageManager.getTextDirection(),
                                    children: [
                                      Icon(
                                        FlutterIcons.phone_faw,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      Container(
                                        width: 5,
                                      ),
                                      Text(
                                        LanguageManager.getText(96),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
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
                              width: 5,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {},
                                child: Container(
                                  height: 45,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    textDirection:
                                        LanguageManager.getTextDirection(),
                                    children: [
                                      Icon(
                                        Icons.chat,
                                        color: Converter.hexToColor("#344f64"),
                                        size: 20,
                                      ),
                                      Container(
                                        width: 5,
                                      ),
                                      Text(
                                        LanguageManager.getText(117),
                                        style: TextStyle(
                                            color:
                                                Converter.hexToColor("#344f64"),
                                            fontSize: 16,
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
                                          color:
                                              Converter.hexToColor("#344f64"))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
        ]));
  }

  List<Widget> getProductSpecifications() {
    List<Widget> items = [];
    items.add(createSpecificationsItem(
        widget.args['color'], FlutterIcons.md_color_palette_ion));
    items.add(
        createSpecificationsItem(widget.args['brand'], FlutterIcons.star_ant));

    items.add(createSpecificationsItem(
        LanguageManager.getText(widget.args['state'] == 'NEW' ? 142 : 143),
        FlutterIcons.box_ent));

    if (widget.args['is_guaranteed'] == "1")
      items.add(createSpecificationsItem(
          LanguageManager.getText(153), FlutterIcons.check_all_mco));
    if (widget.args['memory'].toString().isNotEmpty)
      items.add(createSpecificationsItem(
          LanguageManager.getText(164) + " " + widget.args['memory'],
          FlutterIcons.chip_mco));
    return items;
  }

  Widget createSpecificationsItem(text, icon) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      padding: EdgeInsets.only(left: 15, right: 15),
      height: 38,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Icon(
            icon,
            color: Converter.hexToColor("#C4C4C4"),
          ),
          Container(
            width: 5,
          ),
          Text(
            text.toString(),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Converter.hexToColor("#707070")),
          ),
        ],
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Converter.hexToColor("#F2F2F2")),
    );
  }

  Widget getSlider() {
    double size = MediaQuery.of(context).size.width * 0.95;
    return Center(
      child: Container(
        margin: EdgeInsets.all(10),
        width: size,
        height: size * 0.6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Converter.hexToColor("#F2F2F2")),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListView(
                  scrollDirection: Axis.horizontal,
                  controller: sliderController,
                  children: getSliderContent(Size(size - 20, size * 0.45)),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 20,
                        height: 0,
                      ),
                      Row(
                        textDirection: LanguageManager.getTextDirection(),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: getSliderDots(),
                      ),
                      Icon(
                        FlutterIcons.share_2_fea,
                        color: Converter.hexToColor("#344F64"),
                      )
                    ],
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
    for (var item in widget.args['images']) {
      sliders.add(Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.contain, image: CachedNetworkImageProvider(Globals.correctLink(item)))),
      ));
    }
    return sliders;
  }

  List<Widget> getSliderDots() {
    List<Widget> sliders = [];
    for (var i = 0; i < widget.args['images'].length; i++) {
      bool selected = sliderSelectedIndex == i;
      sliders.add(Container(
        width: selected ? 14 : 8,
        height: 8,
        margin: EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Converter.hexToColor(selected ? "#2094CD" : "#C4C4C4")),
      ));
    }
    return sliders;
  }

  Widget createInfoIcon(icon, text) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Icon(
            icon,
            color: Converter.hexToColor("#C4C4C4"),
            size: 20,
          ),
          Container(
            width: 10,
          ),
          Expanded(
              child: Text(
            text,
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                fontSize: 16,
                color: Converter.hexToColor("#707070"),
                fontWeight: FontWeight.w600),
          ))
        ],
      ),
    );
  }
}
