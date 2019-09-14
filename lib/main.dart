import 'package:oktoast/oktoast.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

import 'package:nora_chat/ui/spalsh_page.dart';
import 'package:nora_chat/ui/main_page.dart';
import 'package:nora_chat/ui/add_friend_page.dart';
import 'package:nora_chat/ui/login_page/login_page.dart';
import 'package:nora_chat/ui/new_friend_page.dart';
import 'package:nora_chat/ui/setting_page.dart';
import 'package:nora_chat/utils/theme_util.dart';
import 'package:nora_chat/utils/jmessage_util.dart';
import 'package:nora_chat/event/event_bus.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() { 
  runApp(MyApp());
  if (Platform.isAndroid) {
   // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前       MaterialApp组件会覆盖掉这个值。
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor:    Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override 
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  String debugLable = 'Unkown';

  final JPush jpush = new JPush();

  ThemeData defaultTheme = ThemeUtil.getDarkTheme();
  
  @override
  void initState() {
    super.initState();
    JMessageUtil.jMessageInit();
    _initJPush();
    _addListener();

  }

  _addListener() {
    eventBus.on<UpdateTheme>().listen((event){
      if (event.message == 'dark') {
        setState(() {
          defaultTheme = ThemeUtil.getDarkTheme();
        });
      } else if(event.message == ''){
        setState(() {
          defaultTheme = ThemeUtil.getDarkTheme();
        });
      } else {
        setState(() {
          defaultTheme = ThemeUtil.getLightTheme();
        });
      }
    });
  }

  Future<void> _initJPush() {
    String platformVersion;

    jpush.getRegistrationID().then((rid){
      setState(() {
        debugLable = 'flutter getRedistrationID: $rid';
      });
    });

    jpush.setup(
      appKey:appKey, 
      channel: 'theChannel',
      production: false,
      debug: false,
    );

     try {
      
      jpush.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");
        setState(() {
            debugLable = "flutter onReceiveNotification: $message";
          });
      },
      onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
        setState(() {
            debugLable = "flutter onOpenNotification: $message";
          });
      },
      onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
        setState(() {
            debugLable = "flutter onReceiveMessage: $message";
          });
      },
      );

    } catch (error) {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
   
    if (mounted) {
      setState(() {
        debugLable = platformVersion;
      });
    } 
  }
  @override
  Widget build(BuildContext context) {

    return OKToast(
      dismissOtherOnShow: true,
      child:MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nora',
        theme: defaultTheme,
        home: SplashPage(),
        routes: {
          '/login_page': (context) => LoginPage(),
          '/main_page': (context) => MainPage(),
          '/add_friend_page': (context) => AddFriendPage(),
          '/new_friend_page': (context) => NewFriendsPage(),
          '/setting_page': (context) => SettingPage()
        },
      )
    );

  }
}

