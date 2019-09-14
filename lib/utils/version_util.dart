import 'package:package_info/package_info.dart';

class VersionUtil {
  static Future<String> getVersion() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}