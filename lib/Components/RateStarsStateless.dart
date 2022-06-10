import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class RateStarsStateless extends StatelessWidget {
  final double size, spacing;
  final Function onUpdate;
  var stars;
  RateStarsStateless(this.size, {this.spacing = 0.1, this.onUpdate, this.stars});


  @override
  Widget build(BuildContext context) {
    return Container(
      width: (5 + (spacing * 4)) * size,
      child: Row(
        children: [
          getStarAt(0),
          Container(
            width: size * spacing,
          ),
          getStarAt(1),
          Container(
            width: size * spacing,
          ),
          getStarAt(2),
          Container(
            width: size * spacing,
          ),
          getStarAt(3),
          Container(
            width: size * spacing,
          ),
          getStarAt(4),
        ],
      ),
    );
  }

  Widget getStarAt(index) {
    return GestureDetector(
      onTap: onUpdate != null
          ? () {
        // setState(() {
        stars = index + 1;
        // });
        onUpdate(index + 1);
      }
          : null,
      child: Container(
        width: size,
        height: size,
        child: Icon(
          FlutterIcons.star_faw,
          size: size,
          color: (index + 1) <= (stars??0) ? Colors.orange : Colors.grey,
        ),
      ),
    );
  }
}
