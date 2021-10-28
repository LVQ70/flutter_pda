import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pda_mes/base/scannerBase.dart';

class WidgetBase {
  static Widget scaffoldBase(String title, Widget widgets) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: Stack(
          children: [
            widgets,
            Positioned(
              right: 10,
              bottom: 10,
              child: GestureDetector(
                child: CircleAvatar(
                  radius: 35,
                  child: Icon(
                    Icons.center_focus_strong,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                onTapUp: (val) {
                  stopScan();
                },
                onTapDown: (val) {
                  startScan();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget rowTextTwo(String leftTxt, String rightTxt) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              "$leftTxt：",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 20, letterSpacing: leftTxt.length < 4 ? 5.5 : 0),
            ),
          ),
          flex: 1,
        ),
        Expanded(
          child: Text(
            rightTxt,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          flex: 2,
        ),
      ],
    );
  }
}
