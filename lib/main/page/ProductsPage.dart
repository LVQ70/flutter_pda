//半成品投料
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pda_mes/base/scannerBase.dart';
import 'package:pda_mes/base/colors.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:pda_mes/base/vibrate.dart';
import 'package:pda_mes/base/baseWidget.dart';

class Products extends StatelessWidget {
  final arguments;
  Products({this.arguments});

  @override
  Widget build(BuildContext context) {
    return WidgetBase.scaffoldBase(
      "${this.arguments['title']}",
      TextFieldDemo(arguments),
    );
  }
}

class TextFieldDemo extends StatefulWidget {
  final arguments;
  TextFieldDemo(this.arguments);
  @override
  _TextFieldDemoState createState() => _TextFieldDemoState(arguments);
}

class _TextFieldDemoState extends State<TextFieldDemo> {
  final arguments;
  _TextFieldDemoState(this.arguments);
  FocusNode focusNode = FocusNode();
  TextEditingController _controller;
  String runMsg = "";
  String titleName = "设备条码";
  int runCode = 0;
  String httpURL, token;
  bool boolOff = true;
  bool boolOffTwo = true;
  String val1;
  String productsItemCode,
      productsItemName,
      productsQty,
      productsUnit,
      productsBarCode;
  @override
  void initState() {
    super.initState();
    SharedPreferencesUtil.getData<String>("HTTP_URL").then((value) {
      setState(() {
        httpURL = value;
      });
    });
    SharedPreferencesUtil.getData<String>("token").then((value) {
      setState(() {
        token = value;
      });
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        //聚焦时清空内容
        _controller = new TextEditingController(text: null);
      }
    });
    //监听扫描
    scanChannel.receiveBroadcastStream().listen((Object event) {
      setState(() {
        Map barcodeScan = jsonDecode(event);
        _controller = new TextEditingController(text: barcodeScan['scanData']);
        if (boolOff) {
          //调用接口
          setState(() {
            val1 = barcodeScan['scanData'];
          });
          getEQP().then((value) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            //判断第二次获取值
            if (boolOff == false) {
              FocusScope.of(context).requestFocus(focusNode);
              _controller = new TextEditingController(text: null);
              setState(() {
                titleName = "目标设备条码";
              });
            }
          });
        } else {
          saveConTransfer(barcodeScan['scanData']);
        }
      });
    });
    //生成配置文件
    createProfile("DataWedgeScanner");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 80,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 120,
            padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        //autofocus: true,
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: titleName,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _controller =
                                    new TextEditingController(text: null);
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 2.0,
                            ),
                          ),
                        ),
                        //focusNode: focusNode,
                        onSubmitted: (text) {
                          //取消光标
                          // focusNode.unfocus();
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Offstage(
                  child: ListView(
                    shrinkWrap: true,
                    physics: new NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        width: getWidth(context),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: themeColor,
                          ),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          physics: new NeverScrollableScrollPhysics(),
                          children: [
                            WidgetBase.rowTextTwo("设备编码", "$val1"),
                            WidgetBase.rowTextTwo("物料编码", "$productsItemCode"),
                            WidgetBase.rowTextTwo("物料名称", "$productsItemName"),
                            WidgetBase.rowTextTwo(
                                "物料重量", "$productsQty$productsUnit"),
                            WidgetBase.rowTextTwo("物料批次", "$productsBarCode"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  offstage: boolOff,
                ),
                SizedBox(height: 10),
                Offstage(
                  child: ListView(
                    shrinkWrap: true,
                    physics: new NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        width: getWidth(context),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: themeColor,
                          ),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          physics: new NeverScrollableScrollPhysics(),
                          children: [
                            WidgetBase.rowTextTwo("结果", "$runMsg"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  offstage: boolOffTwo,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width,
              height: 40,
              decoration: runCode == 0
                  ? BoxDecoration(color: Colors.black12)
                  : runCode == 1
                      ? BoxDecoration(color: Colors.green)
                      : BoxDecoration(color: Colors.red),
              child: Row(
                children: [
                  runCode == 0
                      ? Container(
                          padding: EdgeInsets.only(right: 5),
                          child: Text(''),
                        )
                      : runCode == 1
                          ? Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 30,
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.error,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                  Text(
                    '$runMsg',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  Future<dynamic> getEQP() async {
    var url = httpURL + "custom/Pda/getEquipMent";
    var response = await http.post(url, body: "\"$val1\"");
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      if (code == 0) {
        setState(() {
          //余料罐条码处获取光标
          boolOff = false;
          runMsg = json.decode(response.body)['msg'];
          runCode = 1;
          productsItemCode =
              json.decode(response.body)['data'][0]['ItemCode'].toString();
          productsItemName =
              json.decode(response.body)['data'][0]['ItemName'].toString();
          productsQty = json.decode(response.body)['data'][0]['Qty'].toString();
          productsUnit =
              json.decode(response.body)['data'][0]['Unit'].toString();
          productsBarCode =
              json.decode(response.body)['data'][0]['BarCode'].toString();
        });
        Fluttertoast.showToast(
          msg: '请求成功!',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        return response;
      } else {
        setState(() {
          runMsg = json.decode(response.body)['msg'];
          runCode = 2;
          boolOff = true;
        });
        //触发震动
        vibrate();
      }
    } else {
      setState(() {
        runMsg = '网络请求出错';
        runCode = 2;
        boolOff = true;
      });
      //触发震动
      vibrate();
    }
  }

  Future<dynamic> saveConTransfer(String codeTwo) async {
    var url = httpURL + "custom/Pda/saveConTransfer";
    var apiJson = {
      "CODE": codeTwo,
      "ITEMCODE": productsItemCode,
      "FRISTEQUIPMENTID": val1,
      "CONTAINERIDS": productsBarCode,
      "TOKEN": token
    };
    var response = await http.post(url, body: json.encode(apiJson));
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      if (code == 0) {
        Fluttertoast.showToast(
          msg: '请求成功!',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        setState(() {
          //余料罐条码处获取光标
          boolOffTwo = false;
          runMsg = json.decode(response.body)['msg'];
          runCode = 1;
        });
        return response;
      } else {
        setState(() {
          runMsg = json.decode(response.body)['msg'];
          runCode = 2;
          boolOff = true;
        });
        //触发震动
        vibrate();
      }
    } else {
      setState(() {
        runMsg = '网络请求出错';
        runCode = 2;
        boolOff = true;
      });
      //触发震动
      vibrate();
    }
  }
}
