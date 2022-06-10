import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/NavBarEngineer.dart';
import 'package:dr_tech/Components/SplashEffect.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/Conversations.dart';
import 'package:dr_tech/Pages/Orders.dart';
import 'package:dr_tech/Screens/EngineerServices.dart';
import 'package:dr_tech/Screens/NotificationsScreen.dart';
import 'package:dr_tech/Screens/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  final page;
  const Home({this.page});

  @override
  State<Home> createState() => _HomeEngineerState();
}

class _HomeEngineerState extends State<Home> {
  int iScreenIndex = 0;
  Map<String, String> body = {};
  bool isUploading = false;
  var selectedImage;

  @override
  void initState() {

    if(UserManager.currentUser("avatar").contains('avatars/default.png') || UserManager.currentUser("about") == "")
    Timer(Duration(milliseconds: 200), () {
      Future.delayed(Duration.zero, () {
        Alert.staticContent = alertOnRunApp();
        Alert.show(context, Alert.staticContent, type: AlertType.WIDGET);
        });
    });


    if (widget.page != null) iScreenIndex = widget.page;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Converter.hexToColor("#2094cd")),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    EdgeInsets.only(left: 25, right: 25, bottom: 10, top: 25),
                child: Text(
                  LanguageManager.getText(
                      [249, 250, 35, 45, 46][iScreenIndex]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )),
          ),
          Expanded(
              child: [
            EngineerServices(),
            Conversations(noheader: true),
            Orders(noheader: true),
            NotificationsScreen(),
            ProfileScreen(() {
              setState(() {});
            })
          ][iScreenIndex]),
          Container(
            alignment: Alignment.bottomCenter,
            child: NavBarEngineer(onUpdate: (index) {
              setState(() {
                iScreenIndex = index;
              });
            }, page: iScreenIndex),
          )
        ],
      ),
    );
  }

  alertOnRunApp() {
    var imageSize = MediaQuery.of(context).size.width * 0.32;
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          (!UserManager.currentUser("avatar").contains('avatars/default.png'))
          ? Container()
          : Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(15),
            child: SplashEffect(
              onTap: () async {
                if (isUploading) return;
                await pickImage(ImageSource.gallery);
                if(selectedImage != null) updateImage();
              },
              borderRadius: false,
              showShadow: false,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Converter.hexToColor("#F2F2F2"),
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              Globals.correctLink(UserManager.currentUser("avatar")))),
                    ),
                    child: isUploading
                        ? Container(
                        decoration: BoxDecoration(
                            color: Converter.hexToColor("#000000").withAlpha(70),
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: CustomLoading())
                        : selectedImage != null && !isUploading?
                          Container( child: Image.file(
                            File(pickedFilePath),
                            fit: BoxFit.cover,
                          ))
                    :Container(),
                  ),
                  Container(
                      width: 30,
                      height: 30,
                      padding: EdgeInsets.all(4),
                      child: Icon(MaterialIcons.edit, color: Colors.white, size: 20,),
                      decoration: BoxDecoration(
                          color: Converter.hexToColor("#344f64"),
                          borderRadius: BorderRadius.circular(99)))
                ],
              ),
            ),
          ),
          (!UserManager.currentUser("avatar").contains('avatars/default.png'))
          ? Container()
          : Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Text(
              LanguageManager.getText(406),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ),
          UserManager.currentUser("about") != ""
          ? Container()
          : Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Converter.hexToColor("#F2F2F2")),
            child: TextField(
              onChanged: (r) {
                body['about'] = r;
              },
              textDirection: LanguageManager.getTextDirection(),
              textAlign: LanguageManager.getDirection()
                  ? TextAlign.right
                  : TextAlign.left,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: LanguageManager.getText(330)),
            ),
          ),
          UserManager.currentUser("about") != ""
          ? Container()
          : Container(height: 15),
          UserManager.currentUser("about") != ""
          ? Container()
          : InkWell(
            onTap: () {
              if (UserManager.currentUser("about") == ""  &&  (body['about'] == null || (body['about'] != null && body['about'].length < 3))) return;
              // Navigator.pop(context);
              Alert.startLoading(context);
              UserManager.update("about", body['about'], context ,(r) {
                // DatabaseManager.save("name", name);
                Alert.endLoading();
                if (r['state'] == true) {
                  DatabaseManager.save("about", body['about']);
                  if(!UserManager.currentUser("avatar").contains('avatars/default.png'))
                      Navigator.pop(context);
                  else{
                    Alert.staticContent = alertOnRunApp();
                    Alert.setStateCall = () {};
                    Alert.callSetState();
                  }
                }});
            },
            child: Container(
              height: 45,
              alignment: Alignment.center,
              child: Text(
                LanguageManager.getText(34),
                style: TextStyle(color: Colors.white),
              ),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(15),
                        spreadRadius: 2,
                        blurRadius: 2)
                  ],
                  borderRadius: BorderRadius.circular(8),
                  color: Converter.hexToColor("#344f64")),
            ),
          ),
        ],
      ),
    );
  }

  String pickedFilePath = '';
  Future<void> pickImage(ImageSource source) async {
    try {
      ImagePicker _picker = ImagePicker();

      PickedFile pickedFile = await _picker.getImage(
          source: source, maxWidth: 1024, imageQuality: 50);
      if (pickedFile == null) return;
      pickedFilePath = pickedFile.path;
      var extantion = pickedFile.path.split(".").last;
      Uint8List data = await pickedFile.readAsBytes();
      setState(() {
        selectedImage = data;
      });
    } catch (e) {
      Alert.show(context, LanguageManager.getText(27));
      // error
    }
  }

  void updateImage() {
    if (isUploading) return;
    List files = [];

    files.add({
      "name": "avatar",
      "file": selectedImage,
      "type_name": "image.jpg",
      "file_type": "jpeg",
      "file_name": "${DateTime.now().toString().replaceAll(' ', '_')}.jpeg"
    });


    isUploading = true;
    Alert.staticContent = alertOnRunApp();
    Alert.setStateCall = () {};
    Alert.callSetState();

    NetworkManager().fileUpload(Globals.baseUrl + "users/account/update", files, (p) {}, (r) { // user/updateImage
      if (r['state'] == true) {
        isUploading = false;
        Alert.staticContent = alertOnRunApp();
        Alert.setStateCall = () {};
        Alert.callSetState();
        UserManager.proccess(r['data']);
        if(UserManager.currentUser("about") != "")
          Timer(Duration(milliseconds: 1000), () {
            if(Navigator.canPop(context))
              Navigator.pop(context);
          });

      }
    }, body: body);
  }

}
