
import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/utils/sp_util.dart';
import 'package:nora_chat/event/event_bus.dart';
import 'package:nora_chat/utils/constants_util.dart';

import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  _initTimer() async {

    try {
      await SpUtil.getInstance();
      JMUserInfo userInfo = await jmessage.getMyInfo();
      if(SpUtil.getString(ConstantsUtil.SYSTEM_THEME) != null) {
        eventBus.fire(UpdateTheme(message: SpUtil.getString(ConstantsUtil.SYSTEM_THEME)));
      }
      await Future.delayed(Duration(seconds: 1),(){

        if (userInfo.username != null) {
          Navigator.pushReplacementNamed(context, '/main_page');
        } else {
          Navigator.pushReplacementNamed(context, '/login_page');
        }
      });

    } catch (error) {
      Navigator.pushReplacementNamed(context, '/login_page');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Builder(builder: (context) {
      return Container(
        color: Colors.white,
        child: Image(image: AssetImage('assets/images/splash.png'), fit: BoxFit.fill,),
      );
    });

  }
}