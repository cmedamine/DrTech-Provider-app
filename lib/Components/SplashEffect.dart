import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashEffect extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final double margin;
  final EdgeInsets padding;
  final Color color;
  final bool showShadow;
  final bool borderRadius;

  const SplashEffect(
      {Key key,
      this.child,
      this.onTap,
      this.margin = 0,
      this.padding = const EdgeInsets.all(0),
      this.color = Colors.transparent,
      this.showShadow = true,
      this.borderRadius = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: LanguageManager.getTextDirection(),
      children: [
        Container(
          margin: EdgeInsets.all(margin),
          padding: padding,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius? 999 : 0),
              color: color,
              boxShadow: !showShadow? [] : [
                BoxShadow(
                    offset: Offset(.5, 1),
                    color: Colors.black.withAlpha(50),
                    spreadRadius: 2,
                    blurRadius: 2)
              ]),
          child: child,
        ),
        new Positioned.fill(
            child: new Material(
                color: Colors.transparent,
                child: new InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius? 999 : 0)),
                  splashColor: Colors.white70,
                  onTap: onTap,
                ))),
      ],
    );
  }
}
