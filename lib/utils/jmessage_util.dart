import 'package:flutter/services.dart';
import 'package:jmessage_flutter/jmessage_flutter.dart';
import 'package:platform/platform.dart';

export 'package:jmessage_flutter/jmessage_flutter.dart';

MethodChannel channel = MethodChannel('jmessage_flutter');
JmessageFlutter jmessage = new JmessageFlutter.private(channel, const LocalPlatform());
const String appKey = '7d4f746c37ff641809ba52c1';
class JMessageUtil {

  ///初始化 Jmessage
  static Future<void> jMessageInit() async {
    jmessage.setDebugMode(enable: false);
    jmessage.init(isOpenMessageRoaming: true, appkey: appKey);
  }

}