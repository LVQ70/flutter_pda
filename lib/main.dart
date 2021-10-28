import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pda_mes/routes/Routes.dart';
import 'package:pda_mes/base/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '制造执行系统（MES）',
      theme: ThemeData(
        primaryColor: themeColor,
      ),
      //初始加载命名路由
      initialRoute: '/index',
      onGenerateRoute: onGenerateRoute,
      //去掉debug
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      //国际化
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('zh', 'CH'),
        const Locale('en', 'US'),
      ],
      // home: SplashPage(),
    );
  }
}
