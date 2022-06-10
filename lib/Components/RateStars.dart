import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class RateStars extends StatefulWidget {
  final double size, spacing;
  final Function onUpdate;
  var stars;
  RateStars(this.size,
      {this.spacing = 0.1, this.onUpdate, this.stars });

  @override
  _RateStarsState createState() => _RateStarsState();
}

class _RateStarsState extends State<RateStars> {
  var stars ;
  @override
  void initState() {
    stars = widget.stars ;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (5 + (widget.spacing * 4)) * widget.size,
      child: Row(
        children: [
          getStarAt(0),
          Container(
            width: widget.size * widget.spacing,
          ),
          getStarAt(1),
          Container(
            width: widget.size * widget.spacing,
          ),
          getStarAt(2),
          Container(
            width: widget.size * widget.spacing,
          ),
          getStarAt(3),
          Container(
            width: widget.size * widget.spacing,
          ),
          getStarAt(4),
        ],
      ),
    );
  }

  Widget getStarAt(index) {
    return GestureDetector(
      onTap: widget.onUpdate != null
          ? () {
              setState(() {
                stars = index + 1;
              });
              widget.onUpdate(index + 1);
            }
          : null,
      child: Container(
        width: widget.size,
        height: widget.size,
        child: Icon(
          FlutterIcons.star_faw,
          size: widget.size,
          color: (index + 1) <= (stars??0) ? Colors.orange : Colors.grey,
        ),
      ),
    );
  }
}
