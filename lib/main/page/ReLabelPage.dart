//重打标签
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pda_mes/base/scannerBase.dart';
import 'package:pda_mes/base/colors.dart';
import 'package:pda_mes/base/httpUrl.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:pda_mes/base/vibrate.dart';
import 'package:pda_mes/base/baseWidget.dart';
import 'package:pda_mes/dialog/DialogBase.dart';

class ReLabel extends StatelessWidget {
  final arguments;
  ReLabel({this.arguments});

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
  int runCode = 0;
  String httpURL, token, barcode;
  bool boolOff = true;
  String labelCodeart,
      labelName,
      labelQty,
      labelUnit,
      labelCodeLot,
      labelXfLot,
      labelXfCode,
      labelXfMate;
  @override
  void initState() {
    super.initState();
    SharedPreferencesUtil.getData<String>("token").then((value) {
      setState(() {
        token = value;
      });
    });
    SharedPreferencesUtil.getData<String>("HTTP_URL").then((value) {
      setState(() {
        httpURL = value;
      });
    });
    /*focusNode.addListener(() {
      if (focusNode.hasFocus) {
        //聚焦时清空内容
        _controller = new TextEditingController(text: null);
      }
    });*/
    //监听扫描
    scanChannel.receiveBroadcastStream().listen((Object event) {
      setState(() {
        Map barcodeScan = jsonDecode(event);
        _controller = new TextEditingController(text: barcodeScan['scanData']);
        setState(() {
          barcode = barcodeScan['scanData'];
        });
        //调用接口
        getEQP();
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
                        keyboardType: TextInputType.number,
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: '物料条码',
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
                        onSubmitted: (text) {
                          setState(() {
                            barcode = text;
                          });
                          //取消光标
                          focusNode.unfocus();
                          //调用接口
                          getEQP();
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
                            WidgetBase.rowTextTwo("物料名称", "$labelName"),
                            WidgetBase.rowTextTwo("物料编码", "$labelCodeart"),
                            WidgetBase.rowTextTwo(
                                "当前重量", "$labelQty$labelUnit"),
                            WidgetBase.rowTextTwo("物料批次", "$labelCodeLot"),
                            //WidgetBase.rowTextTwo("产品批次", "$labelXfLot"),
                            // WidgetBase.rowTextTwo("产品编码", "$labelXfCode"),
                            // WidgetBase.rowTextTwo("领料单号", "$labelXfMate"),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: buttonStyle(),
                              onPressed: () {
                                showConfirmDialog(context, '确认打印此物料条码？', () {
                                  getPrintLabel();
                                });
                              },
                              child: Text(
                                "打印",
                                style: TextStyle(
                                  fontSize: 25,
                                  letterSpacing: 20,
                                ),
                              ),
                            ),
                            flex: 1,
                          ),
                        ],
                      )
                    ],
                  ),
                  offstage: boolOff,
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      '$runMsg',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                      ),
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
    var url = httpURL + "custom/Pda/getReLabel";
    var response = await http.post(url,
        body: json.encode({'BARCODE': barcode, "TYPE": 1}));
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      if (code == 0) {
        Fluttertoast.showToast(
          msg: '请求成功!',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        setState(() {
          boolOff = false;
          runMsg = json.decode(response.body)['msg'];
          runCode = 1;
          labelCodeart = json.decode(response.body)['data'][0]['CODEART'];
          labelName = json.decode(response.body)['data'][0]['DESIGNPRINCIPALE'];
          labelQty = json.decode(response.body)['data'][0]['QUANTRESTANTE'];
          labelUnit = json.decode(response.body)['data'][0]['UNITESTOCK'];
          labelCodeLot = json.decode(response.body)['data'][0]['CODELOT'];
          // labelXfLot = json.decode(response.body)['data'][0]['XFIELD_04'];
          // labelXfCode = json.decode(response.body)['data'][0]['XFIELD_05'];
          // labelXfMate = json.decode(response.body)['data'][0]['XFIELD_06'];
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

//打印接口
  Future<dynamic> getPrintLabel() async {
    var url = URL.PRINT_LABEL;
    var dataJson = {
      "Type": "5",
      "ProductName": labelName.trim(),
      "ProductCode": labelCodeart.trim(),
      "Weight": labelQty.trim(),
      "Unit": labelUnit.trim(),
      "Lot": labelCodeLot.trim(),
      // "LabelXfLot": labelXfLot.trim(),
      // "LabelXfCode": labelXfCode.trim(),
      // "LabelXfMate": labelXfMate.trim(),
      "PrintCode": barcode.trim()
    };
    var response = await http.post(url,
        body: json.encode(dataJson),
        headers: {"content-type": "application/json"});
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      if (code == 0) {
        Fluttertoast.showToast(
          msg: '请求成功!',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        setState(() {
          boolOff = false;
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
