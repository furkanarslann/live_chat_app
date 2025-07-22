import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live_chat_app/live_chat_app.dart';
import 'package:live_chat_app/setup_binding.dart';
import 'package:live_chat_app/setup_dependencies.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      setupBindings();
      await setupDependencies();
      runApp(const LiveChatApp());
    },
    (error, stackTrace) {
      // Handle errors using a 3rd-party service later, for now just printing
      debugPrint('Caught error: $error');
      debugPrint('Stack trace: $stackTrace');
    },
  );
}
