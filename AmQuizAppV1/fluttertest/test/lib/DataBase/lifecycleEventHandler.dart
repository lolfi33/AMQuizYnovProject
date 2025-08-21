import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallback;
  final AsyncCallback? detachedCallback;

  LifecycleEventHandler({this.resumeCallback, this.detachedCallback});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallback != null) await resumeCallback!();
        break;
      case AppLifecycleState.detached:
        if (detachedCallback != null) await detachedCallback!();
        break;
      default:
        break;
    }
  }
}
