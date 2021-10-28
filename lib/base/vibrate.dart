import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

import 'colors.dart';

//震动
Future<void> vibrate() async {
  final Iterable<Duration> pauses = [
    // const Duration(milliseconds: 0),
  ];
  Vibrate.vibrateWithPauses(pauses);
}

//语言提示
Future<void> playAudioSuccess() async {
  AudioCache player = new AudioCache();
  player.play('10997.mp3', mode: PlayerMode.LOW_LATENCY);
}

//失败
Future<void> playAudioError() async {
  AudioCache player = new AudioCache();
  player.play('10998.mp3', mode: PlayerMode.LOW_LATENCY);
}

//获取屏幕宽度
getWidth(context) {
  return MediaQuery.of(context).size.width;
}

//获取屏幕宽度
getHight(context) {
  return MediaQuery.of(context).size.height;
}

ButtonStyle buttonStyle() {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all(themeColor),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  );
}
