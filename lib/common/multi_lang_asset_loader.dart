import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class MultiLangAssetLoader extends AssetLoader {
  const MultiLangAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    return jsonMap[locale.languageCode] ?? {};
  }
}
