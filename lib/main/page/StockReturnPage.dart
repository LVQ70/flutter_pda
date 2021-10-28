//原辅料退库
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pda_mes/base/scannerBase.dart';
import 'package:pda_mes/base/colors.dart';
import 'package:pda_mes/base/httpUrl.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:pda_mes/base/vibrate.dart';
import 'package:pda_mes/base/baseWidget.dart';
import 'package:pda_mes/dialog/DialogBase.dart';

class StockReturn extends StatelessWidget {
  final arguments;
  StockReturn({this.arguments});

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
  String httpURL, token;
  String eqpString;
  bool boolOff = true;
  String materielCodeart,
      materielErpLot,
      materielName,
      materielQuantrestante,
      materielUnittare,
      materielContainer,
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
        setState(() {
          eqpString = barcodeScan['scanData'];
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
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: '余料罐条码',
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
                            eqpString = text;
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
                            WidgetBase.rowTextTwo("ERP批次", "$materielErpLot"),
                            WidgetBase.rowTextTwo("物料编码", "$materielCodeart"),
                            WidgetBase.rowTextTwo("当前重量",
                                "$materielQuantrestante$materielUnittare"),
                            WidgetBase.rowTextTwo("物料名称", "$materielName"),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: buttonStyle(),
                              onPressed: () {
                                showConfirmDialog(context, '确认执行退库操作吗？', () {
                                  getStockReutn();
                                });
                              },
                              child: Text(
                                "退料",
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
    var url = httpURL + "custom/Pda/stockReturn";
    var response = await http.post(url, body: json.encode({'CODE': eqpString}));
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
          materielCodeart = json.decode(response.body)['data'][0]['CODEART'];
          materielErpLot = json.decode(response.body)['data'][0]['CODELOT'];
          materielQuantrestante =
              json.decode(response.body)['data'][0]['QUANTRESTANTE'];
          materielUnittare =
              json.decode(response.body)['data'][0]['UNITESTOCK'];
          materielName =
              json.decode(response.body)['data'][0]['DESIGNPRINCIPALE'];
          materielContainer =
              json.decode(response.body)['data'][0]['CONTAINER_ID'];
          labelXfLot = json.decode(response.body)['data'][0]['XFIELD_04'];
          labelXfCode = json.decode(response.body)['data'][0]['XFIELD_05'];
          labelXfMate = json.decode(response.body)['data'][0]['XFIELD_06'];
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

//退料接口
  Future<dynamic> getStockReutn() async {
    var url = httpURL + "custom/Pda/saveStockReturn";
    var dataJson = {
      "TOKEN": token,
      "BARCODE": materielContainer,
      "CONTAINERID": materielContainer,
      "ITEMCODE": materielCodeart,
      "QTY": materielQuantrestante,
      "UNIT": materielUnittare,
      "CODE": eqpString
    };
    var response = await http.post(url, body: json.encode(dataJson));
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
        getPrintLabel();
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
      "Type": "1",
      "ProductName": materielName.trim(),
      "ProductCode": materielCodeart.trim(),
      "Weight": materielQuantrestante.trim(),
      "Unit": materielUnittare.trim(),
      "LabelXfLot": labelXfLot.trim(),
      "LabelXfCode": labelXfCode.trim(),
      "LabelXfMate": labelXfMate.trim(),
      "PrintCode": materielContainer.trim()
    };
    var response = await http.post(url,
        body: json.encode(dataJson),
        headers: {"content-type": "application/json"});
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      if (code == 0) {
        Fluttertoast.showToast(
          msg: '正在打印...',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        setState(() {
          runMsg = json.decode(response.body)['msg'];
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
