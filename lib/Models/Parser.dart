import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Config/IconsMap.dart';
import 'package:dr_tech/Models/parsers/WebParser.dart';
import 'package:dr_tech/models/Router.dart' as Custom;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Parser {
  final BuildContext context;
  Parser(this.context);

  static Widget getNetworkImage(url) {
    if (kIsWeb)
      return Image.network(url);
    else
      return CachedNetworkImage(
        imageUrl: url,
      );
  }

  static ImageProvider getNetworkImageProvider(url) {
    if (kIsWeb)
      return NetworkImage(url);
    else
      return CachedNetworkImageProvider(Globals.correctLink(url));
  }

  Widget load(arg) {
    String type = arg['type'].toString();

    if (type.toLowerCase() == 'container') return this.containerParser(arg);
    if (type.toLowerCase() == 'row') return this.rowParser(arg);
    if (type.toLowerCase() == 'column') return this.columnParser(arg);
    if (type.toLowerCase() == 'expanded') return this.expandedParser(arg);
    if (type.toLowerCase() == 'text') return this.textParser(arg);
    if (type.toLowerCase() == 'icon') return this.iconParser(arg);
    if (type.toLowerCase() == 'listview') return this.listViewParser(arg);
    if (type.toLowerCase() == 'ontap') return this.tabParser(arg);
    if (type.toLowerCase() == 'web') return this.web(arg);

    return Container();
  }
  // multy useage voids

  double getRealValue(val) {
    if (val.runtimeType == double) return val;
    if (val.runtimeType == int) return val.toDouble() ?? 0.0;

    if (val.runtimeType == String) if (val.contains("%")) {
      double screenRelated = val.contains("h")
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.width;
      String realValue =
          val.replaceAll("%", '').replaceAll("w", '').replaceAll("h", '');
      if (realValue.contains(".")) {
        double precentValue = double.parse(realValue) ?? 0.0;
        return screenRelated * (precentValue / 100);
      } else {
        int precentValue = int.parse(realValue) ?? 0;
        return screenRelated * (precentValue / 100);
      }
    } else if (val.contains('.'))
      return double.parse(val) ?? 0.0;
    else
      return int.parse(val).toDouble() ?? 0.0;

    return 0;
  }

  Color getColor(String val) {
    if (val.contains("#")) return Converter.hexToColor(val);
    return Colors.white;
  }

  EdgeInsets edgeInsets(val) {
    if (val.runtimeType == String && val.contains(",")) {
      List<String> values = val.split(",") ?? [];
      for (var i = 0; i < 4; i++) if (values.length < i + 1) values.add("0");

      return EdgeInsets.only(
          left: this.getRealValue(values[0]),
          top: this.getRealValue(values[1]),
          right: this.getRealValue(values[2]),
          bottom: this.getRealValue(values[3]));
    } else
      return EdgeInsets.all(this.getRealValue(val));
  }

  BoxBorder boxBorder(arg) {
    return Border.all(
      color: arg['color'] != null ? this.getColor(arg['color']) : null,
      width: arg['width'] != null ? this.getRealValue(arg['width']) : 1,
    );
  }

  BoxFit boxFit(arg) {
    switch (arg) {
      case "contain":
        return BoxFit.contain;
      case "fill":
        return BoxFit.fill;
      case "fitHeight":
        return BoxFit.fitHeight;
      case "fitHeight":
        return BoxFit.fitHeight;
      case "scaleDown":
        return BoxFit.scaleDown;
      case "cover":
        return BoxFit.cover;
    }
    return BoxFit.contain;
  }

  ImageProvider imageProvider(arg) {
    if (arg.runtimeType == String && arg.contains("http"))
      return Parser.getNetworkImageProvider(arg);

    return null;
  }

  List<BoxShadow> boxShadow(arg) {
    return [
      BoxShadow(
        color: arg['color'] != null ? this.getColor(arg['color']) : null,
        spreadRadius:
            arg['spread'] != null ? this.getRealValue(arg['spread']) : 0,
        blurRadius: arg['blur'] != null ? this.getRealValue(arg['blur']) : 0,
      )
    ];
  }

  BorderRadiusGeometry borderRadius(arg) {
    if (arg.runtimeType == String && arg.contains(",")) {
      List<String> values = arg.split(",") ?? [];
      for (var i = 0; i < 4; i++) if (values.length < i + 1) values.add("0");

      return BorderRadius.only(
          topLeft: Radius.circular(this.getRealValue(values[0])),
          topRight: Radius.circular(this.getRealValue(values[1])),
          bottomLeft: Radius.circular(this.getRealValue(values[2])),
          bottomRight: Radius.circular(this.getRealValue(values[3])));
    } else
      return BorderRadius.circular(this.getRealValue(arg));
  }

  BoxDecoration boxDecoration(arg) {
    return BoxDecoration(
      color: arg['color'] != null ? this.getColor(arg['color']) : null,
      border: arg['border'] != null ? this.boxBorder(arg['border']) : null,
      image: arg['image'] != null ? this.decorationImage(arg['image']) : null,
      boxShadow: arg['shadow'] != null ? this.boxShadow(arg['shadow']) : null,
      borderRadius: arg['borderRadius'] != null
          ? this.borderRadius(arg['borderRadius'])
          : null,
    );
  }

  DecorationImage decorationImage(arg) {
    return DecorationImage(
        alignment: arg['alignment'] != null
            ? this.alignment(arg['alignment'])
            : Alignment.center,
        image: arg['image'] != null ? this.imageProvider(arg['image']) : null,
        fit: arg['fit'] != null ? this.boxFit(arg['fit']) : null);
  }

  TextStyle textStyle(arg) {
    return TextStyle(
      fontFamily: arg['fontFamily'] != null ? arg['fontFamily'] : null,
      color: arg['color'] != null ? this.getColor(arg['color']) : null,
      backgroundColor: arg['backgroundColor'] != null
          ? this.getColor(arg['backgroundColor'])
          : null,
      fontSize:
          arg['fontSize'] != null ? this.getRealValue(arg['fontSize']) : null,
      height: arg['height'] != null ? this.getRealValue(arg['height']) : null,
      letterSpacing: arg['letterSpacing'] != null
          ? this.getRealValue(arg['letterSpacing'])
          : null,
      fontWeight: arg['fontWeight'] != null
          ? this.fontWeight(arg['fontWeight'])
          : FontWeight.normal,
      shadows: arg['shadow'] != null ? this.boxShadow(arg['shadow']) : [],
    );
  }

  FontWeight fontWeight(arg) {
    switch (arg) {
      case 'normal':
        return FontWeight.normal;
      case 'bold':
        return FontWeight.bold;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
    }
    return FontWeight.normal;
  }

  CrossAxisAlignment crossAxisAlignment(arg) {
    switch (arg) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      case 'stretch':
        return CrossAxisAlignment.stretch;
    }
    return CrossAxisAlignment.center;
  }

  MainAxisAlignment mainAxisAlignment(arg) {
    switch (arg) {
      case 'center':
        return MainAxisAlignment.center;
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
    }
    return MainAxisAlignment.start;
  }

  Axis axis(arg) {
    switch (arg) {
      case 'horizontal':
        return Axis.horizontal;
      case 'vertical':
        return Axis.vertical;
    }
    return Axis.horizontal;
  }

  MainAxisSize mainAxisSize(arg) {
    switch (arg) {
      case 'min':
        return MainAxisSize.min;
      case 'max':
        return MainAxisSize.max;
    }
    return MainAxisSize.max;
  }

  VerticalDirection verticalDirection(arg) {
    switch (arg) {
      case 'up':
        return VerticalDirection.up;
      case 'down':
        return VerticalDirection.down;
    }
    return VerticalDirection.down;
  }

  TextAlign textAlign(arg) {
    switch (arg) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'start':
        return TextAlign.start;
      case 'end':
        return TextAlign.end;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
    }
    return null;
  }

  TextDirection textDirection(arg) {
    switch (arg) {
      case 'ltr':
        return TextDirection.ltr;
      case 'rtl':
        return TextDirection.rtl;
    }
    return null;
  }

  AlignmentGeometry alignment(arg) {
    switch (arg) {
      case 'center':
        return Alignment.center;
      case 'centerleft':
        return Alignment.centerLeft;
      case 'centerright':
        return Alignment.centerRight;
      case 'topcenter':
        return Alignment.topCenter;
      case 'topleft':
        return Alignment.topLeft;
      case 'topright':
        return Alignment.topRight;
      case 'bottomcenter':
        return Alignment.bottomCenter;
      case 'bottomleft':
        return Alignment.bottomLeft;
      case 'bottomright':
        return Alignment.bottomRight;
    }
    return null;
  }

  List<Widget> getChildren(arg) {
    List<Widget> children = [];

    for (var i = 0; i < arg.length; i++) {
      children.add(this.load(arg[i]));
    }

    return children;
  }

  Container containerParser(arg) {
    return Container(
      color: arg['color'] != null && arg['decoration'] == null
          ? this.getColor(arg['color'])
          : null,
      height: arg['height'] != null ? this.getRealValue(arg['height']) : null,
      width: arg['width'] != null ? this.getRealValue(arg['width']) : null,
      padding: arg['padding'] != null ? this.edgeInsets(arg['padding']) : null,
      margin: arg['margin'] != null ? this.edgeInsets(arg['margin']) : null,
      alignment:
          arg['alignment'] != null ? this.alignment(arg['alignment']) : null,
      decoration: arg['decoration'] != null
          ? this.boxDecoration(arg['decoration'])
          : null,
      child: arg['child'] != null ? this.load(arg['child']) : null,
    );
  }

  Expanded expandedParser(arg) {
    return Expanded(
      child: arg['child'] != null ? this.load(arg['child']) : null,
    );
  }

  Row rowParser(arg) {
    return Row(
      crossAxisAlignment: arg['crossAxisAlignment'] != null
          ? this.crossAxisAlignment(arg['crossAxisAlignment'])
          : CrossAxisAlignment.center,
      mainAxisAlignment: arg['mainAxisAlignment'] != null
          ? this.mainAxisAlignment(arg['mainAxisAlignment'])
          : MainAxisAlignment.start,
      mainAxisSize: arg['mainAxisSize'] != null
          ? this.mainAxisSize(arg['mainAxisSize'])
          : MainAxisSize.max,
      verticalDirection: arg['direction'] != null
          ? this.verticalDirection(arg['direction'])
          : VerticalDirection.down,
      children:
          arg['children'] != null ? this.getChildren(arg['children']) : [],
    );
  }

  Column columnParser(arg) {
    return Column(
      crossAxisAlignment: arg['crossAxisAlignment'] != null
          ? this.crossAxisAlignment(arg['crossAxisAlignment'])
          : CrossAxisAlignment.center,
      mainAxisAlignment: arg['mainAxisAlignment'] != null
          ? this.mainAxisAlignment(arg['mainAxisAlignment'])
          : MainAxisAlignment.start,
      mainAxisSize: arg['mainAxisSize'] != null
          ? this.mainAxisSize(arg['mainAxisSize'])
          : MainAxisSize.max,
      verticalDirection: arg['direction'] != null
          ? this.verticalDirection(arg['direction'])
          : VerticalDirection.down,
      children:
          arg['children'] != null ? this.getChildren(arg['children']) : [],
    );
  }

  ListView listViewParser(arg) {
    return ListView(
      scrollDirection: arg['scrollDirection'] != null
          ? this.axis(arg['scrollDirection'])
          : Axis.vertical,
      reverse: arg['reverse'] != null ? arg['reverse'] : false,
      children:
          arg['children'] != null ? this.getChildren(arg['children']) : [],
    );
  }

  ListTile listTileParser(arg) {
    return ListTile(
      leading: arg['leading'] != null ? this.load(arg['leading']) : null,
      title: arg['title'] != null ? this.load(arg['title']) : null,
      subtitle: arg['subtitle'] != null ? this.load(arg['subtitle']) : null,
      isThreeLine: arg['isThreeLine'] != null ? arg['isThreeLine'] : false,
    );
  }

  Text textParser(arg) {
    return Text(
      arg['text'] != null ? Converter.getRealText(arg['text']) : "",
      textAlign: arg['align'] != null ? this.textAlign(arg['align']) : null,
      style: arg['style'] != null ? this.textStyle(arg['style']) : null,
      textDirection: arg['direction'] != null
          ? this.textDirection(arg['direction'])
          : null,
    );
  }

  Icon iconParser(arg) {
    return Icon(
      arg['data'] != null
          ? IconsMap.from[arg['data']]
          : FlutterIcons.heart_broken_mco,
      size: arg['size'] != null ? this.getRealValue(arg['size']) : 24,
      color: arg['color'] != null ? this.getColor(arg['color']) : Colors.black,
      textDirection: arg['direction'] != null
          ? this.textDirection(arg['direction'])
          : null,
    );
  }

  InkWell tabParser(arg) {
    return InkWell(
      onTap: () {
        if (arg['action'] != null) this.parseAction(arg['action']);
      },
      child: arg['child'] != null ? this.load(arg['child']) : null,
    );
  }

  Widget web(arg) {
    return WebParser(arg);
  }

  void parseAction(arg) {
    if (arg['message'] != null) {
      var content = arg['message']['content'];
      if (content.runtimeType == Map) content = this.load(content);
      Alert.show(context, content);
    }
    if (arg['router'] != null) {
      var router = arg['router'];
      Custom.Router.navigate(context, router['link'],
          title: router['title'] ?? "");
    }
  }
}
