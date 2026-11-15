import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  static Future<Map<String, dynamic>> get getDeviceInfo async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"
      Map<String, String> dict = {};
      dict.putIfAbsent('uuId', () => iosInfo.identifierForVendor ?? '');
      dict.putIfAbsent('model', () => iosInfo.model ?? '');
      dict.putIfAbsent('deviceName', () => iosInfo.name ?? '');
      dict.putIfAbsent(
          'version', () => iosInfo.systemName! + iosInfo.systemVersion!);
      dict.putIfAbsent('deviceType', () => 'IOS');
      return dict;
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      Map<String, dynamic> dict = {};
      // device_info_plus dropped androidId (it needed a permission Google no
      // longer grants); the build fingerprint id is what's left.
      dict.putIfAbsent('uuId', () => androidInfo.id);
      dict.putIfAbsent('model', () => androidInfo.model);
      dict.putIfAbsent('deviceName', () => androidInfo.brand);
      dict.putIfAbsent('version', () => androidInfo.version.release);
      dict.putIfAbsent('deviceType', () => 'Android');
      return dict;
    }
  }
}
