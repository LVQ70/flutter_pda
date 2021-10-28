import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class AnimationDemoPage extends StatefulWidget {
  AnimationDemoPage({Key key}) : super(key: key);

  @override
  _AnimationDemoPageState createState() => _AnimationDemoPageState();
}

class _AnimationDemoPageState extends State<AnimationDemoPage>
    with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController animationController;
  /*
  AnimationController属性
  value就是当前动画的值
  duration就是持续的时间
  debuglabel 就是用于识别该动画的一个标签
  lowerBound 跟 upperBound就是动画的值最大跟最小值
  vsync 可以理解为提供玩这个动画的门票  
  */
  @override
  void initState() {
    super.initState();
    //创建动画显示时间
    animationController =
        new AnimationController(duration: Duration(seconds: 3), vsync: this);
    //设置动画类型显示方式
    animation = new Tween(begin: 0.0,end: 0.25).animate(animationController)
      //监听事件
      ..addListener(() {
        setState(() {});
      });
    //获取当前状态
    animation.addStatusListener(((state) {
      setState(() {
        //正向动画结束时
        if (state == AnimationStatus.completed) {
          //反向播放
          animationController.reverse();
          //反转结束时
        } else if (state == AnimationStatus.dismissed) {
          //正向播放
          animationController.forward();
        }
      });
    }));
    // 开启动画 正向播放
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AnimationPage'),
      ),
      body: RotationTransition(
        turns: animationController,
        child: Container(
          width: 100,
          height: 100,
          color: Colors.red,
          child: Text('data'),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    //销毁动画
    animationController.dispose();
  }
}
