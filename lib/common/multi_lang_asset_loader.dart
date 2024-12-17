import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class MultiLangAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final data = await rootBundle.loadString(path);
    final translations = json.decode(data) as Map<String, dynamic>;

    final langData = translations[locale.toLanguageTag()] as Map<String, dynamic>?;

    return langData ?? {};
  }
}
