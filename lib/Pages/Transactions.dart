import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/EmptyPage.dart';
import 'package:dr_tech/Components/Recycler.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/AllTransactions.dart';
import 'package:dr_tech/Pages/WebBrowser.dart';
import 'package:dr_tech/Pages/Withdrawal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Transactions extends StatefulWidget {
  const Transactions();

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> with WidgetsBindingObserver {
  // Map<int, List> data = {};
  Map data = {};
  bool isloading = false;
  var balance, commission, balanceOnline, commissionOnline, earnings;
  Map errors = {},body = {};
  int page = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    load();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void load() {
    // if (page > 0 && data.values.last.length == 0) return;
    setState(() {
      isloading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "provider/statistics", context, (r) {
          setState(() {
            isloading = false;
          });
          if (r['state'] == true) {
            setState(() {
              data[page] = r['data'];
              balance = r['data']['revenue'];
              commission = r['data']['commission'];
              balanceOnline = r['data']['revenue_online'];
              commissionOnline = r['data']['commission_online'];
              earnings = r['data']['earnings'];

              // page++;
            });
          }
        }, cashable: false);
    // NetworkManager.httpGet(Globals.baseUrl + "user/transactions?page=$page",
    //      context, (r) {
    //   setState(() {
    //     isloading = false;
    //   });
    //   if (r['state'] == true) {
    //     setState(() {
    //       data[r["page"]] = r['data'];
    //       balance = r['balance'];
    //       unit = r['unit'];
    //       page++;
    //     });
    //   }
    // }, cashable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            textDirection: LanguageManager.getTextDirection(),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleBar(() {Navigator.pop(context);}, 301),
              Expanded(child: getContent()),
              getOptions()
            ]));
  }

  Widget getOptions() {
    if (data.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                print('print_getOptions: balanceOnline: $balanceOnline}, type: ${balanceOnline.runtimeType}');
                if (double.parse(balanceOnline.toString()) <= 0) {
                  Alert.show(context, LanguageManager.getText(241));
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (_) => Withdrawal(
                            double.parse(earnings.toString()),  Globals.getUnit(isUsd: 'online_services'))));
              },
              child: Container(
                height: 45,
                alignment: Alignment.center,
                child: Text(
                  LanguageManager.getText(191),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
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
          ),
          Container(
            width: 10,
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                print('here_commission: $commission');
                if (double.parse(commission.toString()) <= 0) {
                  Alert.show(context, LanguageManager.getText(239));
                  return;
                }
                Alert.staticContent = getSendMoneyWidget();
                Alert.show(context, Alert.staticContent, type: AlertType.WIDGET, isDismissible: false);
                // String url = [
                //   Globals.baseUrl,
                //   "payment/debit/?user=",
                //   UserManager.currentUser(Globals.authoKey)
                // ].join();
                //
                // var results = await Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (_) =>
                //             WebBrowser(url, LanguageManager.getText(228))));
                // if (results != null) {
                //   if (results["message"] != null) {
                //     Alert.show(
                //         context, Converter.getRealText(results['message']));
                //   }
                //   if (results['state'] == true) {
                //     page = 0;
                //     data = {};
                //     load();
                //   }
                // } else if (results == null) {
                //   Alert.show(context, LanguageManager.getText(240));
                //   return;
                // }
              },
              child: Container(
                height: 45,
                alignment: Alignment.center,
                child: Text(
                  LanguageManager.getText(192),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
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
          )
        ],
      ),
    );
  }

  Widget getContent() {

    if (isloading == true && data.isEmpty)
      return Center(
        child: CustomLoading(),
      );

    List<Widget> items = [];

    items.add(Container(height: 25));

    items.add(getColumn());

    if (balance == 0 && commission == 0 && balanceOnline == 0 && earnings == 0 && (data[0]['transaction'] as List).isEmpty) {
      return Column(
        children: items..add(Expanded(child: EmptyPage("wallet", 188))),
      );
    }

    items.add(Container(
      margin: EdgeInsets.all(25),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(20),
                spreadRadius: 6,
                blurRadius: 6)
          ]),
      child: Column(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Container(
            alignment: Alignment.topCenter,
            // height: 70,
            // width: 110,
            child: Icon(
              FlutterIcons.wallet_faw5s,
              size: 50,
              color: Converter.hexToColor("#344F64"),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 10, left: 10,top: 15, bottom: 5),
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Text('الصيانة والتقنية',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ],
            ),
          ),
          Container(height: 1, color: Colors.blue),
          Container(
            height: 25,
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LanguageManager.getText(304) , // 186 // إجمالي المبيعات
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      color: Converter.hexToColor("#344F64"),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),//15
                ),
                Container(
                  width: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: LanguageManager.getTextDirection(),
                    children: [
                        Text(
                        Converter.format(balance),
                        textDirection: LanguageManager.getTextDirection(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Converter.hexToColor("#344F64"),
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                      Container(
                        width: 10,
                      ),
                      Text(
                        Globals.getUnit(),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            color: Converter.hexToColor("#344F64"),
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      )
                    ]),
              ],
            ),
          ),

          Row(
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LanguageManager.getText(305) , // 186 //عمولة التطبيق
                textDirection: LanguageManager.getTextDirection(),
                style: TextStyle(
                    color: Converter.hexToColor("#344F64"),
                    fontWeight: FontWeight.bold,
                    fontSize: 15),//15
              ),
              Container(
                width: 10,
              ),
              Container(
                height: 25,
                child: Row(
                    textDirection: LanguageManager.getTextDirection(),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Converter.format(commission),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Container(
                        width: 10,
                      ),
                      Text(
                        Globals.getUnit(),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ]),
              ),
            ],
          ),

          Container(
            margin: EdgeInsets.only(right: 10, left: 10,top: 15, bottom: 5),
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Text('خدمات الأعمال',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ],
            ),
          ),
          Container(height: 1, color: Colors.blue),
          Container(
            height: 25,
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LanguageManager.getText(304) , // 186 // إجمالي المبيعات
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      color: Converter.hexToColor("#344F64"),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),//15
                ),
                Container(
                  width: 10,
                ),
                Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Text(
                        Converter.format(balanceOnline),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            color: Converter.hexToColor("#344F64"),
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                      Container(
                        width: 10,
                      ),
                      Text(
                        Globals.getUnit(isUsd: "online_services"),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            color: Converter.hexToColor("#344F64"),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      )
                    ]),
              ],
            ),
          ),

          // Container(
          //   height: 25,
          //   child: Row(
          //     textDirection: LanguageManager.getTextDirection(),
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         LanguageManager.getText(305) , // 186 //عمولة التطبيق
          //         textDirection: LanguageManager.getTextDirection(),
          //         style: TextStyle(
          //             color: Converter.hexToColor("#344F64"),
          //             fontWeight: FontWeight.bold,
          //             fontSize: 15),//15
          //       ),
          //       Container(
          //         width: 10,
          //       ),
          //       Row(
          //           textDirection: LanguageManager.getTextDirection(),
          //           children: [
          //             Text(
          //               Converter.format(commissionOnline),
          //               textDirection: LanguageManager.getTextDirection(),
          //               style: TextStyle(
          //                   color: Converter.hexToColor("#344F64"),
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 16),
          //             ),
          //             Container(
          //               width: 10,
          //             ),
          //             Text(
          //               Globals.getUnit(isUsd: "online_services"),
          //               textDirection: LanguageManager.getTextDirection(),
          //               style: TextStyle(
          //                   color: Converter.hexToColor("#344F64"),
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 16),
          //             ),
          //           ]),
          //     ],
          //   ),
          // ),

          Container(
            height: 25,
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LanguageManager.getText(361) , // 186 //عمولة التطبيق
                  textDirection: LanguageManager.getTextDirection(),
                  style: TextStyle(
                      color: Converter.hexToColor("#344F64"),
                      fontWeight: FontWeight.bold,
                      fontSize: 15),//15
                ),
                Container(
                  width: 10,
                ),
                Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      Text(
                        Converter.format(earnings),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Container(
                        width: 10,
                      ),
                      Text(
                        Globals.getUnit(isUsd: "online_services"),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ]),
              ],
            ),
          ),
        ],
      ),
    ));
    if((data[0]['transaction'] as List).isNotEmpty)
    items.add(Row(
      textDirection: LanguageManager.getTextDirection(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: EdgeInsets.only(left: 15, right: 15, bottom: 3),
          child: Text(
            LanguageManager.getText(187),
            textDirection: LanguageManager.getTextDirection(),
            style: TextStyle(
                color: Converter.hexToColor("#344F64"),
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AllTransactions()));
          },
          child: Container(
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 3),
            child: Text(
              LanguageManager.getText(121),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        ),
      ],
    ));

    // for (var page in data.keys) {
      for (var item in data[0]['transaction']) { // (var item in data[page])
        print('here_item: $item');
        items.add(createTransactionItem(item));
      }
    // }

    return Recycler(
      children: items,
    );
    // return items[0];
  }

  Widget createTransactionItem(item) {
    print('here_createTransactionItem: $item');
    Color color = item['type'] == "WITHDRAWAL" ? Colors.blue : (item['order_id'].toString() == '0' ? Colors.red  : Colors.green);
    return Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(30), width: 1))),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Container(
              margin: LanguageManager.getDirection() ? EdgeInsets.only(left: 15, right: 5) : EdgeInsets.only(left: 5, right: 15),
              child: SvgPicture.asset(
                "assets/icons/${item['type'].toString().toLowerCase()}.svg",
                width: 20,
                height: 20,
                color: color,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Text(
                    item['order_id'].toString() == '0'
                        ? LanguageManager.getText( item['type'] == "WITHDRAWAL" ? 302 : item['is_usd'].toString() == '1' ? 189 : 334) + (item['is_usd'].toString() == '1'? " #" + item['id'].toString() : '')
                        : item['type'] == "WITHDRAWAL"
                            ? LanguageManager.getText(302) + " #" + item['order_id'].toString() // تسديد عمولة الطلب رقم
                            : LanguageManager.getText(303) + " #" + item['order_id'].toString() + " " + item['title'], // تنفيذ طلب
                    textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    Converter.getRealText(item['created_at']),
                    // textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: LanguageManager.getDirection() ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Text(
                      Converter.format(item['amount'].toString()),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    Container(width: 5),
                    Text(
                    Globals.getUnit(isUsd: item['is_usd'].toString() == '1' ? 'online_services' : item['service_target']),
                    textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.normal, fontSize: 16),
                  ),
                  ],
                ),
                Row(
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Text(
                      item['order_id'].toString() == '0'? '' : item['commission'].toString(),
                      textDirection: LanguageManager.getTextDirection(),
                      style: TextStyle(
                          color: Converter.hexToColor("#344F64"), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Container(width: 5),
                    Text(
                      item['order_id'].toString() == '0'? '' : Globals.getUnit(isUsd: item['service_target']),
                    textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(
                        color: Converter.hexToColor("#344F64"), fontWeight: FontWeight.normal, fontSize: 12),
                  ),
                  ],
                ),
              ],
            ),
            Container(width: 5),
          ],
        ));
  }

  Widget getColumn() {
    if (isloading == true && data.isEmpty)
      return Center();

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(width: 10,),
          Expanded(
            child: Container(
                decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.red,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(15),
                    spreadRadius: 2,
                    blurRadius: 2)
              ]),
                child:Text('${Converter.getRealText(184)}\n${data[0]['canceled']}', textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)),
          ),
          Container(width: 10,),
          Expanded(
            child: Container(
                decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(15),
                    spreadRadius: 2,
                    blurRadius: 2)
              ]),
                child:Text('${Converter.getRealText(93)}\n${data[0]['pending']}', textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)),
          ),
          Container(width: 10,),
          Expanded(
            child: Container(
                decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Converter.hexToColor("#344F64"),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(15),
                    spreadRadius: 2,
                    blurRadius: 2)
              ]),
                child:Text('${Converter.getRealText(94)}\n${data[0]['completed']}', textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)),
          ),
          Container(width: 10,),
      ]),
    );
  }

  getSendMoneyWidget () {

    TextEditingController _controllerAmount      = new TextEditingController();

    if(body.isNotEmpty && body.containsKey('amount') && body["amount"].toString().isNotEmpty) {
      _controllerAmount.text = body["amount"];
      _controllerAmount.selection = TextSelection.fromPosition(TextPosition(offset: _controllerAmount.text.length));
    }

    return Stack(
      children: [
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: LanguageManager.getTextDirection(),
                  children: [
                    Container(),
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                      child: Text(
                        LanguageManager.getText(371), // حدد المبلغ
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.normal,
                            color: Converter.hexToColor("#344F64")),
                      ),
                    ),
                    Container(
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(FlutterIcons.close_ant)),
                    ),
                  ],
                ),
              ),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                    padding: EdgeInsets.only(left: 7, right: 7),
                    decoration: BoxDecoration(
                        color: Converter.hexToColor(
                            errors['amount'] != null
                                ? "#E9B3B3"
                                : "#F2F2F2"),
                        borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _controllerAmount,
                      onChanged: (t) {
                        body["amount"] = t;
                        if(t.isNotEmpty && errors["amount"] != null){
                          errors["amount"] = null;
                          Alert.staticContent = getSendMoneyWidget();
                          Alert.setStateCall = () {};
                          Alert.callSetState();
                        }
                      },
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      textDirection: LanguageManager.getTextDirection(),
                      decoration: InputDecoration(
                          hintText: "1000",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          hintTextDirection:
                          LanguageManager.getTextDirection(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 0, horizontal: 0)),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(Globals.getUnit(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Converter.hexToColor("#344f64")))
                ],
              ),
              Container(height: 10),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      errors = {};
                      if (body["amount"] == null || (body["amount"] != null && body["amount"].toString().isEmpty)) {
                        errors['amount'] = "_";
                        Alert.staticContent = getSendMoneyWidget();
                        Alert.setStateCall = () {};
                        Alert.callSetState();
                      } else {
                        Navigator.of(context).pop();
                        openWebViewCharge();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      height: 45,
                      width: 200,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(192), // سدد
                        style: TextStyle(
                          color: Colors.white,
                        ),
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
                  Container(
                    width: 10,
                  ),
                  Text(Globals.getUnit(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.transparent))
                ],
              ),
              Container(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void openWebViewCharge() async{
    String url = [
      Globals.urlServerGlobal,
      "/user/payment/myfatoorah",
      "?user_id=", UserManager.currentUser('id'),
      "&price=${body['amount']}",
      "&currency=${UserManager.currentUser('unit_en')}",
    ].join();

    body = {};

    var results = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                WebBrowser(url, LanguageManager.getText(343) + ' ' +LanguageManager.getText(135))));//
    if (results.toString() == 'success') {
      page = 0;
      data = {};
      load();
    } else if (results == null) {
      Alert.show(context, LanguageManager.getText(240));
      return;
    }
  }
}
