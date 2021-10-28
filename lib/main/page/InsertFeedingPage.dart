import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pda_mes/base/scannerBase.dart';
import 'package:pda_mes/base/colors.dart';
import 'package:pda_mes/base/shared_preferences_util.dart';
import 'package:pda_mes/base/vibrate.dart';
import 'package:pda_mes/base/baseWidget.dart';

class InsertFeeding extends StatelessWidget {
  final arguments;
  InsertFeeding({this.arguments});

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
  String httpURL;
  bool boolOff = true;
  String feedWo, feedName, feedCode, materCode, erpLot, erpName;
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
            padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: '投料口编码',
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
                        WidgetBase.rowTextTwo("批 次", "$erpLot"),
                        WidgetBase.rowTextTwo("品 名", "$erpName"),
                        WidgetBase.rowTextTwo("编 码", "$materCode"),
                      ],
                    ),
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
    var url = httpURL + "custom/Pda/getwofromeqp";
    var response = await http.post(url, body: json.encode({'EQP': eqpString}));
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
          feedWo = json.decode(response.body)['data']['WO'];
          feedName = json.decode(response.body)['data']['NAME'];
          feedCode = json.decode(response.body)['data']['CODE'];
          materCode = json.decode(response.body)['data']['PRODUCTID'];
          erpLot = json.decode(response.body)['data']['ERPLOT'];
          erpName = json.decode(response.body)['data']['ERPNAME'];
        });
        //直接跳转下一个页面
        Navigator.pushNamed(context, '/insertFeedTwo',
                arguments: {"data": json.decode(response.body)['data']})
            .then((value) {
          FocusScope.of(context).requestFocus(focusNode);
          _controller = new TextEditingController(text: null);
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
