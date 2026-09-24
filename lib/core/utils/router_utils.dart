import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension GoRouterExtension on BuildContext {
  static DateTime? _lastPushTime;
  static String? _lastPushLocation;

  Future<T?> safePushRoute<T extends Object?>(String location, {Object? extra}) {
    final now = DateTime.now();
    if (_lastPushLocation == location &&
        _lastPushTime != null &&
        now.difference(_lastPushTime!) < const Duration(milliseconds: 500)) {
      return Future.value(null); // Ignore double tap
    }
    _lastPushTime = now;
    _lastPushLocation = location;
    
    // Inject a unique ID to prevent go_router duplicate page key crashes in ShellRoute
    final uniqueId = DateTime.now().microsecondsSinceEpoch.toString();
    final Map<String, dynamic> newExtra = {'_internal_push_id': uniqueId};
    if (extra != null) {
      newExtra['data'] = extra;
    }
    
    return push<T>(location, extra: newExtra);
  }
}
