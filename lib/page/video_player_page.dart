import 'dart:io';

import 'package:anychat/page/router.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends HookWidget {
  static const String routeName = '/video';

  const VideoPlayerPage(this.file, {super.key});

  final File file;

  @override
  Widget build(BuildContext context) {
    final videoController = useState(VideoPlayerController.file(file));
    final chewieController = useState(ChewieController(
      videoPlayerController: videoController.value,
      autoPlay: true,
      looping: false,
      allowFullScreen: false,
      allowPlaybackSpeedChanging: false,
    ));

    useEffect(() {
      return () {
        videoController.value.dispose();
        chewieController.value.dispose();
      };
    }, []);

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
        body: SafeArea(child: Center(child: Chewie(controller: chewieController.value))));
  }
}
