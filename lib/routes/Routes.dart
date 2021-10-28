import 'package:flutter/material.dart';
import 'package:pda_mes/main/home.dart';
import 'package:pda_mes/main/page/ChangePage.dart';
import 'package:pda_mes/main/page/EquipmentPage.dart';
import 'package:pda_mes/main/page/InsertFeedingPage.dart';
import 'package:pda_mes/main/page/InsertFeedingPageTwo.dart';
import 'package:pda_mes/main/page/MaterielPage.dart';
import 'package:pda_mes/main/page/PreparationPage.dart';
import 'package:pda_mes/main/page/ProductsPage.dart';
import 'package:pda_mes/main/page/ReLabelPage.dart';
import 'package:pda_mes/main/page/StockReturnPage.dart';
import 'package:pda_mes/main/userPage/LoginPage.dart';
import 'package:pda_mes/main/userPage/RegisterPage.dart';
import 'package:pda_mes/main/userPage/UpdatePwdPage.dart';
import 'package:pda_mes/main/page/FeedingPage.dart';
import 'package:pda_mes/main/page/FeedingTwoPage.dart';
import 'package:pda_mes/main/userPage/SettingPage.dart';
import 'package:pda_mes/main/index.dart';

//路由管理
var routes = {
  //index
  '/index': (context) => IndexPage(),
  //初始路由
  '/': (context) => LoginPage(),
  //主页面
  '/home': (context) => BottomBar(),
  //投料复核页面
  '/feed': (context, {arguments}) => Feeding(arguments: arguments),
  //投料复核页面2
  '/feedTwo': (context, {arguments}) => FeedingTwo(arguments: arguments),
  //投料复核页面
  '/insertFeed': (context, {arguments}) => InsertFeeding(arguments: arguments),
  //投料复核页面2
  '/insertFeedTwo': (context, {arguments}) =>
      InsertFeedingTwo(arguments: arguments),
  //半成品投料
  '/products': (context, {arguments}) => Products(arguments: arguments),
  //物料信息
  '/materiel': (context, {arguments}) => Materiel(arguments: arguments),
  //物料信息
  '/stock': (context, {arguments}) => StockReturn(arguments: arguments),
  //设备状态
  '/equipment': (context, {arguments}) => Equipment(arguments: arguments),
  //重打标签
  '/label': (context, {arguments}) => ReLabel(arguments: arguments),
  //更改设备状态
  '/change': (context, {arguments}) => Change(arguments: arguments),
  //备料查询
  '/preparation': (context, {arguments}) => Preparation(arguments: arguments),
  //设置页面
  '/setting': (context) => Setting(),
  //登录
  '/login': (context) => LoginPage(),
  //注册
  '/register': (context) => RegisterPage(),
  //修改密码
  '/update': (context) => UpdatePwdPage(),
};

// ignore: missing_return
RouteFactory onGenerateRoute = (RouteSettings settings) {
  // 统一处理
  final String name = settings.name;
  final Function pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
