import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Pages/ContactUs.dart';
import 'package:dr_tech/Pages/ExtraPages/About.dart';
import 'package:dr_tech/Pages/ExtraPages/RateApp.dart';
import 'package:dr_tech/Pages/ExtraPages/Terms.dart';
import 'package:dr_tech/Pages/FrequentlyAskedQuestions.dart';
import 'package:dr_tech/Pages/ProfileEdit.dart';
import 'package:dr_tech/Pages/Transactions.dart';
import 'package:dr_tech/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final refrashState;
  const ProfileScreen(this.refrashState);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {

    return ScrollConfiguration(
      behavior: CustomBehavior(),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 30),
        children: [
          getProfileHeader(),
          Container(height: 10,),
          Container(
            margin: EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5),
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SvgPicture.asset(
                  "assets/icons/lang.svg",
                  fit: BoxFit.fill,
                  width: 30,
                  height: 30,
                ),
                Text(
                  LanguageManager.getText(268),
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Text(
                      LanguageManager.getText(100),
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.blue),
                    ),
                    Switch(
                        value: UserManager.currentUser("active") == "1",
                        onChanged: (v) {
                          setState(() {
                            DatabaseManager.save("active", v ? "1" : "0");
                            UserManager.update("active", v ? "1" : "0",  context, (r) {
                                  setState(() {});
                                });
                          });
                          widget.refrashState();
                        }),
                    Text(
                      LanguageManager.getText(101),
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.blue),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 0, bottom: 10, left: 5, right: 5),
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SvgPicture.asset(
                  "assets/icons/lang.svg",
                  fit: BoxFit.fill,
                  width: 30,
                  height: 30,
                ),
                Text(
                  LanguageManager.getText(48),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Text(
                      LanguageManager.getText(49),
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.blue),
                    ),
                    Switch(
                        value: LanguageManager.getDirection(),
                        onChanged: (v) {
                          setState(() {
                            if (v) {
                              LanguageManager.setLanguage("ar,SA");
                            } else {
                              LanguageManager.setLanguage("en,US");
                            }
                          });
                          widget.refrashState();
                        }),
                    Text(
                      LanguageManager.getText(50),
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.blue),
                    ),
                  ],
                )
              ],
            ),
          ),
          getProfileItem(FlutterIcons.attach_money_mdi, 301, () { // 185
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => Transactions()));
          }),
          getProfileItem(FlutterIcons.list_fea, 59, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Terms()));
          }),
          getProfileItem(FlutterIcons.info_fea, 60, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => About()));
          }),
          getProfileItem(FlutterIcons.flag_fea, 62, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => FrequentlyAskedQuestions()));
          }),
          getProfileItem(FlutterIcons.headphones_fea, 63, () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => ContactUs()));
          }),
          getProfileItem(FlutterIcons.share_fea, 64, () {
            Alert.show(context,
                Container(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        LanguageManager.getText(64),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      getShearinIcons(),
                    ])),
                type: AlertType.WIDGET);
          }),
          getProfileItem(FlutterIcons.star_fea, 65, () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => RateApp()));
          }),
          // getProfileItem(FlutterIcons.account_off_mco, 278, () {
          //   // Navigator.push(context, MaterialPageRoute(builder: (_) => RateApp()));
          //   Alert.show(context, getAlertDeleteAccount(), type: AlertType.WIDGET);
          // }, withArraw: false),
          getProfileItem(FlutterIcons.log_out_fea, 66, () {
            Alert.show(context, 319, onYes: (){
              print('here_logout confirm');
              Alert.startLoading(context);
              UserManager.logout((){
                Alert.endLoading();
                main();
              });
            }, secondaryText: 156, premieryText: 155);
          }, withArraw: false)
        ],
      ),
    );
  }

  Widget getShearinIcons() {
    List<Widget> shearIcons = [];
    if (Globals.getConfig("sharing") != "")
      for (var item in Globals.getConfig("sharing")) {
        shearIcons.add(GestureDetector(
          onTap: () async {
            launch(Uri.encodeFull(item['url']));
          },
          child: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: CachedNetworkImageProvider(Globals.correctLink(item["icon"])))),
          ),
        ));
      }
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: shearIcons,
      ),
    );
  }

  Widget getProfileItem(icon, title, onTap, {withArraw = true}) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
      child: InkWell(
        onTap: onTap,
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              width: 50,
              height: 50,
              child: Icon(
                icon,
                color: Colors.blue.withAlpha(200),
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Converter.hexToColor("#F2F2F2")),
            ),
            Container(
              width: 10,
            ),
            Expanded(
                child: Text(
                  LanguageManager.getText(title),
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Converter.hexToColor("#707070")),
                )),
            Container(
              width: 10,
            ),
            withArraw
                ? Icon(
              LanguageManager.getDirection()
                  ? FlutterIcons.chevron_left_fea
                  : FlutterIcons.chevron_left_fea,
              size: 18,
              color: Colors.blue,
            )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget getProfileHeader() {
    var size = MediaQuery.of(context).size.width * 0.22;
    return Container(
      padding: EdgeInsets.only(left: size * 0.5, right: size * 0.5),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Converter.hexToColor("#F2F2F2"),
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(Globals.correctLink(UserManager.currentUser("avatar")))),
              )),
          Container(
            width: 20,
          ),
          Expanded(
            child: Column(
              textDirection: LanguageManager.getTextDirection(),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  UserManager.currentUser("username"),
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Converter.hexToColor("#707070")),
                ),
                Container(
                  height: 5,
                ),
                InkWell(
                  onTap: () {_navigateAndDisplaySelection(context);},
                  child: Container(
                    alignment: !LanguageManager.getDirection()
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 7, bottom: 7),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Converter.hexToColor("#344F64")),
                      child: Text(
                        LanguageManager.getText(47),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  getAlertDeleteAccount() {
    return
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  InkWell(
                    onTap: () {Navigator.pop(context);},
                    child: Icon(FlutterIcons.x_fea, size: 24),
                  )
                ],
              ),
              Container(child: Icon(FlutterIcons.md_trash_ion, size: 50)),

              Container(height: 5),

              Text('   ' + LanguageManager.getText(280),
                style: TextStyle(color: Converter.hexToColor("#707070"), fontWeight: FontWeight.bold)),

              Container(height: 30),

              Text(
                LanguageManager.getText(279).replaceAll('\\n', '\n'),
                style: TextStyle(
                    color: Converter.hexToColor("#707070"),
                    fontWeight: FontWeight.bold),
              ),
              Container(height: 30),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {Alert.publicClose();},
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(172),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), spreadRadius: 2, blurRadius: 2)],
                          borderRadius: BorderRadius.circular(8),
                          color: Converter.hexToColor("#344f64")),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.pop(context);
                      // cancelOrderConferm();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(169),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), spreadRadius: 2, blurRadius: 2)],
                          borderRadius: BorderRadius.circular(8),
                          color: Converter.hexToColor("#FF0000")),
                    ),
                  ),
                ],
              )
            ],
          ));
  }

  void _navigateAndDisplaySelection(BuildContext context) async {

    // var oldImageUrl = UserManager.currentUser("avatar");
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileEdit()));
    setState(() {});
    // var newImageUrl = UserManager.currentUser("avatar");
    // if(oldImageUrl != newImageUrl){ setState(() {});} // update image

  }

}
