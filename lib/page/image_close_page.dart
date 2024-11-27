import 'dart:io';

import 'package:anychat/page/router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageClosePage extends StatelessWidget {
  static const String routeName = '/image';

  const ImageClosePage({super.key, this.file, this.imageUrl});

  final File? file;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 48,
            leading: IconButton(
                onPressed: () {
                  router.pop();
                },
                icon: const Icon(Icons.close, color: Colors.white, size: 24))),
        body: Center(
            child: file == null
                ? CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover)
                : Image.file(file!, fit: BoxFit.cover)));
  }
}
