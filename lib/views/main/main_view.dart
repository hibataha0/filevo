import 'package:filevo/components/NavigationBar%20.dart';
import 'package:filevo/views/home/home_view.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeView(), // استدعاء HomeView كما هو
     floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
floatingActionButton: Container(
  margin: EdgeInsets.only(bottom: 10),
  width: 56,
  height: 56,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF4D62D5), // #4D62D5
        Color(0xFF28336F), // #28336F
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Material(
    shape: CircleBorder(),
    color: Colors.transparent,
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      child: Icon(Icons.add, color: Colors.white, size: 30),
    ),
  ),
),
bottomNavigationBar: MyBottomBar(
  selectedIndex: selected,
  onTap: (index) {
    setState(() {
      selected = index;
    });
  },
),
    );
  }
}
