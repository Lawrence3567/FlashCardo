import 'package:flashcardo/app/home/settings_page.dart';
import 'package:flashcardo/app/home/cupertino_home_scaffold.dart';
import 'package:flashcardo/app/home/study_set/study_set_list_page.dart';
import 'package:flashcardo/app/home/tab_item.dart';
import 'package:flashcardo/app/home/home_page.dart';
import 'package:flutter/material.dart';

class ChosenPage extends StatefulWidget {
  @override
  _ChosenPageState createState() => _ChosenPageState();
}

class _ChosenPageState extends State<ChosenPage> {
  TabItem _currentTab = TabItem.home;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.sets: GlobalKey<NavigatorState>(),
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.sets: (_) => StudySetListPage(),
      TabItem.home: (_) => HomePage(),
      TabItem.account: (_) => SettingsPage(),
    };
  }

  void _select(TabItem tabItem) {
    setState(() => _currentTab = tabItem);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[_currentTab].currentState.maybePop(),
      child: CupertinoHomeScaffold(
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
        navigatorKeys: navigatorKeys,
      ),
    );
  }
}
