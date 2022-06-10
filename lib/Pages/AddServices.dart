import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:image_picker/image_picker.dart';

class AddServices extends StatefulWidget {
  final data;
  AddServices({this.data});

  @override
  _AddServicesState createState() => _AddServicesState();
}

class _AddServicesState extends State<AddServices>
    with TickerProviderStateMixin {
  Map<String, String> body = {}, selectedTexts = {}, errors = {};
  Map selectOptions = {}, config, data;
  List images = [], removedImagesUpdate = [], removedOffers = [];
  Map<String, TextEditingController> controllers = {};
  Map<String, TabController> tabControllers = {};
  bool isLoading = false, isHas3Child = false;
  bool showSelectCountry = false, showSelectCity = false, showSelectStreet = false;
  List<Map> selectedFiles = [], offers = [];

  @override
  void initState() {
    loadConfig();
    super.initState();
  }

  void loadConfig() {
    setState(() { isLoading = true; });
    NetworkManager.httpGet(Globals.baseUrl + "services",  context, (r) { // services/configuration
      if (r['state'] == true) {
        setState(() {
          config = r['data'];
          if (widget.data != null)    load();   else    isLoading = false;
        });
      }
    }, cashable: true);
  }

  void load() {
      setState(() {
        data = widget.data;
        initBodyData();
        isLoading = false;
      });
  }

  void initDataItem(String bodyName, String configName, {String configNameNext = '', int index = -1}) {
    List list = configName == 'service' || configName == 'type'
        ? config[configName]
        : selectOptions[configName]; // for first item


    if (data[bodyName] != null) {
      body[bodyName] = data[bodyName].toString();
      selectedTexts[bodyName] = getNameFromId(list, data[bodyName].toString());

      if (configNameNext.isNotEmpty)
        selectOptions[configNameNext] = list[getIndexFromId(list, data[bodyName].toString())][configNameNext];  // for last item

      if(bodyName == 'type' ) { selectedTexts["type"] = data[bodyName]['name'] ?? ''; body["type"] = data[bodyName]['id'].toString(); }

    } else if (index != -1 && cssss[index] == 1) { // without first item // الكل
      selectedTexts[bodyName] = getNameFromId(list, 'null');
    }



  }

  void initBodyData() {
    offers = [];
    selectedFiles = [];

    if(data['service_id'] != null) {

      cct   = data['country_city_street']           .split('-').map(int.parse).toList();
      cssss = data['cat_subcat_sub1_sub2_sub3_sub4'].split('-').map(int.parse).toList();

      List CCS= (config['service'][getIndexFromId(config['service'],data['service_id'].toString())]['is_country_city_street'] as String).split('-').toList();

      if(CCS[0] == '1') {
        showSelectCountry = true;
        selectedTexts["country_id"] =  getNameFromId(config['countries'], data['country_id'].toString());
        body["country_id"] = data['country_id'].toString();
        if(cct[0] == 0)
          selectOptions["cities"] = config['countries'][getIndexFromId(config['countries'],data['country_id'].toString())]['cities'];
      } else {
        (config['countries'] as List<dynamic>).forEach((element) {
          if((element as Map)['id'].toString() == UserManager.currentUser('country_id')) {
            selectOptions["cities"] = element['cities'];
          }
        });
      }
      if(CCS[1] == '1') {
        showSelectCity = true;
        selectedTexts["city_id"] = getNameFromId(selectOptions["cities"], data['city_id'].toString());
        body["city_id"] = data['city_id'].toString();
        if(cct[1] == 0)
          selectOptions["street"] = selectOptions["cities"][getIndexFromId(selectOptions["cities"],data['city_id'].toString())]['street'];
      }
      if(CCS[2] == '1') {
        showSelectStreet = true;
        selectedTexts["street_id"] = getNameFromId(selectOptions["street"], data['street_id'].toString());
        body["street_id"] = data['street_id'].toString();
      }

    }

    initDataItem('service_id'              , 'service'      , configNameNext: 'categories'    );
    initDataItem('service_categories_id'   , 'categories'   , configNameNext: 'subcategories', index : 0);
    initDataItem('service_subcategories_id', 'subcategories', configNameNext: 'service_sub_2', index : 1);
    initDataItem('sub2_id'                 , 'service_sub_2', configNameNext: 'service_sub_3', index : 2);
    initDataItem('sub3_id'                 , 'service_sub_3', configNameNext: 'service_sub_4', index : 3);
    initDataItem('sub4_id'                 , 'service_sub_4', index : 4);
    initDataItem('type'                    , 'type');

    body['title'] = data["name"];

    body['description'] = data["about"];

    for (var item in data['offers']) {
      offers.add({"details": item['description'], "price": item['price']});
    }

    for (var item in (data['images'] as String).split('||').toList() ) {
      selectedFiles.add({"id": '1', "name": Globals.correctLink(item)});
    }

    controllers['title'] = TextEditingController(text: body['title'] ?? "");
    controllers['description'] = TextEditingController(text: body['description'] ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          TitleBar(() {Navigator.pop(context);}, widget.data == null ? 253 : 254),
          isLoading
              ? Expanded(child: Center(child: CustomLoading()))
              : Expanded(
                  child: ScrollConfiguration(
                  behavior: CustomBehavior(),
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    children: getFormInputs(),
                  ),
                ))
        ]));
  }

  List<Widget> getFormInputs() {
    List<Widget> items = [];

    if (widget.data == null || body['service_id'] != null)
      items.add(createSelectInput("service_id", 283, config['service'], onSelected: (v) {
      setState(() {
        selectOptions["categories"] = v['categories']  ?? [];

        selectedTexts["service_id"] = v['name'];
        body["service_id"] = v['id'].toString();

        selectedTexts['service_categories_id'] = null;
        body["service_categories_id"] = null;

        List CCS = (v['is_country_city_street'] as String).split('-').toList();
        if(CCS[0] == '1') showSelectCountry = true; else {selectedTexts["country_id"] = null; body["country_id"] = null; showSelectCountry = false;}
        if(CCS[1] == '1') showSelectCity    = true; else {selectedTexts["city_id"]    = null; body["city_id"]    = null; showSelectCity    = false;}
        if(CCS[2] == '1') showSelectStreet  = true; else {selectedTexts["street_id"]  = null; body["street_id"]  = null; showSelectStreet  = false;}

        selectedTexts["country_id"] = null;
        body["country_id"]          = null;
        selectedTexts['city_id']    = null;
        body["city_id"]             = null;
        selectedTexts['street_id']  = null;
        body["street_id"]           = null;
        selectOptions["cities"]     = null;
        selectOptions["street"]     = null;

        if(selectOptions.containsKey('subcategories')) selectOptions.remove('subcategories');
        if(selectOptions.containsKey('service_sub_2')) selectOptions.remove('service_sub_2');
        if(selectOptions.containsKey('service_sub_3')) selectOptions.remove('service_sub_3');
        if(selectOptions.containsKey('service_sub_4')) selectOptions.remove('service_sub_4');

        for(int i = 0; i< cssss.length;i++){cssss[i] = 0; }

      });
    }));

    if (isArrayNotEmpty('categories'))
    items.add(createSelectInput("service_categories_id", 256, selectOptions["categories"], onEmptyMessage: LanguageManager.getText(257), onSelected: (v) {
      setState(() {
        selectOptions["subcategories"] = v['subcategories']  ?? [];

        selectedTexts['service_categories_id'] = v['name'];
        body["service_categories_id"] = v['id'].toString();

       // body['title'] = v['name'];

        selectedTexts["service_subcategories_id"] = null;
        body["service_subcategories_id"] = null;
        body["sub2_id"] = null;
        body["sub3_id"] = null;
        body["sub4_id"] = null;

        if(selectOptions.containsKey('service_sub_2')) selectOptions.remove('service_sub_2');
        if(selectOptions.containsKey('service_sub_3')) selectOptions.remove('service_sub_3');
        if(selectOptions.containsKey('service_sub_4')) selectOptions.remove('service_sub_4');

        for(int i = 0; i< cssss.length;i++){ cssss[i] = 0; }

      });
    }));


    items.add(
        isArrayNotEmpty('subcategories')
          ? createSelectInput("service_subcategories_id", 256, selectOptions["subcategories"], onEmptyMessage: LanguageManager.getText(257), onSelected: (v) {
            setState(() {
              selectedTexts["service_subcategories_id"] = v['name'];
              body["service_subcategories_id"] = v['id'].toString();

              selectOptions["service_sub_2"] = v['service_sub_2'] ?? [];

              selectedTexts["sub2_id"] = null;
              body["sub2_id"] = null;
              body["sub3_id"] = null;
              body["sub4_id"] = null;


              if(selectOptions.containsKey('service_sub_3')) selectOptions.remove('service_sub_3');
              if(selectOptions.containsKey('service_sub_4')) selectOptions.remove('service_sub_4');

              for(int i = 0; i< cssss.length;i++){ cssss[i] = 0; }

            });
          })
        : Container());



    items.add(
        isArrayNotEmpty('service_sub_2')
            ? createSelectInput("sub2_id", 256, selectOptions["service_sub_2"], onEmptyMessage: LanguageManager.getText(257), onSelected: (v) {
                  setState(() {
                    selectedTexts["sub2_id"] = v['name'];
                    body["sub2_id"] = v['id'].toString();

                    selectOptions["service_sub_3"] = v['service_sub_3']  ?? [];

                    selectedTexts["sub3_id"] = null;
                    body["sub3_id"] = null;
                    body["sub4_id"] = null;

                    if(selectOptions.containsKey('service_sub_4')) selectOptions.remove('service_sub_4');

                    for(int i = 0; i< cssss.length;i++){ cssss[i] = 0; }
                  });
                })
          : Container());

    items.add(
        isArrayNotEmpty('service_sub_3')
            ? createSelectInput("sub3_id", 256, selectOptions["service_sub_3"], onEmptyMessage: LanguageManager.getText(257), onSelected: (v) {
                  setState(() {
                    selectedTexts["sub3_id"] = v['name'];
                    body["sub3_id"] = v['id'].toString();

                    selectOptions["service_sub_4"] = v['service_sub_4']  ?? [];

                    selectedTexts["sub4_id"] = null;
                    body["sub4_id"] = null;

                    for(int i = 0; i< cssss.length;i++){ cssss[i] = 0; }
                  });
                })
          : Container());

      items.add(
          isArrayNotEmpty('service_sub_4')
          ? createSelectInput("sub4_id", 256, selectOptions["service_sub_4"], onEmptyMessage: LanguageManager.getText(257), onSelected: (v) {
              setState(() {
                selectedTexts["sub4_id"] = v['name'];
                body["sub4_id"] = v['id'].toString();
              });
            })
          : Container());

      print('here_service_type: ${body['service_id']}, ${isArrayNotEmpty('service_id', map: body)}');
    items.add(body['service_id'] != '6' && isArrayNotEmpty('service_id', map: body)
        ? createSelectInput("type", 200, config['type'], onEmptyMessage: LanguageManager.getText(204), onSelected: (v) {
          setState(() {
            selectedTexts["type"] = v['name'];
            body["type"] = v['id'].toString();
          });
        }) : Container());

    items.add(createInput("description", 258, maxInput: 500, maxLines: 4));


    items.add(Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Text(
        LanguageManager.getText(259),
        textDirection: LanguageManager.getTextDirection(),
        style: TextStyle(
            color: Converter.hexToColor("#2094CD"),
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
    ));
    items.add(createImagesPicker());

    if (showSelectCountry) {
      items.add(createSelectInput("country_id", 312, config['countries'], onSelected: (v) {
        setState(() {
          selectOptions["cities"] = v['cities']  ?? [];

          selectedTexts["country_id"] = v['name'];
          body["country_id"] = v['id'].toString();

          selectedTexts['city_id'] = null;
          body["city_id"] = null;
          body["street_id"] = null;

          for(int i = 0; i< cct.length;i++){ cct[i] = 0; }
          if(body["country_id"].toLowerCase() == 'null') cct[0] = 1;
        });
      }));
    } else if(showSelectCity){
      cct[0] = 0;
      print('here_f_orEach: 9');
      (config['countries'] as List<dynamic>).forEach((element) {
        if((element as Map)['id'].toString() == UserManager.currentUser('country_id')) {
          // print('here_element: $element');
          selectOptions["cities"] = element['cities']  ?? [];
        }
      });

    }


    if (showSelectCity && isArrayNotEmpty('cities'))
      items.add(Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Expanded(
            child: createSelectInput("city_id", 107, selectOptions["cities"], onEmptyMessage: LanguageManager.getText(311), onSelected: (v) {
              setState(() {
                selectOptions["street"] = v['street']  ?? [];

                selectedTexts["city_id"] = v['name'];
                body["city_id"] = v['id'].toString();

                selectedTexts['street_id'] = null;
                body["street_id"] = null;

                for(int i = 0; i< cct.length;i++){ cct[i] = 0; }
                if(body["city_id"].toLowerCase() == 'null') cct[1] = 1;
              });
            }),
          ),
          showSelectStreet  &&  isArrayNotEmpty('street')?
          Expanded(
            child: createSelectInput("street_id", 108, selectOptions["street"], onEmptyMessage: LanguageManager.getText(113),onSelected: (v) {
              setState(() {
                selectedTexts["street_id"] = v['name'];
                body["street_id"] = v['id'].toString();

                for(int i = 0; i< cct.length;i++){ cct[i] = 0; }
                if(body["street_id"].toLowerCase() == 'null') cct[2] = 1;

              });
            }),
          ):Container()
        ],
      ));

    items.add(Container(height: 10,));
    items.add(InkWell(
      onTap: widget.data == null ? send : confirmUpdate , //update
      child: Container(
        margin: EdgeInsets.all(10),
        height: 45,
        alignment: Alignment.center,
        child: Text(
          LanguageManager.getText(widget.data == null ? 262 : 254),
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
    return items;
  }

  Widget createImagesPicker() {
    if (tabControllers["images"] == null ||
        tabControllers["images"].length != selectedFiles.length) {
      tabControllers["images"] =
          TabController(length: selectedFiles.length, vsync: this);
      tabControllers["images"].addListener(() {
        setState(() {});
      });
      if (selectedFiles.length > 0)
        tabControllers["images"].index = selectedFiles.length - 1;
    }
    double size = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: size,
              height: size * 0.5,
              child: TabBarView(
                controller: tabControllers["images"],
                children: selectedFiles.map((e) {
                  if (e["id"] != null) {
                    return CachedNetworkImage(imageUrl: e["name"]);
                  } else
                    return Image.memory(e["data"]);
                }).toList(),
              ),
              decoration: BoxDecoration(
                color: Converter.hexToColor(
                    errors["images"] != null ? "#E9B3B3" : "#F2F2F2"),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Container(
                    width: 50,
                  ),
                  Row(
                    children: selectedFiles.map((e) {
                      bool selected = tabControllers["images"].index ==
                          selectedFiles.indexOf(e);
                      return Container(
                        margin: EdgeInsets.only(left: 2, right: 2),
                        width: selected ? 10 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : Converter.hexToColor("#344F64"),
                            borderRadius: BorderRadius.circular(20)),
                      );
                    }).toList(),
                  ),
                  Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      InkWell(
                        onTap: () async {
                          await pickImage(ImageSource.gallery);
                        },
                        child: Container(
                            width: 24,
                            height: 24,
                            child: Icon(
                              Icons.upload_sharp,
                              size: 24,
                            )),
                      ),
                      Container(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            int index = tabControllers['images'].index;
                            if (selectedFiles.isNotEmpty) {
                              if (selectedFiles[index]['id'] != null)
                                removedImagesUpdate.add(selectedFiles[index]['name']);
                              selectedFiles.removeAt(index);
                            }
                          });
                        },
                        child: Container(
                            width: 24,
                            height: 24,
                            child: Icon(Icons.delete, size: 22)),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
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
        Alert.show(context, options, type: AlertType.SELECT, onSelected: onSelected);
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        padding: EdgeInsets.only(left: 7, right: 7),
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
                  color: selectedTexts[key] != null ? Colors.black : Colors.grey),
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

  Widget createInput(key, titel,
      {maxInput, TextInputType textType: TextInputType.text, maxLines}) {
    if (controllers[key] == null) {
      controllers[key] = TextEditingController(
          text: selectedTexts[key] != null ? selectedTexts[key] : "");
    }
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
        controller: controllers[key],
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

  Future<void> pickImage(ImageSource source) async {
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

  List cct   = [0,0,0]; // country_city_street
  List cssss = [0,0,0,0,0]; // cat_subcat_sub1_sub2_sub3_sub4

  void setAll(String key, {bool isUpdateDoNotRemove = false, bool notAll = false}){
    print('here_setAll: key: $key, cssss: $cssss, cct: $cct');
    switch(key){
      case 'service_categories_id'    :  cssss[0] = (notAll ? 0 : 1); break;
      case 'service_subcategories_id' :  cssss[1] = (notAll ? 0 : 1); break;
      case 'sub2_id' :  cssss[2] = (notAll ? 0 : 1); break;
      case 'sub3_id' :  cssss[3] = (notAll ? 0 : 1); break;
      case 'sub4_id' :  cssss[4] = (notAll ? 0 : 1); break;

      case 'country_id' :  cct[0] = (notAll ? 0 : 1); break;
      case 'city_id'    :  cct[1] = (notAll ? 0 : 1); break;
      case 'street_id'  :  cct[2] = (notAll ? 0 : 1); break;
    }
    if(! isUpdateDoNotRemove && body[key].toLowerCase() == "null") {
      print('here_setAll: remove key: $key');
      body.remove(key);
    } else {
      print('here_setAll: remove not key: $key');
    }
    body['cat_subcat_sub1_sub2_sub3_sub4'] = '${cssss[0]}-${cssss[1]}-${cssss[2]}-${cssss[3]}-${cssss[4]}';
    body['country_city_street'] = '${cct[0]}-${cct[1]}-${cct[2]}';

    print('here_setAll: body: $body');
  }

  void validate({bool isUpdateDoNotRemove = false}){
    setState(() { errors = {}; });

    List validateKeys = ["service_id", "description"]; // ,"service"

    if(cct[0] == 0 && showSelectCountry == true)          validateKeys.add('country_id');

    if(cct[0] == 0 && cct[1] == 0 && showSelectCity == true)             validateKeys.add('city_id');

    if(cct[0] == 0 && cct[1] == 0 && cct[2] == 0 && showSelectStreet == true)           validateKeys.add('street_id');

    if(cssss[0] == 0 && isArrayNotEmpty("categories"))    validateKeys.add('service_categories_id');

    if(cssss[1] == 0 && isArrayNotEmpty("subcategories")) validateKeys.add('service_subcategories_id');

    if(cssss[2] == 0 && isArrayNotEmpty("service_sub_2")) validateKeys.add('sub2_id');

    if(cssss[3] == 0 && isArrayNotEmpty("service_sub_3")) validateKeys.add('sub3_id');

    if(cssss[4] == 0 && isArrayNotEmpty("service_sub_4")) validateKeys.add('sub4_id');


    for (var key in validateKeys) {
      print('here_setAll: key-: $key, value: ${body[key]}');
      if (body[key] == null || body[key].isEmpty)
        setState(() {
          errors[key] = "_";
        });
      else if(body[key].toString().toLowerCase() == "null") {
        setAll(key.toString(), isUpdateDoNotRemove: isUpdateDoNotRemove);
      } else
        setAll(key.toString(), isUpdateDoNotRemove: isUpdateDoNotRemove, notAll: true);
    }

    if (selectedFiles.length == 0 && images.length == 0) {
      errors["images"] = "_";
    }

    print('here_errors: $errors');

  }

  void send() {

    validate();

    if (errors.keys.length > 0) return;

    var isCountryCityStreet = config['service'][getIndexFromId(config['service'],body['service_id'].toString())]['is_country_city_street'];
    if(isCountryCityStreet.toString().contains('1') && ((body.containsKey('country_id') && body["country_id"] == null) || (!body.containsKey('country_id')))){
      body["country_id"] = UserManager.currentUser('country_id');
    }

    List files = [];

    var i = 0;
    for (var item in selectedFiles) {
      if (item['id'] == null) {
        files.add({
          "name": "image_$i",
          "file": item['data'],
          "type_name": "image",
          "file_type": item['type'],
          "file_name": "${DateTime.now().toString().replaceAll(' ', '_')}.${item['type']}"
        });
        i++;
      }
    }
    body["images_length"] = files.length.toString();
    body['offers'] = jsonEncode(offers);
    body['service_subcategories_id'] == null? body.remove('service_subcategories_id') : null;
    print('here_body: $body');
    body.removeWhere((key, value) {
      return (value == null || (value != null && value == 'null'))? true : false;
    });

    Alert.startLoading(context);
    NetworkManager().fileUpload(Globals.baseUrl + "provider/service/create", files, (p) {},  (r) { // services/add
      Alert.endLoading();
      if (r['state'] == true) {
        Navigator.of(context).pop(true);
      } else if (r["message"] != null) {
        Alert.show(context, Converter.getRealText(r["message"]));
      }
    }, body: body);

  }

  void confirmUpdate() {
    if( data['status'].toString().toUpperCase() != 'ACCEPTED') {update(); return;}
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
                  FlutterIcons.info_fea,
                  size: 60,
                  color: Converter.hexToColor("#2094CD"),
                ),
              ),
              Container(
                height: 30,
              ),
              Text(
                LanguageManager.getText(323), // "سيتم تحويل الخدمة إلى المراجعة من قبل الإدارة هل أنت متأكد من إرسال طلب التعديل؟
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
                      Alert.publicClose();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
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
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      update();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(170),
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
                          color: Converter.hexToColor("#2094CD")),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        type: AlertType.WIDGET);
  }

  void update() {

    validate(isUpdateDoNotRemove: true);

    if (errors.keys.length > 0) return;

    var isCountryCityStreet = config['service'][getIndexFromId(config['service'],body['service_id'].toString())]['is_country_city_street'];
    if(isCountryCityStreet.toString().contains('1') && ((body.containsKey('country_id') && body["country_id"] == null) || (!body.containsKey('country_id')))){
      body["country_id"] = UserManager.currentUser('country_id');
    }

    List files = [];

    var i = 0;
    for (var item in selectedFiles) {
      if (item['id'] == null) {
        files.add({
          "name": "image_$i",
          "file": item['data'],
          "type_name": "image",
          "file_type": item['type'],
          "file_name": "${DateTime.now().toString().replaceAll(' ', '_')}.${item['type']}"
        });
        i++;
      }
    }
    body["images_length"] = files.length.toString();
    body['offers'] = jsonEncode(offers);
    body['removed_images'] = jsonEncode(removedImagesUpdate);
    body.forEach((key, value) {
      if(value == null)
        body[key] = value.toString().toUpperCase();
    });

    Alert.startLoading(context);
    NetworkManager().fileUpload(Globals.baseUrl + "provider/service/update/${widget.data['id']}", files, (p) {},   (r) { // services/add
      Alert.endLoading();
      if (r['state'] == true) {
        Navigator.of(context, rootNavigator: true)..pop(true)..pop(true);
      } else if (r["message"] != null) {
        Alert.show(context, Converter.getRealText(r["message"]));
      }
    }, body: body);
  }

  getNameFromId(List config, String id) {
    var name = '';
    if(id.toLowerCase() == 'null') {
      print('here_f_orEach: 15 config: $config, id: $id ${id.toLowerCase() == 'null'}');
      return LanguageManager.getText(112);
    } else if (config == null){
      print('here_f_orEach: 15 config: $config, id: $id');
      return LanguageManager.getText(112);
    }

    config.forEach((element) {
      if((element as Map)['id'].toString() == id){
        name =  (element as Map)['name'];
        return name;
      }
    });
    return name;
  }

  getIndexFromId(List config, String id) {
    var index = 0, i = 0;
    if(id.toLowerCase() == 'null') {
      print('here_f_orEach: 16 config: $config, id: $id ${id.toLowerCase() == 'null'}');
      return 1;
    } else if (config == null){
      print('here_f_orEach: 16 config: $config, id: $id');
      return 1;
    }
    config.forEach((element) {
      if((element as Map)['id'].toString() == id){
        index =  i;
        return index;
      }
      i++;
    });
    return index;
  }

  bool isArrayNotEmpty(String s, {Map map}) {
    if(map != null)
      return map.containsKey(s)
          && map[s] != null
          && map[s].length > 0;

    return selectOptions.containsKey(s)
        && selectOptions[s] != null
        && selectOptions[s].length > 0;
  }

}