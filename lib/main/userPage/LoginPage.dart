import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:pda_mes/base/vibrate.dart';
import 'package:pda_mes/dialog/NetLoadingDialog.dart';
import 'package:pda_mes/base/colors.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String loginName;
  String password;
  bool obscure = true;
  DateTime lastPopTime;
  int index = 1;
  String httpURL;
  bool runBool = true;

  @override
  void initState() {
    super.initState();
    SharedPreferencesUtil.getData<String>("HTTP_URL").then((value) {
      setState(() {
        httpURL = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: Container(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 60, 0, 140),
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/login/top-bg.png'),
                        fit: BoxFit.cover)),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        size: 25,
                      ),
                      hintText: '?????????'),
                  onChanged: (val) {
                    setState(() {
                      this.loginName = val;
                    });
                  },
                  //??????????????????
                  onEditingComplete: () {
                    FocusScope.of(context).nextFocus(); //?????????????????????
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword, //????????????
                  textInputAction: TextInputAction.done,
                  obscureText: this.obscure, //????????????
                  maxLength: 12,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: this.obscure
                            ? Icon(Icons.remove_red_eye)
                            : Icon(Icons.panorama_fish_eye),
                        onPressed: () {
                          setState(() {
                            if (this.obscure) {
                              this.obscure = false;
                            } else {
                              this.obscure = true;
                            }
                          });
                        },
                      ),
                      icon: Icon(Icons.lock),
                      hintText: '??????'),
                  onChanged: (val) {
                    setState(() {
                      this.password = val;
                      if (this.loginName.length > 0 &&
                          this.password.length > 0) {
                        this.index = 0;
                      } else {
                        this.index = 1;
                      }
                    });
                  },
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    child: MaterialButton(
                      height: 50,
                      color: index == 1 ? greyColor : themeColor,
                      textColor: Colors.white,
                      child: Text(
                        '??????',
                        style: TextStyle(fontSize: 25),
                      ),
                      onPressed: () {
                        if (this.loginName.length < 1) {
                          Fluttertoast.showToast(
                              msg: '??????????????????',
                              backgroundColor: Colors.black54,
                              textColor: Colors.white);
                        } else if (this.password.length < 1) {
                          Fluttertoast.showToast(
                              msg: '??????????????????',
                              backgroundColor: Colors.black54,
                              textColor: Colors.white);
                        } else if (lastPopTime == null ||
                            // ???????????????
                            DateTime.now().difference(lastPopTime) >
                                Duration(seconds: 2)) {
                          lastPopTime = DateTime.now();
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                return new NetLoadingDialog(
                                  requestCallBack: getData(),
                                  outsideDismiss: false,
                                );
                              }).then((val) {
                            if (runBool) {
                              Navigator.pushNamed(context, '/index');
                            }
                          });
                        } else {
                          lastPopTime = DateTime.now();
                          Fluttertoast.showToast(
                              msg: '?????????????????????',
                              backgroundColor: Colors.black54,
                              textColor: Colors.white);
                        }
                      },
                    ),
                    flex: 1,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: MaterialButton(
                      height: 50,
                      color: themeColor,
                      textColor: Colors.white,
                      child: Text(
                        "??????",
                        style: TextStyle(fontSize: 25),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/setting');
                      },
                    ),
                    flex: 1,
                  ),
                  SizedBox(width: 10),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> getData() async {
    //??????10s???????????????????????????????????????
    const timeout = const Duration(seconds: 10);
    var _timer = Timer(timeout, () {
      setState(() {
        runBool = false;
      });
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: '???????????????',
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
      //????????????
      vibrate();
    });
    var url = httpURL + "custom/Pda/login";
    var response = await http.post(url,
        body: json.encode({"UserName": loginName, "pwd": password}));
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      if (code == 0) {
        Fluttertoast.showToast(
            msg: '????????????!',
            backgroundColor: Colors.black54,
            textColor: Colors.white);
        //????????????
        SharedPreferencesUtil.saveData<String>(
            'username', json.decode(response.body)['data']['UserName']);
        SharedPreferencesUtil.saveData<String>(
            'token', json.decode(response.body)['data']['Token']);
        SharedPreferencesUtil.saveData<String>('loginName', loginName);
        SharedPreferencesUtil.saveData<String>('menuList',
            json.encode(json.decode(response.body)['data']['Menu']));
        _timer.cancel();
        setState(() {
          runBool = true;
        });
        return response;
      } else {
        Fluttertoast.showToast(
            msg: json.decode(response.body)['msg'],
            backgroundColor: Colors.black54,
            textColor: Colors.white);
        setState(() {
          runBool = false;
        });
        //????????????
        vibrate();
        _timer.cancel();
      }
    } else {
      Fluttertoast.showToast(
          msg: '??????????????????!',
          backgroundColor: Colors.black54,
          textColor: Colors.white);
      setState(() {
        runBool = false;
      });
      //????????????
      vibrate();
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
