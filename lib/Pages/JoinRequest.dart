import 'dart:async';
import 'dart:typed_data';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'Home.dart';

class JoinRequest extends StatefulWidget {
  const JoinRequest();

  @override
  _JoinRequestState createState() => _JoinRequestState();
}

class _JoinRequestState extends State<JoinRequest> {
  Map<String, String> body = {}, selectedTexts = {}, errors = {};
  Map selectOptions = {};
  bool isLoading = true;
  Map config, data;
  Map slectedListOptions = {};
  List<Map> selectedFiles = [];
  @override
  void initState() {
    // loadConfig();----------------------------------------------
    super.initState();
  }

  void loadConfig() {
    NetworkManager.httpGet(Globals.baseUrl + "join/config",  context, (r) {
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        setState(() {
          config = r["data"];
          data = r['old'];
        });
      }
    }, cashable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          Container(
              decoration: BoxDecoration(color: Converter.hexToColor("#2094cd")),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      EdgeInsets.only(left: 25, right: 25, bottom: 15, top: 30),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            //Navigator.pop(context);
                            }, child: Icon(
                            LanguageManager.getDirection()
                                ? FlutterIcons.chevron_right_fea
                                : FlutterIcons.chevron_left_fea,
                            color: Colors.transparent,
                            size: 26,
                          )),
                      Text(
                        LanguageManager.getText(175),// طلب اشتراك مزود خدمة
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Container()
                      // NotificationIcon(),
                    ],
                  ))),
          Expanded(child: getFormContent()) //          Expanded(child: isLoading ? Center(child: CustomLoading()) : getFormContent()) // -------------
        ]));
  }

  Widget getStatusText() {
    var map = {
      'PENDING': {"text": 216, "color": "#000000"},
      'PROCESSING': {"text": 217, "color": "#DFC100"},
      'ACCEPTED': {"text": 218, "color": "#00710B"},
      'CANCELED': {"text": 219, "color": "#F00000"}
    };
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Converter.hexToColor(map[data['state']]["color"]).withAlpha(15)),
      child: Text(
        LanguageManager.getText(map[data['state']]["text"]),
        textDirection: LanguageManager.getTextDirection(),
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Converter.hexToColor(map[data['state']]["color"])),
      ),
    );
  }

  Widget getFormContent() {
    // if (config == null) return Container();
    if (data != null) {
      return Column(
        children: [
          Container(height: 70),
          SvgPicture.asset("assets/illustration/join.svg", width: 120, height: 120),
          Container(height: 10),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
            child: Text(
              LanguageManager.getText(214),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Converter.hexToColor("#2094CD")),
            ),
          ),
          Container(height: 10),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LanguageManager.getText(215),
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Converter.hexToColor("#344F64")),
                ),
                Container(width: 10),
                getStatusText(),
              ],
            ),
          )
        ],
      );
    }
    List<Widget> items = [];

    // items.add(createSelectInput("service", 200, config['service'], onSelected: (v) {
    //   setState(() {
    //     selectedTexts["service"] = v['name'];
    //     body["service"] = v['id'];
    //     selectOptions["service_catigories"] = v['catigories'];
    //     selectOptions["devices"] = v['devices'];
    //
    //     // clear
    //     selectedTexts["service_catigory"] = null;
    //     body["service_catigory"] = null;
    //     body["device"] = null;
    //   });
    // }));

    // items.add(createSelectInput(
    //     "service_catigory", 201, selectOptions['service_catigories'],
    //     onSelected: (v) {
    //   setState(() {
    //     selectOptions["sub_service_catigory"] = v['children'];
    //     selectedTexts["service_catigory"] = v['name'];
    //     body["service_catigory"] = v['id'];
    //   });
    // }, onEmptyMessage: LanguageManager.getText(204)));
    //
    // items.add(createSelectInput("device", 202, selectOptions['devices'], onSelected: (v) {
    //   var key = "device";
    //   setState(() {
    //     if (slectedListOptions[key] == null) {
    //       slectedListOptions[key] = [];
    //     }
    //     if ((slectedListOptions[key] as List).contains(v)) {
    //       int index = (slectedListOptions[key] as List).indexOf(v);
    //       slectedListOptions[key][index]["fucsed"] = true;
    //     } else
    //       slectedListOptions[key].add(v);
    //   });
    // }, onEmptyMessage: LanguageManager.getText(204)));
    //
    // items.add(getSelectedOptionList("device"));
    //
    // items.add(createSelectInput(
    //     "sub_service_catigory", 203, selectOptions['sub_service_catigory'],
    //     onSelected: (v) {
    //   var key = "sub_service_catigory";
    //   setState(() {
    //     if (slectedListOptions[key] == null) {
    //       slectedListOptions[key] = [];
    //     }
    //     if ((slectedListOptions[key] as List).contains(v)) {
    //       int index = (slectedListOptions[key] as List).indexOf(v);
    //       slectedListOptions[key][index]["fucsed"] = true;
    //     } else
    //       slectedListOptions[key].add(v);
    //   });
    // }, onEmptyMessage: LanguageManager.getText(205)));
    // items.add(getSelectedOptionList("sub_service_catigory"));
    items.add(createInput("first_name"   , 206));
    items.add(createInput("second_name"  , 207));
    items.add(createInput("last_name"    , 208));
    items.add(createInput("email"        , 246, textType: TextInputType.emailAddress,));
    items.add(createInput("friend_number", 209, textType: TextInputType.number));
    items.add(Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Text(
        LanguageManager.getText(210),
        textDirection: LanguageManager.getTextDirection(),
        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
      ),
    ));
    items.add(Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
      child: Text(
        LanguageManager.getText(211),
        textDirection: LanguageManager.getTextDirection(),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ));
    items.add(createImagesPicker());
    items.add(Container(
      padding: EdgeInsets.all(7),
      child: InkWell(
        onTap: send,
        child: Container(
          margin: EdgeInsets.all(10),
          height: 50,
          alignment: Alignment.center,
          child: Text(
            LanguageManager.getText(212),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    ));
    return ScrollConfiguration(
      behavior: CustomBehavior(),
      child: ListView(
          padding: EdgeInsets.symmetric(vertical: 0),
          children: items
      ),
    );
  }

  Widget getSelectedOptionList(key) {
    List<Widget> items = [];
    if (slectedListOptions[key] != null)
      for (var i = 0; i < slectedListOptions[key].length; i++) {
        var item = slectedListOptions[key][i];
        if (item['fucsed'] == true) {
          Timer(Duration(milliseconds: 150), () {
            setState(() {
              slectedListOptions[key][i]["fucsed"] = null;
            });
          });
        }
        items.add(AnimatedContainer(
          duration: Duration(milliseconds: 250),
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: item['fucsed'] == true ? Colors.yellow : Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(20),
                    spreadRadius: 2,
                    blurRadius: 2)
              ]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: LanguageManager.getTextDirection(),
            children: [
              Text(item['name'], style: TextStyle(fontSize: 16, color: Colors.black)),
              Container(width: 10),
              InkWell(
                onTap: () {
                  setState(() {
                    (slectedListOptions[key] as List).remove(item);
                  });
                },
                child: Icon(FlutterIcons.x_fea, color: Colors.red, size: 18),
              )
            ],
          ),
        ));
      }
    return Container(
      padding: EdgeInsets.all(10),
      child: Wrap(
        textDirection: LanguageManager.getTextDirection(),
        children: items,
      ),
    );
  }

  Widget createImagesPicker() {
    double size = (MediaQuery.of(context).size.width - 20) * 0.25;
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Converter.hexToColor(
              errors["images"] != null ? "#E9B3B3" : "#ffffff")),
      child: Wrap(
        textDirection: LanguageManager.getTextDirection(),
        children: selectedFiles.map((e) {
          return Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(10),
              child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(25),
                            spreadRadius: 2,
                            blurRadius: 2)
                      ],
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white),
                  child: Stack(
                    children: [
                      Image.memory(e["data"]),
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedFiles.remove(e);
                            });
                          },
                          child: Container(
                              width: 24,
                              height: 24,
                              color: Colors.white,
                              child: Icon(Icons.delete, size: 22,)),
                        ),
                      )
                    ],
                  )));
        }).toList()
          ..add(Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                pickImage(ImageSource.gallery);
              },
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(25),
                      spreadRadius: 2,
                      blurRadius: 2)
                ], borderRadius: BorderRadius.circular(5), color: Colors.white),
                alignment: Alignment.center,
                child: Icon(
                  FlutterIcons.upload_faw,
                  size: 25,
                ),
              ),
            ),
          )),
      ),
    );
  }

  Widget createInput(key, titel,
      {maxInput, TextInputType textType: TextInputType.text, maxLines}) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      padding: EdgeInsets.only(left: 7, right: 7),
      decoration: BoxDecoration(
          color:
              Converter.hexToColor(errors[key] != null ? "#E9B3B3" : "#F2F2F2"),
          borderRadius: BorderRadius.circular(12)),
      child: TextField(
        onChanged: (t) {
          body[key] = t;
        },
        keyboardType: textType,
        maxLength: maxInput,
        maxLines: maxLines,
        textDirection: LanguageManager.getTextDirection(),
        decoration: InputDecoration(
            hintText: LanguageManager.getText(titel),
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            hintTextDirection: LanguageManager.getTextDirection(),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
      ),
    );
  }

  Widget createSelectInput(key, titel, options, {onEmptyMessage, onSelected}) {
    return GestureDetector(
      onTap: () {
        hideKeyBoard();
        if (options == null) {
          Alert.show(context, onEmptyMessage);
          return;
        }
        Alert.show(context, options,
            type: AlertType.SELECT, onSelected: onSelected);
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
            color: Converter.hexToColor(
                errors[key] != null ? "#E9B3B3" : "#F2F2F2"),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Expanded(
                child: Text(
              selectedTexts[key] != null
                  ? selectedTexts[key]
                  : LanguageManager.getText(titel),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  fontSize: 16,
                  color:
                      selectedTexts[key] != null ? Colors.black : Colors.grey),
            )),
            Icon(
              FlutterIcons.chevron_down_fea,
              color: Converter.hexToColor("#727272"),
              size: 22,
            )
          ],
        ),
      ),
    );
  }

  void send() {
    setState(() {
      errors = {};
    });
    List validateKeys = [
      // "service",
      // "service_catigory",
      "first_name",
      "second_name",
      "last_name",
      "email",
      'images',
    ];

    for (var key in validateKeys) {
      if (body[key] == null || body[key].isEmpty)
        setState(() {
          errors[key] = "_";
        });
    }

    // for (var key in ['device', 'sub_service_catigory']) {
    //   if (slectedListOptions[key] == null || slectedListOptions[key].isEmpty)
    //     errors[key] = "_";
    //   else
    //     body[key] = jsonEncode(slectedListOptions[key]);
    // }
    if (selectedFiles.length == 0) {
      errors["images"] = "_";
    } else {
      errors.remove('images');
    }

    print('heree: $errors');

    if (errors.keys.length > 0) {
      Globals.vibrate();
      return;
    }

    // body['username'] = body['first_name'] + " "+body['last_name'];

    var files = [];
    // print('heree: ${selectedFiles[0]}');
    // selectedFiles[0].keys.forEach((key) {
    //   print('heree: ' + key);
    // });
    body["identity"] = selectedFiles.length.toString(); // '1.' + selectedFiles[0]['type'];

    for (var i = 0; i < selectedFiles.length; i++) {
      var item = selectedFiles[i];
      files.add({
        "name": "image_$i",//"identity",
        "size": "0",
        "file": item['data'],
        "type_name": "image",
        "file_type": item['type'],
        "file_name": "${DateTime.now().toString().replaceAll(' ', '_')}.${item['type']}" //"file_name": "image"
      });
    }

    print('heree_files: $files');

    Alert.startLoading(context);
    NetworkManager().fileUpload(Globals.baseUrl + "provider/create", files, (p) {}, (r) { // join/set
      Alert.endLoading();
      if (r['state'] == true) {
        UserManager.proccess(r['data']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
        // Navigator.pop(context);
        // Alert.show(context, LanguageManager.getText(213));
      }
    }, body: body, context: context);
  }

  void pickImage(ImageSource source) async {
    try {
      ImagePicker _picker = ImagePicker();

      PickedFile pickedFile = await _picker.getImage(
          source: source, maxWidth: 1024, imageQuality: 50);
      if (pickedFile == null) return;
      var extantion = pickedFile.path.split(".").last;
      Uint8List data = await pickedFile.readAsBytes();
      setState(() {
        selectedFiles.add({"type": extantion, "data": data});
      });
    } catch (e) {
      Alert.show(context, LanguageManager.getText(27));
      // error
    }
  }

  void hideKeyBoard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild.unfocus();
    }
  }
}
