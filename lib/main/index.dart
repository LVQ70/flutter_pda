import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:http/http.dart' as http;
import 'package:pda_mes/base/vibrate.dart';
import 'package:url_launcher/url_launcher.dart';

class IndexPage extends StatefulWidget {
  IndexPage({Key key}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  List menuList;
  bool runBool = false;
  String upMsg = "", apkUrl = "";
  @override
  void initState() {
    super.initState();
    initShare();
  }

  initShare() {
    SharedPreferencesUtil.getData<String>("HTTP_URL").then((value) {
      if (value == null) {
        Navigator.pushNamed(context, '/setting');
      } else {
        //获取版本号
        version(value).then((value) {
          //不需要更新，直接跳转
          if (value != 1) {
            SharedPreferencesUtil.getData<String>("username").then((value) {
              if (value != null) {
                Navigator.pushNamed(context, '/home');
              } else {
                Navigator.pushNamed(context, '/');
              }
            });
          } else {
            //需要更新，页面等待，显示等待更新
            _launchURL();
          }
        });
      }
    });
  }

  //获取版本号
  Future<int> version(httpURL) async {
    //设置10s回调，关闭弹出层，弹出异常
    const timeout = const Duration(seconds: 5);
    var _timer = Timer(timeout, () {
      setState(() {
        runBool = true;
      });
      Fluttertoast.showToast(
        msg: '请求超时,请检查网络！',
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
      //触发震动
      vibrate();
    });
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    //版本号
    String version = packageInfo.version + packageInfo.buildNumber;
    Fluttertoast.showToast(
      msg: "获取版本中，请稍后...",
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
    //请求服务器版本
    var response = await http.post("${httpURL}custom/Pda/version",
        body: json.encode({'VERSION': version}));
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      if (code == 0) {
        Fluttertoast.showToast(
          msg: json.decode(response.body)['msg'],
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        setState(() {
          apkUrl = '$httpURL${json.decode(response.body)['data']}';
          upMsg = "请前往更新版本！";
          runBool = true;
        });
        _timer.cancel();
        return 1;
      } else {
        //不需要更新
        setState(() {
          runBool = false;
        });
        _timer.cancel();
        return 0;
      }
    } else {
      //网络异常，触发震动
      vibrate();
      _timer.cancel();
      return 1;
    }
  }

  _launchURL() {
    if (canLaunch(apkUrl) != null) {
      launch(apkUrl);
    } else {
      throw 'Could not launch $apkUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 100,
                height: 100,
              ),
              SizedBox(height: 20),
              runBool
                  ? Container(
                      width: getWidth(context),
                      child: Container(
                        child: TextButton(
                          style: buttonStyle(),
                          onPressed: () {
                            initShare();
                          },
                          child: Text(
                            "重试",
                            style: TextStyle(
                              fontSize: 25,
                              letterSpacing: 20,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Text(''),
              Text('$upMsg'),
              SelectableText('$apkUrl'),
            ],
          ),
        ),
      ),
    );
  }
}
