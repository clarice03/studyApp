import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'firebase_options.dart';
import 'screens/homescreen.dart';
import 'notificationService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 📊 Analytics instance
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // 📊 Log test event (for DebugView testing)
  await analytics.logEvent(
    name: 'app_started',
  );

  print("🔥 Firebase Analytics event sent");

  // 📦 Hive setup
  await Hive.initFlutter();
  await Hive.openBox('tasksBox');

  // 🔔 Notifications
  await NotificationService.init();

  runApp(const StudyPlannerApp());
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exam Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}