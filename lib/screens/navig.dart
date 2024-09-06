import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:stohz/screens/account.dart';
import 'package:stohz/screens/cart.dart';
import 'package:stohz/screens/fevorite.dart';
import 'package:stohz/screens/home.dart';

class Navig extends StatefulWidget {
  const Navig({super.key});

  @override
  State<Navig> createState() => _NavigState();
}

class _NavigState extends State<Navig> {
  int selectedIndex = 0;
  List<Widget> pages = [
    HomePage(),
    Heart(),
    Cart(),
    Account(),
  ];

  final iconList = <IconData>[
    Icons.home,
    Icons.favorite,
    Icons.shopping_cart,
    CupertinoIcons.person_alt,
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Stack(
        children: [
          AnimatedBottomNavigationBar(
            icons: iconList,
            activeIndex: selectedIndex,
            gapLocation: GapLocation.none,
            notchSmoothness: NotchSmoothness.smoothEdge,
            onTap: onItemTapped,
            activeColor: Color(0xfff06f45),
            inactiveColor: Colors.grey,
            splashColor: Color(0xfff06f45),
            iconSize: 24,
            leftCornerRadius: 32,
            rightCornerRadius: 32,
          ),
        ],
      ),
    );
  }
}
