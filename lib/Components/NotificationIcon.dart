import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon();

  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {

  int countNotSeen =
  UserManager.currentUser('not_seen').isNotEmpty
      ? int.parse(UserManager.currentUser('not_seen'))
      : 0;

  @override
  void initState() {
    print('here_not_seen: initState NotificationIcon');
    Globals.updateTitleBarNotificationCount = ()
    {
      print('here_not_seen..');
      print('here_not_seen: $mounted');
      if(mounted)
        setState(() {
          print('here_not_seen: $countNotSeen, ${UserManager.currentUser('not_seen')}');
          countNotSeen = UserManager.currentUser('not_seen').isNotEmpty? int.parse(UserManager.currentUser('not_seen')) : 0;
          print('here_not_seen: $countNotSeen, ${UserManager.currentUser('not_seen')}');
        });
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          setState(() {
            countNotSeen = 0;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home(page: 3,)));
          });
        },
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Icon(
              FlutterIcons.bell_outline_mco,
              color: Colors.white,
              size: 26,
            ),
            countNotSeen > 0
                ? Container(
                    alignment: Alignment.center,
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Colors.red),
                      child: Text(
                        countNotSeen > 99 ? '99+' : countNotSeen.toString(),
                        style: TextStyle(fontSize: 6, color: Colors.white,fontWeight: FontWeight.w900 ),
                        textAlign: TextAlign.center),
            )
                : Container()
          ],
        ));
  }
}
