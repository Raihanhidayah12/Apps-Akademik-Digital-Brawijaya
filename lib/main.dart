import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'utils/notification_service.dart';
import 'platform/db_init_io.dart' if (dart.library.html) 'platform/db_init_web.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Setup database khusus desktop (no-op di Web)
  initDesktopDatabase();

  if (!kIsWeb) {
    await NotificationService.init();
  }

  // ✅ Jalankan aplikasi
  runApp(const MyApp());
}
