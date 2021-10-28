import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:pda_mes/base/vibrate.dart';
import 'package:pda_mes/dialog/NetLoadingDialog.dart';
import 'package:pda_mes/base/colors.dart';

class Setting extends StatefulWidget {
  Setting({Key key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  TextEditingController _ipAddressController;
  TextEditingController _ipPordController;
  String ipAddress;
  String port;
  DateTime lastPopTime;
  int index = 1;
  bool runBool = true;
  @override
  void initState() {
    super.initState();
    SharedPreferencesUtil.getData<String>("HTTP_URL").then((value) {
      if (value != null) {
        setState(() {
          var address = value.substring(7, value.length - 1).split(':');
          ipAddress = address[0];
          port = address[1];
          _ipAddressController = new TextEditingController(text: ipAddress);
          _ipPordController = new TextEditingController(text: port);
          //改变按钮状态值
          index = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: new AppBar(
          title: new Text('设置'),
        ),
        body: GestureDetector(
          onTap: () {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          },
          child: Container(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: _ipAddressController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        icon: Icon(
                          Icons.computer,
                          size: 25,
                        ),
                        hintText: '服务器地址'),
                    onChanged: (val) {
                      setState(() {
                        this.ipAddress = val;
                      });
                    },
                    //键盘操作事件
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus(); //下一个光标焦点
                    },
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    keyboardType: TextInputType.number, //输入类型
                    textInputAction: TextInputAction.done,
                    controller: _ipPordController,
                    maxLength: 12,
                    decoration: InputDecoration(
                        icon: Icon(Icons.offline_bolt), hintText: '端口'),
                    onChanged: (val) {
                      setState(() {
                        this.port = val;
                        if (this.ipAddress.length > 0 && this.port.length > 0) {
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
                          '保存',
                          style: TextStyle(fontSize: 25),
                        ),
                        onPressed: () {
                          if (this.ipAddress.length < 1) {
                            Fluttertoast.showToast(
                                msg: '服务器地址不得为空！',
                                backgroundColor: Colors.black54,
                                textColor: Colors.white);
                          } else if (this.port.length < 1) {
                            Fluttertoast.showToast(
                                msg: '端口不得为空！',
                                backgroundColor: Colors.black54,
                                textColor: Colors.white);
                          } else {
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
                                Navigator.pushNamed(context, '/login');
                              }
                            });
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
                          "取消",
                          style: TextStyle(fontSize: 25),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
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
      ),
    );
  }

  Future<dynamic> getData() async {
    //设置10s回调，关闭弹出层，弹出异常
    const timeout = const Duration(seconds: 10);
    var _timer = Timer(timeout, () {
      setState(() {
        runBool = false;
      });
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: '无效连接！',
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
      //触发震动
      vibrate();
    });
    //验证ip是否为可连接
    var url = "http://$ipAddress:$port/custom/pda";
    var response = await http.post(url);
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      _timer.cancel();
      if (code == 0) {
        Fluttertoast.showToast(
          msg: '请求成功!',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        setState(() {
          runBool = true;
        });
        SharedPreferencesUtil.saveData<String>(
            'HTTP_URL', "http://$ipAddress:$port/");
        return response;
      } else {
        setState(() {
          runBool = false;
        });
        Fluttertoast.showToast(
          msg: json.decode(response.body)['msg'],
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        //触发震动
        vibrate();
      }
    } else {
      setState(() {
        runBool = false;
      });
      Fluttertoast.showToast(
        msg: '未连接网络！',
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
      //触发震动
      vibrate();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
