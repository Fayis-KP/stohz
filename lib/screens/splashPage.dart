import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stohz/screens/login.dart';

class Splashpage extends StatefulWidget {
  const Splashpage({super.key});

  @override
  State<Splashpage> createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  @override
  void initState() {
    super.initState();
    // Start the timer for 5 seconds
    Timer(Duration(seconds: 4), () {
      // After 5 seconds, navigate to the next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your target page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/stohz.png"),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
