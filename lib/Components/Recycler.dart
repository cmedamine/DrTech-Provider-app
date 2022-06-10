import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:flutter/material.dart';

class Recycler extends StatefulWidget {
  final List<Widget> children;
  final Function onScrollDown;
  const Recycler({this.children, this.onScrollDown});

  @override
  _RecyclerState createState() => _RecyclerState();
}

class _RecyclerState extends State<Recycler> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener(
        onNotification: (n) {
          if (n is ScrollNotification) {
            if (n.metrics.pixels == n.metrics.maxScrollExtent && widget.onScrollDown != null) {
              widget.onScrollDown();
            }
          }
          return true;
        },
        child: ScrollConfiguration(
          behavior: CustomBehavior(),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            children: widget.children,
          ),
        ));
  }
}
