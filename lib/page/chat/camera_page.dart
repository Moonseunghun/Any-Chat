import 'package:anychat/page/router.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CameraPage extends HookWidget {
  static const String routeName = '/camera';

  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isCameraInitialized = useState<bool>(false);
    final cameras = useState<List<CameraDescription>>([]);
    final cameraController = useState<CameraController?>(null);
    final viewIndex = useState<int>(0);
    final isVideo = useState<bool>(false);
    final isVideoRecording = useState<bool>(false);
    final isLoading = useState<bool>(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        availableCameras().then((result) async {
          cameras.value = result;

          cameraController.value = CameraController(
            cameras.value[viewIndex.value],
            ResolutionPreset.high,
          );

          await cameraController.value!.initialize();
          isCameraInitialized.value = true;
        });
      });

      return () {};
    }, []);

    if (!isCameraInitialized.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          Column(
            children: [
              Expanded(child: CameraPreview(cameraController.value!)),
              Container(
                  height: 160.h,
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isVideoRecording.value)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () {
                                  isVideo.value = false;
                                },
                                child: Text('Picture',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight:
                                            !isVideo.value ? FontWeight.bold : FontWeight.normal))),
                            SizedBox(width: 20.w),
                            TextButton(
                                onPressed: () {
                                  isVideo.value = true;
                                },
                                child: Text('Video',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight:
                                            isVideo.value ? FontWeight.bold : FontWeight.normal))),
                          ],
                        ),
                      Expanded(
                          child: Stack(
                        children: [
                          if (!isVideoRecording.value)
                            Positioned.fill(
                                left: 20.w,
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                        onPressed: () {
                                          router.pop();
                                        },
                                        child: const Text('Cancel',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500))))),
                          Positioned.fill(
                              child: Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () async {
                                      isLoading.value = true;
                                      if (isVideo.value) {
                                        if (isVideoRecording.value) {
                                          final videoPath =
                                              await cameraController.value!.stopVideoRecording();
                                          router.pop(videoPath);
                                        } else {
                                          await cameraController.value!.startVideoRecording();
                                          isVideoRecording.value = true;
                                        }
                                      } else {
                                        final image = await cameraController.value!.takePicture();
                                        router.pop(image);
                                      }
                                      isLoading.value = false;
                                    },
                                    child: Container(
                                        width: 66,
                                        height: 66,
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: isVideoRecording.value
                                            ? Container(
                                                margin: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  border: const Border.fromBorderSide(
                                                      BorderSide(color: Colors.black, width: 1)),
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Colors.red,
                                                ),
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  border: const Border.fromBorderSide(
                                                      BorderSide(color: Colors.black, width: 2)),
                                                  shape: BoxShape.circle,
                                                  color: isVideo.value ? Colors.red : Colors.white,
                                                ),
                                              )),
                                  ))),
                          if (!isVideoRecording.value)
                            Positioned.fill(
                                right: 20.w,
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () async {
                                        isCameraInitialized.value = false;
                                        await cameraController.value!.dispose();
                                        cameraController.value = CameraController(
                                          cameras.value[viewIndex.value == 0 ? 1 : 0],
                                          ResolutionPreset.high,
                                        );
                                        await cameraController.value!.initialize();
                                        viewIndex.value = viewIndex.value == 0 ? 1 : 0;
                                        isCameraInitialized.value = true;
                                      },
                                      child: const Icon(Icons.change_circle,
                                          color: Colors.white, size: 40),
                                    )))
                        ],
                      )),
                      SizedBox(height: 20.h),
                    ],
                  )),
            ],
          ),
          if (isLoading.value)
            Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator())),
        ]));
  }
}
