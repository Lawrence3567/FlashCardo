import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewResultsListviewPage extends StatefulWidget {
  const ViewResultsListviewPage(
      {Key key, @required this.studySet, @required this.database})
      : super(key: key);

  final StudySet studySet;
  final Database database;

  static Future<void> show(BuildContext context,
      {StudySet studySet, Database database}) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ViewResultsListviewPage(
          studySet: studySet,
          database: database,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<ViewResultsListviewPage> createState() =>
      _ViewResultsListviewPageState();
}

class _ViewResultsListviewPageState extends State<ViewResultsListviewPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Quiz History"),
          backgroundColor: Colors.lightGreen[400],
          elevation: 20,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.lightGreen[400], Colors.green[300]],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(FontAwesomeIcons.chartPie),
              ),
              Tab(
                icon: Icon(
                  FontAwesomeIcons.solidChartBar,
                ),
              ),
            ],
          ),
        ),
        body: _buildContents(context),
        backgroundColor: Colors.grey[900],
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    return Text("Hello");
  }
}
