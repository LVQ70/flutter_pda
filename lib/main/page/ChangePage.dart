//更改设备状态
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pda_mes/base/colors.dart';
import 'package:pda_mes/base/scannerBase.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:pda_mes/base/baseWidget.dart';
import 'package:pda_mes/base/vibrate.dart';
import 'package:pda_mes/dialog/DialogBase.dart';

class Change extends StatelessWidget {
  final arguments;
  Change({this.arguments});

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
  String runMsg = "", productsCleanUp = "YES";
  int runCode = 0;
  String httpURL;
  //是否显示清场状态
  bool boolOffClean = true;
  String productsClean, eqpCode, eqpName, eqpStatus, eqpId, cleanDate, endDate;
  @override
  void initState() {
    super.initState();
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
        //调用接口
        getEQP(barcodeScan['scanData']);
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
                          labelText: '设备条码',
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
                          //取消光标
                          focusNode.unfocus();
                          //调用接口
                          getEQP(text);
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Offstage(
                  child: Container(
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
                        WidgetBase.rowTextTwo("设备编码", "$eqpCode"),
                        WidgetBase.rowTextTwo("设备名称", "$eqpName"),
                        WidgetBase.rowTextTwo("清洁日期", "$cleanDate"),
                        WidgetBase.rowTextTwo("有效期至", "$endDate"),
                        WidgetBase.rowTextTwo(
                            "设备状态", eqpStatus == "I" ? "正常使用" : "设备异常"),
                        WidgetBase.rowTextTwo(
                            "当前状态", productsClean == "YES" ? "已清洁" : "未清洁"),
                        WidgetBase.rowTextTwo(
                            "更改状态", productsCleanUp == "YES" ? "已清洁" : "未清洁"),
                      ],
                    ),
                  ),
                  offstage: boolOffClean,
                ),
                SizedBox(height: 10),
                Offstage(
                  child: Container(
                    width: getWidth(context),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '更改状态为:',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          flex: 1,
                        ),
                        Expanded(
                          child: DropdownButton(
                            value: productsCleanUp,
                            icon: Icon(Icons.arrow_right),
                            iconSize: 40,
                            iconEnabledColor: Colors.green.withOpacity(0.7),
                            hint: Text('请选择需要修改的设备状态'),
                            isExpanded: true,
                            underline: Container(
                                height: 1,
                                color: Colors.green.withOpacity(0.7)),
                            items: [
                              DropdownMenuItem(
                                  child: Text('已清洁'), value: "YES"),
                              DropdownMenuItem(child: Text('未清洁'), value: "NO"),
                            ],
                            onChanged: (value) => setState(() {
                              setState(() {
                                productsCleanUp = value;
                              });
                            }),
                          ),
                          flex: 2,
                        )
                      ],
                    ),
                  ),
                  offstage: boolOffClean,
                ),
                Offstage(
                  child: Container(
                    width: getWidth(context),
                    child: Container(
                      child: TextButton(
                        style: buttonStyle(),
                        onPressed: () {
                          showConfirmDialog(context,
                              '确认执行将 $eqpName 更改为 ${productsCleanUp == "YES" ? '已清洁' : '未清洁'} 操作吗？',
                              () {
                            if (productsCleanUp == productsClean) {
                              Fluttertoast.showToast(
                                msg:
                                    '$eqpName 状态为 ${productsCleanUp == "YES" ? '已清洁' : '未清洁'}，无需更改！',
                                backgroundColor: Colors.black54,
                                textColor: Colors.white,
                              );
                            } else {
                              setEqpStatus();
                            }
                          });
                        },
                        child: Text(
                          "更改",
                          style: TextStyle(
                            fontSize: 25,
                            letterSpacing: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  offstage: boolOffClean,
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

  Future<dynamic> getEQP(String eqpString) async {
    setState(() {
      boolOffClean = true;
    });
    var url = httpURL + "custom/Pda/getEqpClean";
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
          eqpCode = json.decode(response.body)['data'][0]['CODE'];
          eqpName = json.decode(response.body)['data'][0]['NAME'];
          cleanDate = json.decode(response.body)['data'][0]['CLEANDATE'];
          endDate = json.decode(response.body)['data'][0]['ENDDATE'];
          eqpStatus = json.decode(response.body)['data'][0]['STATUS'];
          productsClean = json.decode(response.body)['data'][0]['STATUSCODE'];
          eqpId = json.decode(response.body)['data'][0]['PK_OBJECTID'];
          boolOffClean = false;
          runMsg = json.decode(response.body)['msg'];
          runCode = 1;
        });
        return response;
      } else {
        setState(() {
          runMsg = json.decode(response.body)['msg'];
          runCode = 2;
        });
        //触发震动
        vibrate();
      }
    } else {
      setState(() {
        runMsg = '网络请求出错';
        runCode = 2;
      });
      //触发震动
      vibrate();
    }
  }

  //提交修改状态接口
  Future<dynamic> setEqpStatus() async {
    var url = httpURL + "custom/Pda/setEqpStatus";
    var response = await http.post(url,
        body: json.encode({
          "EqpCode": eqpCode,
          "EqpId": eqpId,
          "EqpStatusKey": "CLEAN",
          "EqpStatusValue": productsCleanUp
        }));
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      if (code == 0) {
        Fluttertoast.showToast(
          msg: json.decode(response.body)['msg'],
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        //重新请求状态接口
        getEQP(eqpCode);
        return response;
      } else {
        setState(() {
          runMsg = json.decode(response.body)['msg'];
          runCode = 2;
        });
        //触发震动
        vibrate();
      }
    } else {
      setState(() {
        runMsg = '网络请求出错';
        runCode = 2;
      });
      //触发震动
      vibrate();
    }
  }
}
