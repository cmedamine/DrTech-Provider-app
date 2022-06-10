import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/RateStarsStateless.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Models/UserManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:dr_tech/Pages/AddServices.dart';
import 'package:dr_tech/Pages/ServicePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EngineerServices extends StatefulWidget {
  const EngineerServices();

  @override
  _EngineerServicesState createState() => _EngineerServicesState();
}

class _EngineerServicesState extends State<EngineerServices> {
  bool isLoading = false;
  List data = [];

  @override
  void initState() {
    print('here_infoBody $data');
    Globals.reloadPageEngineerServices = () {
      if (mounted) load();
    };
    load();
    super.initState();
  }

  var isFirstLoad = true;
  void load() {
    if(isLoading) return;
    setState(() {
      isLoading = true;
    });

    NetworkManager.httpGet(Globals.baseUrl + "provider/services/${UserManager.currentUser('id')}",  context, (r) { // user/services
      setState(() {
        isLoading = false;
      });
      if (r['state'] == true) {
        data = r['data'];
        setState(() {});
      }
    }, cashable: true);
  }

  @override
  Widget build(BuildContext context) {
    return getContent();
  }

  Widget getContent() {
    if (isLoading) {
      return Center(
        child: CustomLoading(),
      );
    } else if (data.length == 0) {
      double size = MediaQuery.of(context).size.width * 0.8;
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: SvgPicture.asset(
              "assets/illustration/empty.svg",
              width: size,
              height: size,
            ),
          ),
          Text(
            LanguageManager.getText(251),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 10,
          ),
          Text(
            LanguageManager.getText(252),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 30,
          ),
          getAddButton(),
        ],
      );
    }
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: 50),
            child: Wrap(
              children: data.map((e) => getServiceItem(e)).toList(),
            ),
          ),
        ),
        Container(
            padding: EdgeInsets.all(10),
            alignment: Globals.isRtl()?Alignment.bottomLeft:Alignment.bottomRight,
            child: getAddButton()),
      ],
    );
  }

  Widget getServiceItem(item) {
    double size = MediaQuery.of(context).size.width * 0.5;
    return InkWell(
      onTap: () async{
        var results = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => ServicePage(item["id"])));
        print('here_WillPopScope: $results');
        if (results == true) {
          load();
        }
      },
      child: Container(
        width: size,
        padding: EdgeInsets.all(10),
        child: Container(
          child: Column(
            children: [
              Container(
                width: size * 0.8,
                height: size * 0.7,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(Globals.correctLink(item["thumbnail"]))//image
                    ),
                    color: Colors.black.withAlpha(20),
                    borderRadius: BorderRadius.circular(10)),
              ),
              Text(
                item['title'].toString(), // name
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Converter.hexToColor("#2094CD"),
                    fontWeight: FontWeight.bold),
              ),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  item['status']!=null?getStatusService(item):Container(),
                  Container(width: 10),
                  RateStarsStateless(15, stars: item['stars']?? 5,), // rate
                  Container(width: 10),
                  Text(
                    Converter.format(item['stars']) ?? '5',//rate
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Container(
                height: 10,
              )
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 2,
                    spreadRadius: 2)
              ]),
        ),
      ),
    );
  }

  Widget getAddButton() {
    double size = 60;
    return InkWell(
      onTap: () async {
        var results = await Navigator.push(
            context, MaterialPageRoute(builder: (_) => AddServices()));
        if (results == true) {
          load();
        }
      },
      child: Container(
        width: size,
        height: size,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: size * 0.9,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size),
            color: Converter.hexToColor("#344F64")),
      ),
    );
  }

  Widget getStatusService(item) {
    var map = {
      'PENDING': {"text": 217, "color": "#EDF25A"}, // 216, #000000
      'PROCESSING': {"text": 217, "color": "#DFC100"},
      'ACCEPTED': {"text": 218, "color": "#21CD20"},
      'REJECTED': {"text": 219, "color": "#F00000"}
    };
    return Container(
        alignment: Alignment.center,
        width: 10,
        height: 10,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Converter.hexToColor(map[item['status']]["color"])),
        child: Text(' '),
      );
    // Container(
    //   padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
    //   decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(15),
    //       color: Converter.hexToColor(map[item['status']]["color"]).withAlpha(15)),
    //   child: Text(
    //     LanguageManager.getText(map[item['status']]["text"]),
    //     textDirection: LanguageManager.getTextDirection(),
    //     style: TextStyle(
    //         fontWeight: FontWeight.w600,
    //         fontSize: 16,
    //         color: Converter.hexToColor(map[item['status']]["color"])),
    //   ),
    // );
  }
}
