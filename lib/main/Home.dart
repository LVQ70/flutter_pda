import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pda_mes/base/colors.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:pda_mes/main/customDrawer/DrawerPage.dart';

class BottomBar extends StatefulWidget {
  BottomBar({Key key}) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

List datawt;

class _BottomBarState extends State<BottomBar> {
  bool nextKickBackExitApp;
  @override
  void initState() {
    super.initState();
    nextKickBackExitApp = false;
    SharedPreferencesUtil.getData<String>("menuList").then((value) {
      setState(() {
        datawt = json.decode(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: new Text("MES手持设备操作系统"),
        ),
        body: GestureDetector(
          onTap: () {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          },
          child: MenuList(),
        ),
        drawer: DrawerPage(),
      ),
      onWillPop: () {
        if (nextKickBackExitApp) {
          SystemNavigator.pop();
          return Future<bool>.value(true);
        } else {
          Fluttertoast.showToast(
              msg: '再次点击将退出应用!',
              backgroundColor: Colors.black54,
              textColor: Colors.white);
          nextKickBackExitApp = true;
          Future.delayed(
            const Duration(seconds: 2),
            () => nextKickBackExitApp = false,
          );
          return Future<bool>.value(false);
        }
      },
    );
  }
}

class MenuList extends StatefulWidget {
  MenuList({Key key}) : super(key: key);

  @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 1,
          ),
          itemCount: datawt == null ? 0 : datawt.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              child: Container(
                decoration: BoxDecoration(),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        child: Icon(
                          IconData(
                            int.parse(datawt[index]['img_icon']),
                            fontFamily: 'MaterialIcons',
                          ),
                          color: themeColor,
                          size: 60,
                        ),
                      ),
                      Text(
                        datawt[index]['title'],
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff353535),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                int ins = int.parse(datawt[index]['id'].toString());
                switchFunc(context, ins, datawt);
              },
            );
          }),
    );
  }
}

void switchFunc(context, index, datawt) {
  switch (index) {
    case 0:
      Navigator.pushNamed(context, '/products',
          arguments: {"title": datawt[index]['title']});
      break;
    case 1:
      Navigator.pushNamed(context, '/feed',
          arguments: {"title": datawt[index]['title']});
      break;
    case 2:
      Navigator.pushNamed(context, '/stock',
          arguments: {"title": datawt[index]['title']});
      break;
    case 3:
      Navigator.pushNamed(context, '/materiel',
          arguments: {"title": datawt[index]['title']});
      break;
    case 4:
      Navigator.pushNamed(context, '/equipment',
          arguments: {"title": datawt[index]['title']});
      break;
    case 5:
      Navigator.pushNamed(context, '/label',
          arguments: {"title": datawt[index]['title']});
      break;
    case 6:
      Navigator.pushNamed(context, '/change',
          arguments: {"title": datawt[index]['title']});
      break;
    case 7:
      Navigator.pushNamed(context, '/insertFeed',
          arguments: {"title": datawt[index]['title']});
      break;
    case 10:
      Navigator.pushNamed(context, '/preparation',
          arguments: {"title": datawt[index]['title']});
      break;
    default:
      Fluttertoast.showToast(
        msg: 'SUCCESS',
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
      break;
  }
}
