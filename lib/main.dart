import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stohz/screens/home.dart';
import 'package:stohz/screens/navig.dart';
import 'package:stohz/screens/splashPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    var firebaseOptions = const FirebaseOptions(
      apiKey: "AIzaSyBfMwbk0NtO00LpWg_WPSgPo10NpeA4-4s",
      authDomain: 'stohz-20a9c.firebaseapp.com',
      projectId: 'stohz-20a9c',
      storageBucket: 'stohz-20a9c.appspot.com',
      messagingSenderId: '884488582323',
      appId: '1:884488582323:android:859e8b5193bdf1634b2cc6',
      //measurementId: '8041727286',
    );

    await Firebase.initializeApp(options: firebaseOptions);
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Splashpage(),debugShowCheckedModeBanner: false,
    );
  }
}
