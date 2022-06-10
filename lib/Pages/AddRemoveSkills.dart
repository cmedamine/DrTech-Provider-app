import 'dart:async';
import 'dart:convert';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:number_to_word_arabic/number_to_word_arabic.dart';

class AddRemoveSkills extends StatefulWidget {
  AddRemoveSkills();

  @override
  _AddRemoveSkillsState createState() => _AddRemoveSkillsState();
}

class _AddRemoveSkillsState extends State<AddRemoveSkills> with TickerProviderStateMixin {
  Map<String, String> body = {},  errors = {};
  Map  selectedTexts = {};
  List removedSkills = [], editedSkills = [], addSkills = [], mySkills = [], configSkills = [];
  Map<String, TextEditingController> controllers = {};
  bool isLoading = false;


  @override
  void initState() {
    if(UserManager.currentUser("skills") != '')
      mySkills = json.decode(UserManager.currentUser("skills"))?? [];
    print('here_mySkills: $mySkills');
    loadConfig();
    super.initState();
  }

  void loadConfig() {
    NetworkManager.httpGet(Globals.baseUrl + "skills/get",  context, (r) { // services/configuration
      if (r['state'] == true) {
        setState(() {
          configSkills = r['data'];
        });
      }
    }, cashable: true);
  }

  void initBodyData(_data) {
    setState(() {
      mySkills = _data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          TitleBar(() {Navigator.pop(context);}, 401),
          isLoading
              ? Expanded(child: Center(child: CustomLoading()))
              : Expanded(
                  child: ScrollConfiguration(
                  behavior: CustomBehavior(),
                  child: Stack(
                    children: [
                      mySkills.length == 0
                          ? Center(
                            child: Container(
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.blue.withAlpha(10),
                                        spreadRadius: 2,
                                        blurRadius: 10)
                                  ],
                                  color: Converter.hexToColor("#f2f2f2").withAlpha(2),),
                                padding: EdgeInsets.all(25),
                                child: Text(
                                  LanguageManager.getText(416),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                          )
                          : ListView(
                              padding: EdgeInsets.only(top: 0, bottom: 70),
                              children: getMySkills(),
                          ),
                      Container(
                        padding: EdgeInsets.all(10),
                        alignment: Globals.isRtl()?Alignment.bottomLeft:Alignment.bottomRight,
                        child: Wrap(
                          direction: Axis.vertical,
                          crossAxisAlignment : WrapCrossAlignment.center,
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10, left: 10),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withAlpha(65),
                                        spreadRadius: 2,
                                        blurRadius: 2)
                                  ],
                                  color: Converter.hexToColor("#344F64"),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () {
                                    if(selectedTexts.isNotEmpty && selectedTexts.containsKey('edit_offer_status')) selectedTexts.remove('edit_offer_status');
                                    body = {};
                                    Alert.staticContent = getAddSkillForm();
                                    Alert.show(context, Alert.staticContent, type: AlertType.WIDGET, isDismissible: true);
                                  },
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                LanguageManager.getText(372),
                                textDirection: LanguageManager.getTextDirection(),
                                style: TextStyle(
                                    color: Converter.hexToColor("#2094CD"),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ))
        ]));
  }


  List<Widget> getMySkills() {
    List<Widget> items = [];
    int i = 0;

    items.add(Container(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisSize: MainAxisSize.min,
                children: mySkills.map((e) {
                  ++i;
                  return Container(
                    margin: EdgeInsets.only(top: 10,bottom: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Converter.hexToColor("#2094cd"),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 2,
                              spreadRadius: 2)
                        ]),
                        child: Row(
                          textDirection: LanguageManager.getTextDirection(),
                          children: [
                            Container(width: 15),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: LanguageManager.getDirection()
                                      ? BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
                                      : BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                ),
                                  child: Column(
                                    textDirection: LanguageManager.getTextDirection(),
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        child: Row(
                                          textDirection: LanguageManager.getTextDirection(),
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                LanguageManager.getText(417) + ' ' +'${Tafqeet.convert(i.toString())}',
                                                textDirection: LanguageManager.getTextDirection(),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Converter.hexToColor("#2094CD"),
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      addSkills.isNotEmpty && addSkills.contains(e)
                                      ? LinearProgressIndicator()
                                      : Container(height: 1,width: double.infinity,color: Colors.grey.withAlpha(100)),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        child: Row(
                                          textDirection: LanguageManager.getTextDirection(),
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                e[LanguageManager.getDirection()? 'name': 'name_en'].toString(),
                                                textDirection: LanguageManager.getTextDirection(),
                                                style: TextStyle(
                                                    color: Converter.hexToColor("#727272"),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                            ),
                                            // editedSkills.isNotEmpty && editedSkills.contains(e)
                                            //     ? Container(padding: EdgeInsets.only(top: 5,right: 5),child: CustomLoading())
                                            //     : Material(
                                            //   color: Colors.transparent,
                                            //   child: InkWell(
                                            //     onTap: () {
                                            //       //selectedTexts['edit_offer_status'] = e['status'] == 'ACTIVE'? config[0] : config[1];
                                            //       body = {};
                                            //       Alert.staticContent = getAddSkillForm(isEditOffer: true, offer: e);
                                            //       Alert.show(context, Alert.staticContent, type: AlertType.WIDGET, isDismissible: true);
                                            //     },
                                            //     child: Container(
                                            //       padding: EdgeInsets.only(top: 5,right: 5),
                                            //       child: Icon(
                                            //         Icons.edit,
                                            //         color: Colors.blue,
                                            //         size: 23,
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                            removedSkills.isNotEmpty && removedSkills.contains(e)
                                            ? Container(padding: EdgeInsets.only(top: 5,right: 5),child: CustomLoading())
                                            : Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  Timer(Duration(milliseconds: 200), () {
                                                    confirmSkillDelete(e);
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 5,right: 5),
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                    size: 23,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(height: 5,)
                                    ],
                                  ),
                                ),
                            )
                          ],
                        ),
                  );
                }).toList(),
              ),
            ),
          ));

    return items;
  }

  Widget getAddSkillForm({bool isEditOffer = false, Map offer}) {

    return Stack(
      alignment : AlignmentDirectional.bottomCenter,
      children: [
        Container(
          child: ScrollConfiguration(
            behavior: CustomBehavior(),
            child: Container(
              child: ListView(
                shrinkWrap: true,
                children: getListOptions(isEditOffer, offer),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void confirmSkillDelete(Map e) {
    Alert.show(
        context,
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
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      FlutterIcons.x_fea,
                      size: 24,
                    ),
                  )
                ],
              ),
              Container(
                child: Icon(
                  FlutterIcons.trash_faw,
                  size: 50,
                  color: Converter.hexToColor("#707070"),
                ),
              ),
              Container(
                height: 30,
              ),
              Text(
                LanguageManager.getText(418) + '\n\'${e[LanguageManager.getDirection()? 'name' : 'name_en']}\'',
                textDirection: LanguageManager.getTextDirection(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Converter.hexToColor("#707070"),
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 30,
              ),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        removedSkills.add(e);
                        print('here_confirmOfferDelete: \nremovedOffers:$removedSkills \noffers:$mySkills');
                        removeSkill(e);
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(169),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(15),
                                spreadRadius: 2,
                                blurRadius: 2)
                          ],
                          borderRadius: BorderRadius.circular(8),
                          color: Converter.hexToColor("#FF0000")),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Alert.publicClose();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(172),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                  )
                ],
              )
            ],
          ),
        ),
        type: AlertType.WIDGET);
  }

  List<Widget> getListOptions(isEditOffer, offer) {
    List<Widget> contents = [];
    for (var item in configSkills) {
      print('here_Alert_getListOptions: $item');
      contents.add(InkWell(
        onTap: () {
          Navigator.pop(context);
          print('here_Alert_selected_text: ${item['name']} , $selectedTexts');
          selectedTexts['edit_offer_status'] = item;
          print('here_Alert_selected_text: ${item['name']} , $selectedTexts');
          setState(() {
            mySkills.add({
              "id" : "0",
              "name": item["name"],
              "name_en": item["name_en"],
            });
            addSkills.add(mySkills.last);
            addSkill(mySkills.last, item);
            // update(offers.last);
          });
            //proccess
        },
        child: Container(
          height: 40,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black.withAlpha(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: LanguageManager.getTextDirection(),
            children: [
              Text(
                Converter.getRealText(item[LanguageManager.getDirection()? 'name' : 'name_en']),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                textDirection: LanguageManager.getTextDirection(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              Icon(FlutterIcons.add_mdi, color: Colors.black.withAlpha(130),),
            ],
          ),
        ),
      ));
    }

    return contents;
  }

  void removeSkill(Map e) {
    NetworkManager.httpGet(Globals.baseUrl + "provider/skill/remove/${e['id']}",  context, (r) { // services/configuration
      if (r['state'] == true) {
        setState(() {
          UserManager.updateSp('skills', r['data']);
          mySkills = r['data']?? [];
          removedSkills.remove(e);
        });
      }
    });
  }

  void addSkill(Map e, itemConfigSkill) {
    NetworkManager.httpPost(Globals.baseUrl + "provider/skill/create",  context, (r) { // services/configuration
      if (r['state'] == true) {
        setState(() {
          UserManager.updateSp('skills', r['data']);
          mySkills = r['data']?? [];
          addSkills.remove(e);
          // if(UserManager.currentUser("skills") != '')
          //   mySkills.last['id'] = (r['data'] as List).last['id'];
        });
      }
    }, body: {
      'skill_id' : itemConfigSkill['id'].toString(),
      'user_id' : UserManager.currentUser('id'),
    });
  }
}