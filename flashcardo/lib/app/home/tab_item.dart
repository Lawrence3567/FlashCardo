import 'package:flutter/material.dart';

enum TabItem { sets, home, account }

class TabItemData {
  const TabItemData({this.title, @required this.icon});
  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.sets: TabItemData(icon: Icons.view_headline),
    TabItem.home: TabItemData(icon: Icons.home),
    TabItem.account: TabItemData(icon: Icons.person),
  };
}
