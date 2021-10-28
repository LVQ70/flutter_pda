//备料查询
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pda_mes/base/scannerBase.dart';
import 'package:pda_mes/base/colors.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:pda_mes/base/vibrate.dart';
import 'package:pda_mes/base/baseWidget.dart';
import 'package:pda_mes/dialog/NetLoadingDialog.dart';

class Preparation extends StatelessWidget {
  final arguments;
  Preparation({this.arguments});

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
  //下来选择框集合
  // ignore: deprecated_member_use
  List<DropdownMenuItem> items = new List();
  String runMsg = "";
  int runCode = 0;
  String httpURL, loginName, selectWo;
  String eqpString;
  bool boolOff = true, inputBool = true;
  String erpLots, itemCode, itemName, supperName;
  @override
  void initState() {
    super.initState();
    SharedPreferencesUtil.getData<String>("loginName").then((value) {
      setState(() {
        loginName = value;
      });
    });
    SharedPreferencesUtil.getData<String>("HTTP_URL").then((value) {
      setState(() {
        httpURL = value;
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return new NetLoadingDialog(
              requestCallBack: getEQP(),
              loadingText: "同步领料单中...",
              outsideDismiss: false,
            );
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
        if (!inputBool) {
          _controller =
              new TextEditingController(text: barcodeScan['scanData']);
          setState(() {
            eqpString = barcodeScan['scanData'];
          });
          //调用接口
          getCheck();
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
                DropdownButton(
                  items: items,
                  isExpanded: true,
                  hint: new Text('请选择需核对的工单号'),
                  value: selectWo,
                  onChanged: (T) {
                    setState(() {
                      selectWo = T;
                      inputBool = false;
                    });
                  },
                  elevation: 24,
                  iconSize: 50.0,
                  iconEnabledColor: themeColor,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 20,
                  ),
                ),
                Offstage(
                  offstage: inputBool,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                            WidgetBase.rowTextTwo("ERP批次", "$erpLots"),
                            WidgetBase.rowTextTwo("物料编码", "$itemCode"),
                            WidgetBase.rowTextTwo("供 应 商", "$supperName"),
                            WidgetBase.rowTextTwo("物料名称", "$itemName"),
                          ],
                        ),
                      ),
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

  //获取所有工单信息
  Future<dynamic> getEQP() async {
    var url = httpURL + "custom/pda/getWoMat";
    var response = await http.get(url);
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      if (code == 0) {
        Fluttertoast.showToast(
          msg: '同步成功!',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        var data = json.decode(response.body)['data'];
        for (var i = 0; i < data.length; i++) {
          DropdownMenuItem dropdownMenuItem = new DropdownMenuItem(
            child: new Text(data[i]['NUMOF']),
            value: data[i]['NUMOF'],
          );
          items.add(dropdownMenuItem);
        }
        setState(() {
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
        boolOff = true;
      });
      //触发震动
      vibrate();
    }
  }

//物料复核
  Future<dynamic> getCheck() async {
    var url = httpURL + "/custom/Pda/tlk_check_fuhe";
    var response = await http.post(url,
        body: json
            .encode({'WO': selectWo, "BARCODE": eqpString, "USER": loginName}));
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      setState(() {
        erpLots = json.decode(response.body)['data']['ERPLOTS'];
        itemCode = json.decode(response.body)['data']['ITEMCODE'];
        itemName = json.decode(response.body)['data']['ITEMNAME'];
        supperName = json.decode(response.body)['data']['SUPPERNAME'];
      });
      if (code == 0) {
        Fluttertoast.showToast(
          msg: '请求成功!',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        setState(() {
          runMsg = json.decode(response.body)['msg'];
          runCode = 1;
          boolOff = false;
        });
        return response;
      } else {
        setState(() {
          runMsg = json.decode(response.body)['msg'];
          runCode = 2;
          boolOff = false;
        });
        //触发震动
        vibrate();
      }
    } else {
      Fluttertoast.showToast(
          msg: '网络请求出错!',
          backgroundColor: Colors.black54,
          textColor: Colors.white);
      //触发震动
      vibrate();
      setState(() {
        boolOff = true;
      });
    }
  }
}
