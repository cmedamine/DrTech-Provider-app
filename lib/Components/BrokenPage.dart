import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';

class BrokenPage extends StatefulWidget {
  final Function callback;
  final message, buttonText, icon;
  BrokenPage(this.callback,
      {this.message = 20, this.buttonText = 114, this.icon});
  @override
  _BrokenPageState createState() => _BrokenPageState();
}

class _BrokenPageState extends State<BrokenPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          FlutterIcons.error_outline_mdi,
          size: 50,
          color: Colors.grey,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            LanguageManager.getText(widget.message),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
        GestureDetector(
          onTap: widget.callback,
          child: Container(
              alignment: Alignment.center,
              width: 180,
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
                    LanguageManager.getText(widget.buttonText),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .apply(color: Theme.of(context).primaryColor),
                  ),
                  Icon(widget.icon != null ? widget.icon : Icons.refresh,
                      color: Theme.of(context).primaryColor)
                ],
              )),
        )
      ],
    );
  }
}
