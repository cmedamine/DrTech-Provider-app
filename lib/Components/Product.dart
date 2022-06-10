import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/ProductDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Product extends StatefulWidget {
  final item;
  const Product(this.item);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.5 - 10;
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProductDetails(widget.item)));
      },
      child: Container(
        width: size,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              blurRadius: 2, spreadRadius: 2, color: Colors.black.withAlpha(20))
        ], borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: size,
                  height: size * 0.8,
                  margin: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: CachedNetworkImageProvider(Globals.correctLink(
                              widget.item['images'][0]))),
                      borderRadius: BorderRadius.circular(5),
                      color: Converter.hexToColor("#F2F2F2")),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            widget.item['isLiked'] =
                                widget.item['isLiked'] != true ? true : false;
                          });
                          NetworkManager.httpGet(
                              Globals.baseUrl +
                                  "product/like?product_id=" +
                                  widget.item["id"],  context, (r) {
                            if (r['state'] == true) {
                              setState(() {
                                widget.item['isLiked'] = r["data"];
                              });
                            }
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          child: Icon(FlutterIcons.heart_ant,
                              size: 24,
                              color: widget.item['isLiked'] != true
                                  ? Colors.grey
                                  : Colors.red),
                        ),
                      ),
                      Container(
                        width: 90,
                        padding: EdgeInsets.all(5),
                        child: Text(
                          LanguageManager.getText(
                              widget.item['state'] == "USED" ? 142 : 143),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: LanguageManager.getDirection()
                                ? BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20))
                                : BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20)),
                            color: Converter.hexToColor("#2094CD")),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 5, left: 5, right: 5),
              child: Row(
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Expanded(
                      child: Text(
                    widget.item['name'],
                    textDirection: LanguageManager.getTextDirection(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )),
                  Container(
                    width: 10,
                  ),
                  Text(
                    widget.item['price'],
                    textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            createInfoIcon(
                FlutterIcons.md_color_palette_ion, widget.item["color"]),
            createInfoIcon(FlutterIcons.star_ant, widget.item["brand"]),
            createInfoIcon(
                FlutterIcons.location_on_mdi, widget.item["location"]),
            createInfoIcon(FlutterIcons.user_faw, widget.item["user"]["name"]),
            Container(
              height: 8,
            ),
            Container(
              padding: EdgeInsets.all(7),
              child: Row(
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 35,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            Icon(
                              FlutterIcons.phone_faw,
                              color: Colors.white,
                              size: 18,
                            ),
                            Container(
                              width: 5,
                            ),
                            Text(
                              LanguageManager.getText(96),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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
                        height: 35,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            Icon(
                              Icons.chat,
                              color: Converter.hexToColor("#344f64"),
                              size: 18,
                            ),
                            Container(
                              width: 5,
                            ),
                            Text(
                              LanguageManager.getText(117),
                              style: TextStyle(
                                  color: Converter.hexToColor("#344f64"),
                                  fontSize: 14,
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
                                color: Converter.hexToColor("#344f64"))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createInfoIcon(icon, text) {
    return Container(
      padding: EdgeInsets.only(left: 7, right: 7),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Icon(
            icon,
            color: Converter.hexToColor("#C4C4C4"),
            size: 20,
          ),
          Container(
            width: 5,
          ),
          Expanded(
              child: Text(
            text,
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                fontSize: 14,
                color: Converter.hexToColor("#707070"),
                fontWeight: FontWeight.w600),
          ))
        ],
      ),
    );
  }
}
