import 'package:flutter/widgets.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ToastUtil {
    
    static Future<void> showLodingToast() async {
      Widget widget = Center(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SpinKitFadingCircle(
            color: Colors.white,
            size: 30,
            duration: Duration(seconds: 1),
          ),
        ),
      );
      showToastWidget(widget,dismissOtherToast: true,duration: Duration(minutes: 10));
    }
  
    static Future<void> showLoadingToastWithText(String msg) async {

    Widget widget = Center(
      child:Container(
        height: 150,
        width: 200,
        padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SpinKitCircle(
              color: Colors.white,
              size: 50,
              duration: Duration(seconds: 1),
            ),
            Text(
              msg,
              style: TextStyle(fontSize: 17.0, color: Colors.white)
            )
          ],
        )
      )
    );
    showToastWidget(widget,dismissOtherToast: true, duration: Duration(minutes: 10), );
  }

  static Future<void> dismissMyToast() async{
      dismissAllToast();
  }

  static Future<void> showTextToast(String msg) async {
        Widget showWidget = Center(
      child:Container(
        padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          msg,
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
    )
    );

    showToastWidget(
      showWidget,
      duration: Duration(seconds: 2),
      position: ToastPosition.center,
      dismissOtherToast: true,

      );  
  }
}