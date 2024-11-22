import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CacheManager {
  static Future<String> _getCacheDirectory() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<File?> getCachedImage(String imageUrl) async {
    final cacheDir = await _getCacheDirectory();
    final filePath = "$cacheDir/$imageUrl";
    final file = File(filePath);

    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  static Future<File> downloadAndCacheImage(String imageUrl) async {
    final Dio dio = Dio();
    final cacheDir = await _getCacheDirectory();
    final filePath = "$cacheDir/$imageUrl";

    await dio.download(imageUrl, filePath);
    manageCacheSize(200 * 1024 * 1024);
    return File(filePath);
  }

  static Future<int> _getCacheSize() async {
    final cacheDir = await _getCacheDirectory();
    final directory = Directory(cacheDir);

    if (!directory.existsSync()) return 0;

    int totalSize = 0;
    final files = directory.listSync();

    for (var file in files) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    return totalSize;
  }

  static Future<void> manageCacheSize(int maxSizeInBytes) async {
    final cacheDir = await _getCacheDirectory();
    final directory = Directory(cacheDir);

    int currentSize = await _getCacheSize();

    if (currentSize <= maxSizeInBytes) {
      return;
    }

    final files = directory.listSync().whereType<File>().toList()
      ..sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

    for (var file in files) {
      final fileSize = await file.length();
      await file.delete();

      currentSize -= fileSize;
      if (currentSize <= maxSizeInBytes) {
        break;
      }
    }
  }

  Future<ImageProvider> getImageProvider(String url) async {
    final file = await downloadAndCacheImage(url);
    return FileImage(file);
  }
}
