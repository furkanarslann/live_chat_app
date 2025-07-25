import 'package:firebase_core/firebase_core.dart';
import 'package:live_chat_app/firebase_options.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
