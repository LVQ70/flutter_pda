import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pda_mes/base/scannerBase.dart';
import 'package:pda_mes/base/colors.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:pda_mes/base/vibrate.dart';
import 'package:pda_mes/base/baseWidget.dart';

class FeedingTwo extends StatelessWidget {
  final arguments;
  FeedingTwo({this.arguments});

  @override
  Widget build(BuildContext context) {
    return WidgetBase.scaffoldBase(
      "扫描物料条码",
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
  String httpURL;
  String itemCode, itemName, supperName, erpLots;
  bool boolOff = true;
  String loginName;
  int voted = 0, votedCount = 0;
  @override
  void initState() {
    super.initState();
    SharedPreferencesUtil.getData<String>("HTTP_URL").then((value) {
      setState(() {
        httpURL = value;
      });
    });
    SharedPreferencesUtil.getData<String>("loginName").then((value) {
      setState(() {
        loginName = value;
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
        getCheck(barcodeScan['scanData']);
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
              scrollDirection: Axis.vertical,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: '物料条码',
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
                          getCheck(text);
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: 5),
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
                        WidgetBase.rowTextTwo(
                            "批 次", "${this.arguments['data']['ERPLOT']}"),
                        WidgetBase.rowTextTwo(
                            "品 名", "${this.arguments['data']['ERPNAME']}"),
                        WidgetBase.rowTextTwo(
                            "编 码", "${this.arguments['data']['PRODUCTID']}"),
                      ],
                    ),
                  ),
                  offstage: false,
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
                        WidgetBase.rowTextTwo("批次号", "$erpLots"),
                        WidgetBase.rowTextTwo("物料编码", "$itemCode"),
                        WidgetBase.rowTextTwo("物料名称", "$itemName"),
                        WidgetBase.rowTextTwo("供应商名", "$supperName"),
                      ],
                    ),
                  ),
                  offstage: boolOff,
                ),
                SizedBox(height: 10),
                Text(
                  "投入包数：$voted/$votedCount",
                  style: TextStyle(
                    fontSize: 22,
                  ),
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

  Future<dynamic> getCheck(String eqpString) async {
    var url = httpURL + "/custom/Pda/tlk_check";
    var response = await http.post(url,
        body: json.encode({
          'WO': "${this.arguments['data']['WO']}",
          "BARCODE": eqpString,
          "USER": loginName
        }));
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      setState(() {
        erpLots = json.decode(response.body)['data']['ERPLOTS'];
        itemCode = json.decode(response.body)['data']['ITEMCODE'];
        itemName = json.decode(response.body)['data']['ITEMNAME'];
        supperName = json.decode(response.body)['data']['SUPPERNAME'];
      });
      //执行包数获取接口
      getVoted(itemCode);
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
        //调取声音提示
        playAudioSuccess();
        return response;
      } else {
        setState(() {
          runMsg = json.decode(response.body)['msg'];
          runCode = 2;
          boolOff = false;
        });
        //触发震动
        vibrate();
        playAudioError();
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

  //获取已投物料总包数
  Future<dynamic> getVoted(String itemCode) async {
    var url = httpURL + "/custom/Pda/votedMateriel";
    var response = await http.post(url,
        body: json.encode({
          "NUMOF": "${this.arguments['data']['WO']}",
          "ITEMCODE": itemCode
        }));
    int code = json.decode(response.body)['code'];
    if (response.statusCode == 200) {
      if (code == 0) {
        Fluttertoast.showToast(
          msg: '请求成功!',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
        setState(() {
          voted = int.parse(json.decode(response.body)['data']['num']);
          votedCount = int.parse(json.decode(response.body)['data']['count']);
        });
        return response;
      } else {
        Fluttertoast.showToast(
          msg: '获取投料包数失败',
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
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
    }
  }
}
