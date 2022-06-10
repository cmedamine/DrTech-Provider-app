import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/WebBrowser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentOptions extends StatefulWidget {
  final id, messageId;
  PaymentOptions(this.id, this.messageId);

  @override
  _PaymentOptionsState createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  List data;
  String selectedPaymentOption = "";
  @override
  void initState() {
    load();
    super.initState();
  }

  void load() {
    NetworkManager.httpGet(Globals.baseUrl + "payment/load",  context, (r) {
      if (r['state'] == true) {
        setState(() {
          data = r['data'];
        });
      }
    }, cashable: true);
  }

  @override
  Widget build(BuildContext context) {
    if (data == null)
      return Container(
        height: 30,
        child: CustomLoading(),
        alignment: Alignment.center,
      );
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: getList(),
      ),
    );
  }

  List<Widget> getList() {
    List<Widget> items = [];
    items.add(Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Container(
            width: 20,
          ),
          Text(
            LanguageManager.getText(126),
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.blue),
          ),
          InkWell(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: Icon(FlutterIcons.x_fea)),
        ],
      ),
    ));
    items.add(Container(
      height: 20,
    ));
    for (var item in data) {
      items.add(getPaymentMethod(item));
    }
    items.add(Container(
      height: 20,
    ));
    items.add(InkWell(
      onTap: selectedPaymentOption.isEmpty ? null : excutePayment,
      child: Container(
        height: 45,
        alignment: Alignment.center,
        child: Text(
          LanguageManager.getText(136),
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(15),
                  spreadRadius: 2,
                  blurRadius: 2)
            ],
            borderRadius: BorderRadius.circular(8),
            color: Converter.hexToColor("#344f64")
                .withAlpha(selectedPaymentOption.isEmpty ? 100 : 255)),
      ),
    ));
    return items;
  }

  Widget getPaymentMethod(itemKey) {
    switch (itemKey) {
      case "CACH":
        return getPaymentOption(134, "payment-cash", "CACH");
        break;
      case "CARD":
        return getPaymentOption(135, "visa", "CARD");
        break;
      default:
    }
    return Container();
  }

  Widget getPaymentOption(text, icon, key) {
    return InkWell(
        onTap: () {
          setState(() {
            selectedPaymentOption = key;
          });
        },
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            textDirection: LanguageManager.getTextDirection(),
            children: [
              Container(
                alignment: Alignment.center,
                child: Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(width: 3, color: Colors.grey)),
                  child: key == selectedPaymentOption
                      ? Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey),
                        )
                      : null,
                ),
              ),
              Container(
                width: 15,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 2,
                            spreadRadius: 2)
                      ]),
                  child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      SvgPicture.asset("assets/icons/$icon.svg"),
                      Container(
                        width: 30,
                      ),
                      Text(
                        LanguageManager.getText(text),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void excutePayment() async {
    if (selectedPaymentOption.isEmpty) {
      return;
    }
    if (selectedPaymentOption == "CACH")
      offerAccept('');
    else {
      String url = [
        Globals.baseUrl,
        "payment/offer/?user=",
        UserManager.currentUser(Globals.authoKey),
        "&id=",
        widget.id,
        "&message_id=",
        widget.messageId,
        "&method=",
        "2"
      ].join();

      var results = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => WebBrowser(url, LanguageManager.getText(228))));
      if (results == null) {
        Alert.show(context, LanguageManager.getText(240));
        return;
      }
      onResponce(results);
    }
  }

  void offerAccept(paymentToken) {
    Map<String, String> body = {
      "message_id": widget.messageId,
      "id": widget.id,
      "token": paymentToken
    };
    Alert.startLoading(context);
    NetworkManager.httpPost(Globals.baseUrl + "orders/set",  context, (r) {
      Alert.endLoading();
      onResponce (r);
    }, body: body);
  }

  void onResponce  (r) {
    if (r['state'] == true) {
      Navigator.of(context).pop(true);
    }
  }
}
