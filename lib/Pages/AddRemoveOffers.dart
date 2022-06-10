import 'dart:async';
import 'dart:convert';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:number_to_word_arabic/number_to_word_arabic.dart';

class AddRemoveOffers extends StatefulWidget {
  final data;
  AddRemoveOffers({this.data});

  @override
  _AddRemoveOffersState createState() => _AddRemoveOffersState();
}

class _AddRemoveOffersState extends State<AddRemoveOffers>
    with TickerProviderStateMixin {
  Map<String, String> body = {},  errors = {};
  Map  selectedTexts = {};
  List removedOffers = [], editedOffers = [], addOffers = [], offers = [];
  Map<String, TextEditingController> controllers = {};
  bool isLoading = false;
  bool visibleOfferStates = false;
  var config = [
    {'status': 'ACTIVE', 'text': LanguageManager.getText(359)},
    {'status': 'NOT_ACTIVE', 'text': LanguageManager.getText(360)}
  ];

  @override
  void initState() {
    load();
    super.initState();
  }


  void load() {
    setState(() {
      isLoading = true;
    });

    NetworkManager.httpGet(Globals.baseUrl + "provider/service/offers/${widget.data['id']}",  context, (r) { // user/service?id=${widget.id}
      setState(() {isLoading = false;});
      if (r['state'] == true) {
        initBodyData(r['data']);
      }
    });
  }

  void initBodyData(_data) {
    setState(() {
      offers = _data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          TitleBar(() {Navigator.pop(context);}, 354),
          isLoading
              ? Expanded(child: Center(child: CustomLoading()))
              : Expanded(
                  child: ScrollConfiguration(
                  behavior: CustomBehavior(),
                  child: Stack(
                    children: [
                      offers.length == 0
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
                                  LanguageManager.getText(263),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                          )
                          : ListView(
                              padding: EdgeInsets.only(top: 0, bottom: 70),
                              children: getOffers(),
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
                                    visibleOfferStates = false;
                                    if(selectedTexts.isNotEmpty && selectedTexts.containsKey('edit_offer_status')) selectedTexts.remove('edit_offer_status');
                                    body = {};
                                    Alert.staticContent = getAddOfferForm();
                                    Alert.show(context, Alert.staticContent, type: AlertType.WIDGET, isDismissible: false);
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
                                LanguageManager.getText(260),
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


  List<Widget> getOffers() {
    List<Widget> items = [];
    int i = 0;

    items.add(Container(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisSize: MainAxisSize.min,
                children: offers.map((e) {
                  ++i;
                  return Container(
                    margin: EdgeInsets.only(top: 10,bottom: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: e['status'] == 'ACTIVE'? Converter.hexToColor("#2094cd") : Colors.red,
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
                                                LanguageManager.getText(352) + ' ' +'${Tafqeet.convert(i.toString())}',
                                                textDirection: LanguageManager.getTextDirection(),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Converter.hexToColor("#2094CD"),
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Text(
                                              e["price"].toString() + " " + Globals.getUnit(isUsd: widget.data["service_target"]),
                                              textDirection: LanguageManager.getTextDirection(),
                                              style: TextStyle(
                                                  color: Converter.hexToColor("#2094CD"),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      addOffers.isNotEmpty && addOffers.contains(e)
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
                                                e["description"].toString(),
                                                textDirection: LanguageManager.getTextDirection(),
                                                style: TextStyle(
                                                    color: Converter.hexToColor("#727272"),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                            ),
                                            editedOffers.isNotEmpty && editedOffers.contains(e)
                                                ? Container(padding: EdgeInsets.only(top: 5,right: 5),child: CustomLoading())
                                                : Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  visibleOfferStates = false;
                                                  selectedTexts['edit_offer_status'] = e['status'] == 'ACTIVE'? config[0] : config[1];
                                                  body = {};
                                                  Alert.staticContent = getAddOfferForm(isEditOffer: true, offer: e);
                                                  Alert.show(context, Alert.staticContent, type: AlertType.WIDGET, isDismissible: false);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 5,right: 5),
                                                  child: Icon(
                                                    Icons.edit,
                                                    color: Colors.blue,
                                                    size: 23,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            removedOffers.isNotEmpty && removedOffers.contains(e)
                                            ? Container(padding: EdgeInsets.only(top: 5,right: 5),child: CustomLoading())
                                            : Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  Timer(Duration(milliseconds: 200), () {
                                                    confirmOfferDelete(e);
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

  Widget getAddOfferForm({bool isEditOffer = false, Map offer}) {
    List<Widget> items = [];

    if(!isEditOffer && selectedTexts['edit_offer_status'] == null)
      selectedTexts['edit_offer_status'] = config[0];

    items.add(Container(
      padding: EdgeInsets.all(10),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          Text(
            LanguageManager.getText(isEditOffer? 356 : 260),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              child: Icon(Icons.close),
            ),
          ),
        ],
      ),
    ));
    items.add(createInput("offer_price", 95, textType: TextInputType.number));
    items.add(createInput("offer_description", 261, maxLines: 4, maxInput: 200));
    items.add(GestureDetector(
      onTap: () {
        print('here_selectedTexts: selectedTexts: $selectedTexts, body: $body');
        showOffers(isEditOffer, offer);
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        padding: EdgeInsets.only(left: 7, right: 7),
        decoration: BoxDecoration(
            color: Converter.hexToColor(errors['provider_service_id'] != null ? "#E9B3B3" : "#F2F2F2"),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Expanded(
                child: Text(
                  selectedTexts['edit_offer_status'] != null
                      ? selectedTexts['edit_offer_status']['text']
                      : LanguageManager.getText(268),
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      fontSize: 16,
                      color: selectedTexts['edit_offer_status'] != null ? Colors.black : Colors.grey),
                )),
            Icon(
              FlutterIcons.chevron_down_fea,
              color: Converter.hexToColor("#727272"),
              size: 22,
            )
          ],
        ),
      ),
    ));
    items.add(InkWell(
      onTap: () {

        if(isEditOffer && controllers['offer_price'].text.isNotEmpty && controllers['offer_description'].text.isNotEmpty){
          editedOffers.add(offer);
          setState(() {
            editedOffers.add({
            "id"         : "${offer['id']}",
            "price"      : controllers['offer_price'].text,
            "description": controllers['offer_description'].text,
            "provider_service_id" : "${widget.data['id']}",
            "status" : "${selectedTexts['edit_offer_status']['status']}",
          });
          });
          editOffer(editedOffers.last);
          Navigator.pop(context);
          return;
        }

        if (body['offer_price'] == null ||
            body['offer_description'] == null ||
            body['offer_price'].isEmpty ||
            body['offer_description'].isEmpty) {
          Alert.show(context, LanguageManager.getText(264));
          return;
        }
        setState(() {
          offers.add({
            "id" : "0",
            "price": body["offer_price"],
            "description": body["offer_description"],
            "status" : "${selectedTexts['edit_offer_status']['status']}",
          });
          addOffers.add(offers.last);
          update(offers.last);
        });
        body['offer_price'] = "";
        body['offer_description'] = "";
        controllers["offer_price"].text = "";
        controllers["offer_description"].text = "";
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.all(10),
        height: 45,
        alignment: Alignment.center,
        child: Text(
          LanguageManager.getText(isEditOffer? 356 : 260),
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
    ));

    if(isEditOffer&& body.isEmpty){
      body['offer_price'] = offer['price'].toString();
      body['offer_description'] = offer['description'].toString();
    }
    controllers['offer_price'].text = isEditOffer && body.isEmpty? offer['price'].toString() : (body['offer_price'] ?? '');
    controllers['offer_description'].text = isEditOffer && body.isEmpty? offer['description'].toString() : (body['offer_description'] ??'');

    return Stack(
      alignment : AlignmentDirectional.bottomCenter,
      children: [
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items,
          ),
        ),
        visibleOfferStates
        ? Container(
          child: InkWell(
            onTap: ()=> showOffers(isEditOffer, offer),
            highlightColor: Colors.green,
            splashColor: Colors.red,
            child: Container(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 120, right: 20, left: 20),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(20),
                            spreadRadius: 5,
                            blurRadius: 5)
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  child: ScrollConfiguration(
                    behavior: CustomBehavior(),
                    child: Container(
                      child: ListView(
                        shrinkWrap: true,
                        children: getListOptions(isEditOffer, offer),
                      ),
                    ),
                  ),
                )
            ),
          ),
        )
        : Container(height: 1)
      ],
    );
  }


  Widget createInput(key, titel,
      {maxInput, TextInputType textType: TextInputType.text, maxLines}) {
    if (controllers[key] == null) {
        controllers[key] = TextEditingController(text: selectedTexts[key] != null ? selectedTexts[key] : "");
    }
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      padding: EdgeInsets.only(left: 7, right: 7),
      decoration: BoxDecoration(
          color:
              Converter.hexToColor(errors[key] != null ? "#E9B3B3" : "#F2F2F2"),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Expanded(
            child: TextField(
              onChanged: (t) {
                body[key] = t;
              },
              keyboardType: textType,
              maxLength: maxInput,
              maxLines: maxLines,
              controller: controllers[key],
              textDirection: LanguageManager.getTextDirection(),
              decoration: InputDecoration(
                  hintText: LanguageManager.getText(titel),
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  hintTextDirection: LanguageManager.getTextDirection(),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
            ),
          ),
          key != 'offer_price'
          ? Container()
          : Text(
              Converter.getRealText(Globals.getUnit(isUsd: widget.data['service_target'])) ,
              style: TextStyle(fontSize: 15),
            )
        ],
      ),
    );
  }

  void confirmOfferDelete(Map e) {
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
                LanguageManager.getText(355),
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
                        removedOffers.add(e);
                        print('here_confirmOfferDelete: \nremovedOffers:$removedOffers \noffers:$offers');
                        update(e);
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

  void update(offer) {
    if (removedOffers.isEmpty && addOffers.isEmpty) return;
    print('here_update: removedOffers: ${removedOffers.length}, addOffers: ${addOffers.length}, offers: ${offers.length},');
    //body['offers'] = jsonEncode(offers);

    if(addOffers.isNotEmpty && offer['id'] == "0") {
      body['added_offers'] = jsonEncode([offer]);
      body.remove('removed_offers');
    } else if(removedOffers.isNotEmpty ) {
      body['removed_offers'] = jsonEncode([offer]);
      body.remove('added_offers');
    }

    NetworkManager.httpPost(Globals.baseUrl + "provider/service/offers/update/${widget.data['id']}", context, (r) { // services/add
      if (r['state'] == true) {
        if(removedOffers.isNotEmpty) offers.remove(removedOffers.first);
        if(removedOffers.length <= 1) body.remove('removed_offers');
        if(addOffers.length <= 1) body.remove('added_offers');
        offer['id'] == "0" ? addOffers.remove(offer) : removedOffers.remove(offer);
        initBodyData(r['data']);
        print('here done');
      } else if (r["message"] != null) {
        removedOffers = [];
        addOffers = [];
        setState(() {});
        Alert.show(context, Converter.getRealText(r["message"]));
      }
    }, body: body);
  }

  void editOffer(Map offer) {
    if (editedOffers.isEmpty) return;
    NetworkManager.httpPost(Globals.baseUrl + "provider/service/offer/edit/${offer['id']}", context, (r) { // services/add
      if (r['state'] == true) {
        editedOffers.remove(editedOffers[editedOffers.indexOf(offer) - 1]);
        editedOffers.remove(offer);
        initBodyData(r['data']);
      } else if (r["message"] != null) {
        editedOffers = [];
        setState(() {});
      }
    }, body: offer);
  }

  void showOffers(bool isEditOffer, Map offer) {
    print('here_selectedTexts: selectedTexts: $selectedTexts, body: $body');
    visibleOfferStates = !visibleOfferStates;
    Alert.staticContent = getAddOfferForm(isEditOffer: isEditOffer, offer: offer);
    Alert.setStateCall = () {};
    Alert.callSetState();
    setState((){});
  }

  List<Widget> getListOptions(isEditOffer, offer) {
    List<Widget> contents = [];

    for (var item in config) {
      print('here_Alert_getListOptions: $item');
      contents.add(InkWell(
        onTap: () {
          print('here_Alert_selected_text: ${item['text']} , $selectedTexts');
          //allowEmptyOffer = false;
          selectedTexts['edit_offer_status'] = item;
          print('here_Alert_selected_text: ${item['text']} , $selectedTexts');
          //offer['provider_service_id'] = item['id'].toString();
          showOffers(isEditOffer, offer);
        },
        child: Container(
          height: 40,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black.withAlpha(5),
          ),
          child: Text(
            Converter.getRealText(item['text']),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
        ),
      ));
    }

    return contents;
  }
}