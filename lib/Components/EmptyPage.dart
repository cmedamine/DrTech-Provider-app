import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyPage extends StatefulWidget {
  final Function callback;
  final image, message, label;
  EmptyPage(this.image, this.message, {this.label = -1, this.callback});
  @override
  _EmptyPageState createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.width * 0.5,
          child: SvgPicture.asset("assets/illustration/${widget.image}.svg"),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            LanguageManager.getText(widget.message),
            textDirection: LanguageManager.getTextDirection(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        widget.label == -1
            ? Container()
            : GestureDetector(
                onTap: widget.callback,
                child: Container(
                    alignment: Alignment.center,
                    width: 150,
                    height: 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          LanguageManager.getText(widget.label),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .apply(color: Theme.of(context).primaryColor),
                        ),
                      ],
                    )),
              )
      ],
    );
  }
}
