import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavBarEngineer extends StatefulWidget {
  final onUpdate;
  final page;
  const NavBarEngineer({this.onUpdate,this.page});

  @override
  _NavBarEngineerState createState() => _NavBarEngineerState();
}

class _NavBarEngineerState extends State<NavBarEngineer> {
  Color activeColor;
  int iSelectedIndex = 0;
  double homeIconSize;
  int countNotSeen = UserManager.currentUser('not_seen').isNotEmpty? int.parse(UserManager.currentUser('not_seen')) : 0;
  int countChatNotSeen = UserManager.currentUser('chat_not_seen').isNotEmpty? int.parse(UserManager.currentUser('chat_not_seen')) : 0;

  @override
  void initState() {
    print('here_not_seen: initState NavBarEngineer');
    activeColor = Converter.hexToColor("#2094CD");
    if(widget.page != null) iSelectedIndex = widget.page;
    Globals.updateBottomBarNotificationCount = ()
    {
      print('here_not_seen: $mounted');

      if(mounted)
        setState(() {
          print('here_not_seen: $countNotSeen, ${UserManager.currentUser('not_seen')}');
          countNotSeen = UserManager.currentUser('not_seen').isNotEmpty? int.parse(UserManager.currentUser('not_seen')) : 0;
          countChatNotSeen = UserManager.currentUser('chat_not_seen').isNotEmpty? int.parse(UserManager.currentUser('chat_not_seen')) : 0;
          print('here_not_seen: $countNotSeen, ${UserManager.currentUser('not_seen')}');
        });
    };
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    homeIconSize = MediaQuery.of(context).size.width * 0.35;
    if (homeIconSize > 160) homeIconSize = 160;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: homeIconSize * 0.5,
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(10),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, -1))
          ]),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          height: homeIconSize * 0.5,
          child: Row(
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Home
              createIcon("services", 249, () { setState(() { iSelectedIndex = 0; });
                widget.onUpdate(iSelectedIndex);
              }, iSelectedIndex == 0, isBig: true),

              createIcon("chat", 250, () { setState(() { iSelectedIndex = 1; });
                widget.onUpdate(iSelectedIndex);
              }, iSelectedIndex == 1, count: countChatNotSeen),

              createIcon("checklist", 35, () { setState(() { iSelectedIndex = 2; });
                widget.onUpdate(iSelectedIndex);
              }, iSelectedIndex == 2),

              createIcon("bell", 45, () {print('here_countNotSeen: $countNotSeen'); setState(() { iSelectedIndex = 3; });
                widget.onUpdate(iSelectedIndex);
              }, iSelectedIndex == 3, count: countNotSeen),

              createIcon("menu", 46, () { setState(() { iSelectedIndex = 4; });
                widget.onUpdate(iSelectedIndex);
              }, iSelectedIndex == 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget createIcon(icon, text, onTap, isActive, {isBig = false, count = 0}) {
    if (!isBig)
      return InkWell(
          onTap: onTap,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  padding: count >0 ? EdgeInsets.only(top: 2): EdgeInsets.zero,
                    width: homeIconSize * (count == 0? 0.15: 0.20), // 20.2
                    height: homeIconSize * (count == 0? 0.15: 0.16), // 17.7
                    child: SvgPicture.asset(
                      "assets/icons/$icon.svg",
                      color: isActive ? activeColor : Colors.grey,
                      fit: BoxFit.contain,
                    )),
                count > 0
                ? Container(
                  alignment: Alignment.center,
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Colors.red),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(fontSize: 6, color: Colors.white,fontWeight: FontWeight.w900 ),
                  textAlign: TextAlign.center,),
                )
                : Container(),
              ],
            ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Text(
                LanguageManager.getText(text),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isActive ? activeColor : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            )
          ]));
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Column(
          textDirection: LanguageManager.getTextDirection(),
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: homeIconSize * 0.04),
              width: homeIconSize * 0.45,
              height: homeIconSize * 0.45,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/$icon.svg",
                    width: homeIconSize * 0.15,
                    height: homeIconSize * 0.15,
                    color: Colors.white,
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text(
                      LanguageManager.getText(text).replaceAll('My', '').trim(),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.grey,
                  borderRadius: BorderRadius.circular(homeIconSize)),
            ),
          ],
        ),
      ),
    );
  }
}
