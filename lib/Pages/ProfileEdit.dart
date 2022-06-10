import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/SplashEffect.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';

import 'AddRemoveSkills.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit();

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  Map controllers = {}, selectedTexts = {}, body = {}, errors = {}, socialMediaLinks = {};
  var selectedImage;
  bool isUploading = false;
  List skills = [];

  @override
  void initState() {
    selectedTexts["full_name"] = UserManager.currentUser("first_name") +
        " " +
        UserManager.currentUser("second_name") +
        " " +
        UserManager.currentUser("last_name");
    selectedTexts["email"] = UserManager.currentUser("email")??'';
    selectedTexts["about"] = UserManager.currentUser("about")??'';
    socialMediaLinks = json.decode(UserManager.currentUser("social_media_links"));
    selectedTexts["twitter"] = socialMediaLinks['twitter'];
    selectedTexts["facebook"] = socialMediaLinks['facebook'];
    selectedTexts["telegram"] = socialMediaLinks['telegram'];
    selectedTexts["instagram"] = socialMediaLinks['instagram'];

    print("here_skills ${UserManager.currentUser("skills")}");
    if(UserManager.currentUser("skills") != '')
      skills = json.decode(UserManager.currentUser("skills"))?? [];
    skills.add({"id":0,"name":"إضافة","name_en":"Add"});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var imageSize = MediaQuery.of(context).size.width * 0.32;
    return Scaffold(
      body:
          Column(textDirection: LanguageManager.getTextDirection(), children: [
            TitleBar(() {Navigator.pop(context);}, 269),
            Expanded(
                child: ScrollConfiguration(
                    behavior: CustomBehavior(),
                    child: ListView(
                      padding: EdgeInsets.symmetric(vertical: 0),
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(15),
                          child: InkWell(
                            onTap: () async {
                              if (isUploading) return;
                              await pickImage(ImageSource.gallery);
                              if(selectedImage != null) updateImage();
                            },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                    width: imageSize,
                                    height: imageSize,
                                  margin: EdgeInsets.all(10),
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
                                        : Container(),
                                    ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  padding: EdgeInsets.all(4),
                                child: Icon(MaterialIcons.edit, color: Colors.white, size: 20),
                                decoration: BoxDecoration(
                                    color: Converter.hexToColor("#344f64"),
                                    borderRadius: BorderRadius.circular(99)))
                              ],
                            ),
                          ),
                        ),
                        createInput("full_name", 243, readOnly: true),
                        // createInput("first_name", 206),
                        // createInput("second_name", 207),
                        // createInput("last_name", 208),
                        createInput("email", 246),
                        // createInput("specialty", 270, readOnly: true),
                        // createInput("city", 271, readOnly: true),
                        createTitle(272),
                        createInput("about", 0, maxLines: 3, maxInput: 250, textType: TextInputType.multiline),
                        createTitle(401),
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
                          child: Wrap(
                              textDirection: LanguageManager.getTextDirection(),
                              children: List<Widget>.generate(skills.length, (index) {
                                return createItemSkill(skills[index][LanguageManager.getDirection() ? 'name' : 'name_en'], index);
                              })
                          ),
                        ),
                        createTitle(414),
                        createInput("twitter", 410, textType: TextInputType.emailAddress),
                        createInput("facebook", 411, textType: TextInputType.emailAddress),
                        createInput("telegram", 412, textType: TextInputType.emailAddress),
                        createInput("instagram", 413, textType: TextInputType.emailAddress),

                      ],
                    ))),
            InkWell(
              onTap: update,
              child: Container(
                margin: EdgeInsets.all(10),
                height: 45,
                alignment: Alignment.center,
                child: Text(
                  LanguageManager.getText(170),
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      ]),
    );
  }

  Widget createInput(key, title, {maxInput, TextInputType textType: TextInputType.text, maxLines, bool readOnly: false}) {
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
        readOnly: readOnly,
        textDirection: LanguageManager.getTextDirection(),
        decoration: InputDecoration(
            hintText: title == 0?'':LanguageManager.getText(title),
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
        selectedImage = data;
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

  void update() {
    hideKeyBoard();
    print('here_body: $body');
    print('here_body: ${body.length}');

    if(body.containsKey('twitter') || body.containsKey('facebook') ||
       body.containsKey('telegram') || body.containsKey('instagram')) {
      body['social_media_links'] = jsonEncode({
        'twitter' : body['twitter'] ?? selectedTexts['twitter'],
        'facebook' : body['facebook'] ?? selectedTexts['facebook'],
        'telegram' : body['telegram'] ?? selectedTexts['telegram'],
        'instagram' : body['instagram'] ?? selectedTexts['instagram'],
      }).toString();
    }

    if(body.length > 0) {
      Alert.startLoading(context);
      body["username"] = UserManager.currentUser("first_name") + " " +UserManager.currentUser("last_name");
      UserManager.updateBody(body,  context, (r) {
        Alert.endLoading();
      });
    }else{
      Alert.show(context, LanguageManager.getText(281));
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


    setState(() {
      isUploading = true;
    });
    NetworkManager().fileUpload(Globals.baseUrl + "users/account/update", files, (p) {}, (r) { // user/updateImage
      setState(() {
        isUploading = false;
      });
      if (r['state'] == true) {
        UserManager.proccess(r['data']);
      } else if (r["message"] != null) {
        Alert.show(context, Converter.getRealText(r["message"]));
      }
    }, body: body);
  }

  createTitle(int textIndex) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Text(
        LanguageManager.getText(textIndex),
        textDirection: LanguageManager.getTextDirection(),
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Converter.hexToColor("#2094CD")),
      ),
    );
  }

  createItemSkill(String str, int index) {

    return SplashEffect(
      onTap: index != skills.length - 1? null : () async {
        await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddRemoveSkills()));
          setState(() {
            skills = json.decode(UserManager.currentUser("skills"))?? [];
            skills.add({"id":0,"name":"إضافة","name_en":"Add"});
          });
      },
      showShadow: false,
      child: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: index == skills.length - 1 ? Converter.hexToColor( '#344f64') : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Converter.hexToColor(index == skills.length - 1 ? '#344f64' :'#707070'),
              width: 1,
            ),
          ),
          child: index != skills.length - 1
          ? Text(str, style: TextStyle(color: Colors.black, fontSize: 14))
          : Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: LanguageManager.getTextDirection(),
            children: [
              Text(str, style: TextStyle(color: Colors.white, fontSize: 14), textDirection: LanguageManager.getTextDirection()),
              Container(width: 5),
              Icon(MaterialIcons.edit, color: Colors.white, size: 15),
            ],
          )
      ),
    );
  }
}
