import 'package:flutter/material.dart';

class MyBottomBar extends StatelessWidget {
  final Function(int) onTap;
  final int selectedIndex;

  MyBottomBar({required this.onTap, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 5.0,
      shape: CircularNotchedRectangle(),
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildItem(Icons.home_outlined,  0),
          _buildItem(Icons.folder_outlined, 1),
          _buildItem(Icons.person_outline_outlined,  2),
          _buildItem(Icons.settings_outlined,  3),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, int index) {
    Color color = selectedIndex == index ?  Color(0xFF00BFA5): Colors.black;
    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            //Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
