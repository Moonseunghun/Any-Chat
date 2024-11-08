import 'package:flutter/cupertino.dart';

class OverlayComponent {
  static final List<OverlayEntry> _entry = [];

  static void showOverlay({required BuildContext context, required Widget child}) {
    _entry.add(OverlayEntry(builder: (context) {
      return child;
    }));

    Overlay.of(context).insert(_entry.last);
  }

  static void hideOverlay() {
    _entry.lastOrNull?.remove();
    _entry.removeLast();
  }
}
