import 'dart:io';

import 'package:anychat/page/router.dart';
import 'package:chewie/chewie.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends HookWidget {
  static const String routeName = '/video';

  VideoPlayerPage(this.file, {super.key});

  final File file;

  late final VideoPlayerController videoController;

  @override
  Widget build(BuildContext context) {
    final chewieController = useState<ChewieController?>(null);

    useEffect(() {
      if (Platform.isIOS && file.path.endsWith('.temp')) {
        final outputFilePath = file.path.replaceAll('.temp', '.mp4');
        _convertTempToMp4(file.path, outputFilePath).then((_) {
          videoController = VideoPlayerController.file(File(outputFilePath));
          videoController.initialize().then((_) {
            chewieController.value = ChewieController(
              videoPlayerController: videoController,
              autoPlay: true,
              looping: false,
              allowFullScreen: false,
              aspectRatio: videoController.value.aspectRatio,
              allowPlaybackSpeedChanging: false,
            );
          });
        });
      } else {
        videoController = VideoPlayerController.file(file);

        videoController.initialize().then((_) {
          chewieController.value = ChewieController(
            videoPlayerController: videoController,
            autoPlay: true,
            looping: false,
            allowFullScreen: false,
            aspectRatio: videoController.value.aspectRatio,
            allowPlaybackSpeedChanging: false,
          );
        });
      }

      return () {
        videoController.dispose();
        chewieController.value?.dispose();
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
        body: SafeArea(
            child: chewieController.value == null
                ? const Center(child: CircularProgressIndicator())
                : Chewie(controller: chewieController.value!)));
  }

  Future<void> _convertTempToMp4(String tempFilePath, String outputFilePath) async {
    await FFmpegKit.execute('-i $tempFilePath -c:v copy -c:a copy $outputFilePath');
  }
}
