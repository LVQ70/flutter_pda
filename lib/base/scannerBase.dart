import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

const MethodChannel methodChannel =
    MethodChannel('com.example.pda_mes/command');
const EventChannel scanChannel = EventChannel('com.example.pda_mes/scan');

Future<void> sendDataWedgeCommand(String command, String parameter) async {
  try {
    String argumentAsJson =
        jsonEncode({"command": command, "parameter": parameter});

    await methodChannel.invokeMethod(
        'sendDataWedgeCommandStringParameter', argumentAsJson);
  } on PlatformException {
    Fluttertoast.showToast(
      msg: '扫描头异常',
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }
}

Future<void> createProfile(String profileName) async {
  try {
    await methodChannel.invokeMethod('createDataWedgeProfile', profileName);
  } on PlatformException {
    Fluttertoast.showToast(
      msg: '扫描头异常',
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }
}

void startScan() {
  sendDataWedgeCommand(
      "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
}

void stopScan() {
  sendDataWedgeCommand(
      "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
}
