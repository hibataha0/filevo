// custom_tab_bar.dart
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController? controller;
  final List<String> tabs;
  final Color backgroundColor;
  final Color indicatorColor;
  final Color labelColor;
  final Color unselectedLabelColor;

  const CustomTabBar({
    Key? key,
    this.controller,
    required this.tabs,
    this.backgroundColor = Colors.white,
    this.indicatorColor = Colors.green,
    this.labelColor = Colors.white,
    this.unselectedLabelColor = Colors.white70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: backgroundColor.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: TabBar(
          controller: controller,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          labelColor: labelColor,
          unselectedLabelColor: unselectedLabelColor,
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
    );
  }
}