import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../service/chat_service.dart';
import '../../service/friend_service.dart';
import '../router.dart';

class QrViewPage extends HookConsumerWidget {
  static const String routeName = '/qr_code';

  QrViewPage(this.index, {super.key});

  final GlobalKey _qrKey = GlobalKey();
  final int index;
  bool canScan = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 48,
            leading: IconButton(
                onPressed: () {
                  router.pop();
                },
                icon: const Icon(Icons.close, color: Color(0xFF3B3B3B), size: 24)),
            title: const Text('QR 코드 스캔',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            centerTitle: true),
        body: QRView(
          key: _qrKey,
          onQRViewCreated: (controller) {
            controller.scannedDataStream.listen((scanData) {
              if (scanData.code == null || !canScan) return;
              canScan = false;
              controller.pauseCamera();

              if (index == 0) {
                FriendService().addFriend(ref, scanData.code!).then((_) {
                  router.pop();
                }).catchError((e) {
                  controller.resumeCamera();
                  canScan = true;
                });
              } else if (index == 1) {
                chatService.makeRoom([scanData.code!]).catchError((e) {
                  controller.resumeCamera();
                  canScan = true;
                });
              } else if (index == 2) {
                chatService.inviteUsers([scanData.code!]);
                router.pop();
                router.pop();
              }
            });
          },
          overlay: QrScannerOverlayShape(
              borderColor: Colors.blueAccent,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 353.w),
        ));
  }
}
