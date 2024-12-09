import 'dart:io';

import 'package:anychat/common/config.dart';
import 'package:anychat/common/error.dart';
import 'package:dio/dio.dart';

class LauncherService {
  Future<void> launcher() async {
    await Dio().get('${HttpConfig.prodUrl}/launcher/api', queryParameters: {
      'appVersion': HttpConfig.appVersion,
      'osTypeId': Platform.isIOS ? 2 : 1,
    }).run(null, (result) {
      HttpConfig.url = result.data['data']['servers']['web'];
      HttpConfig.webSocketUrl = result.data['data']['servers']['socket'];
      final serverStatus = result.data['data']['serverStatus']['name'];
    }, errorHandler: (error) {});
  }
}
