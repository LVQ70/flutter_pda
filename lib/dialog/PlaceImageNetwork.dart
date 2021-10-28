import 'package:flutter/material.dart';
import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';

// ignore: non_constant_identifier_names
Widget MyPlaceImage(image, {double width, double height, BoxFit fit}) {
  return FadeInImage.assetNetwork(
    placeholder: "assets/login/top-bg.png",
    image: image,
    height: height,
    width: width,
    fit: fit,
  );
}

// ignore: non_constant_identifier_names
SetTimeOut(context, {int time, String msg}) {
  Timer.periodic(Duration(milliseconds: time), (t) {
    Fluttertoast.showToast(
        msg: msg, backgroundColor: Colors.black54, textColor: Colors.white);
    Navigator.pop(context); //关闭对话框
    Navigator.pop(context);
    t.cancel(); //停止计时器
  });
}
