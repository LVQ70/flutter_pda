import 'dart:convert';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:pda_mes/base/colors.dart';
import 'package:pda_mes/base/vibrate.dart';
import 'package:pda_mes/main/Home.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';

//侧滑
class DrawerPage extends StatefulWidget {
  DrawerPage({Key key}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

List datawt;

class _DrawerPageState extends State<DrawerPage> {
  String username;
  @override
  void initState() {
    super.initState();
    SharedPreferencesUtil.getData<String>("menuList").then((value) {
      setState(() {
        datawt = json.decode(value);
      });
    });
    SharedPreferencesUtil.getData<String>("username").then((value) {
      setState(() {
        username = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          headList(context),
          menuList(),
          SizedBox(
            height: ScreenUtil.getScaleH(context, 20),
          ),
          goOut(context)
        ],
      ),
    );
  }

  //头部
  Widget headList(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.getScaleH(context, 240),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/login/top-bg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 30),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Container(height: ScreenUtil.getScaleH(context, 185)),
          ),
        ),
        UserAccountsDrawerHeader(
          accountName: Text(
            '用户名：$username',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          accountEmail: Text(
            '描述',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          currentAccountPicture: ClipOval(
            child: Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
          decoration: BoxDecoration(
            image: null,
          ),
          otherAccountsPictures: <Widget>[
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_right,
                size: 45,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        )
      ],
    );
  }

  Widget menuList() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: datawt == null ? 0 : datawt.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Icon(
              IconData(int.parse(datawt[index]['img_icon']),
                  fontFamily: 'MaterialIcons'),
              color: themeColor,
            ),
            title: Text(
              datawt[index]['title'],
              style: TextStyle(
                fontSize: 18,
                color: Color(0xff353535),
              ),
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              int ins = int.parse(datawt[index]['id'].toString());
              switchFunc(context, ins, datawt);
            },
          );
        },
      ),
    );
  }

  //退出
  Widget goOut(context) {
    return Container(
      child: Center(
        child: MaterialButton(
          color: themeColor,
          textColor: Colors.white,
          minWidth: getWidth(context) * 0.7,
          height: 40,
          child: Text(
            '退出',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          onPressed: () {
            SharedPreferencesUtil.saveData<String>('username', null);
            // Navigator.pushNamed(context, '/login');
            //清空所有路由
            Navigator.of(context).pushNamedAndRemoveUntil(
                "/login", ModalRoute.withName("/login"));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
