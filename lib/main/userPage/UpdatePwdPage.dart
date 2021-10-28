import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class UpdatePwdPage extends StatefulWidget {
  UpdatePwdPage({Key key}) : super(key: key);

  @override
  _UpdatePwdPageState createState() => _UpdatePwdPageState();
}

class _UpdatePwdPageState extends State<UpdatePwdPage> {
  String phone;
  String password;
  String upassword;
  String code;
  int type = 1; //注册用户的类型 1-普通用户 2-系统用户
  int yzmType = 2; //1-注册 2-重置密码 3-验证码登录
  int i = 60; //验证码计时器
  bool obscure = true;
  String yzmText = '获取';
  String project = 'blockchain';
  int index = 1;
  List listRegister = [
    "assets/login/btn-change.png",
    "assets/login/btn-change2.png"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('修改密码', style: TextStyle(fontSize: 18)),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    icon: Icon(
                      Icons.person,
                      size: 25,
                    ),
                    hintText: '手机号'),
                onChanged: (val) {
                  setState(() {
                    this.phone = val;
                  });
                },
                //键盘操作事件
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus(); //下一个光标焦点
                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Stack(
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        icon: Icon(Icons.email), hintText: '验证码'),
                    onChanged: (val) {
                      this.code = val;
                    },
                  ),
                  Positioned(
                    right: 5,
                    top: 10,
                    child: InkWell(
                      child: Text(
                        this.yzmText,
                        style:
                            TextStyle(color: Color(0xffcdcccc), fontSize: 16),
                      ),
                      onTap: () {
                        if (this.phone.length != 11) {
                          Fluttertoast.showToast(
                              msg: '请输入正确的手机号',
                              textColor: Colors.white,
                              backgroundColor: Colors.black54);
                        } else {
                          if (i == 60) {
                            Timer.periodic(Duration(seconds: 1), (t) {
                              setState(() {
                                if (i <= 0) {
                                  this.yzmText = '重新获取';
                                  i = 60;
                                  t.cancel();
                                } else {
                                  i--;
                                  this.yzmText = i.toString() + 's';
                                }
                              });
                            });
                            getDataYzm();
                          } else {
                            Fluttertoast.showToast(
                                msg: '请在${i}s后重试',
                                backgroundColor: Colors.black54,
                                textColor: Colors.white);
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                keyboardType: TextInputType.visiblePassword, //输入类型
                textInputAction: TextInputAction.next,
                obscureText: this.obscure, //是否隐藏
                maxLength: 12,
                decoration: InputDecoration(
                    icon: Image.asset(
                      'assets/login/icon-password.png',
                      width: 25,
                      height: 25,
                    ),
                    hintText: '新密码'),
                //键盘操作事件
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
                onChanged: (val) {
                  this.password = val;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                keyboardType: TextInputType.visiblePassword, //输入类型
                textInputAction: TextInputAction.done,
                obscureText: this.obscure, //是否隐藏
                maxLength: 12,
                decoration: InputDecoration(
                    icon: Image.asset(
                      'assets/login/icon-password.png',
                      width: 25,
                      height: 25,
                    ),
                    hintText: '再次输入密码'),
                onChanged: (val) {
                  setState(() {
                    this.upassword = val;
                    if (this.phone.length > 7 &&
                        this.password.length > 5 &&
                        this.password == this.upassword &&
                        this.code.length > 4) {
                      this.index = 0;
                    } else {
                      this.index = 1;
                    }
                  });
                },
              ),
            ),
            SizedBox(height: 60),
            Container(
              child: InkWell(
                child: Image.asset(
                  "${this.listRegister[index]}",
                  height: 60,
                ),
                onTap: () {
                  if (index == 1) {
                    Fluttertoast.showToast(
                        msg: '请先完成修改内容填写',
                        backgroundColor: Colors.black54,
                        textColor: Colors.white);
                  } else {
                    getData();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

//验证码
  getDataYzm() async {
    var url =
        "http://courage.cqscrb.top/system/sendCode?phone=${this.phone}&type=${this.yzmType}&project=${this.project}";
    var response = await http.post(url);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: '发送成功',
          backgroundColor: Colors.black54,
          textColor: Colors.white);
    } else {
      print('发送验证码请求失败');
    }
  }

//修改密码
  getData() async {
    var url =
        "http://courage.cqscrb.top/system/resetPassword?phone=${this.phone}&newPassword=${this.password}&confirmPassword=${this.upassword}&code=${this.code}&project=${this.project}";
    var response = await http.post(url);
    bool success = json.decode(response.body)['success'];
    if (response.statusCode == 200) {
      if (success) {
        Fluttertoast.showToast(
            msg: '修改成功!',
            backgroundColor: Colors.black54,
            textColor: Colors.white);
        Navigator.pushNamed(context, '/login');
      } else {
        Fluttertoast.showToast(
            msg: json.decode(response.body)['msg'],
            backgroundColor: Colors.black54,
            textColor: Colors.white);
      }
    } else {
      print('修改密码请求失败');
    }
  }
}
