import 'package:aitravelplanner/dashboard/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAnpDQC6ZEL3kP3Y_xgPTwmBg5mf12wJ_U',
      appId: '1:304251559498:android:1422017c0f452b5c0190b3',
      messagingSenderId: '304251559498',
      projectId: 'aitravel-planner',
    ),
  );

  // Sign in the user anonymously
  UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
  String userId = userCredential.user!.uid;

  runApp(MyApp(userId: userId));
}

class MyApp extends StatelessWidget {
  final String userId;

  MyApp({required this.userId});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'The Narator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardScreen(userId: userId),
    );
  }
}

