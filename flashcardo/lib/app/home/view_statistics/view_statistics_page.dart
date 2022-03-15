import 'dart:math';

import 'package:flashcardo/app/home/models/quiz_result.dart';
import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'bar_chart.dart';

class ViewStatisticsPage extends StatefulWidget {
  const ViewStatisticsPage(
      {Key key, @required this.studySet, @required this.database})
      : super(key: key);

  final StudySet studySet;
  final Database database;

  static Future<void> show(BuildContext context,
      {StudySet studySet, Database database}) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ViewStatisticsPage(
          studySet: studySet,
          database: database,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<ViewStatisticsPage> createState() => _ViewStatisticsPageState();
}

class _ViewStatisticsPageState extends State<ViewStatisticsPage> {
  List<charts.Series<BarChartData, String>> _seriesBarData = [];

  final colorList = <Color>[
    Color(4294822766),
    Color(4278813923),
    Color(4277813923),
    Color(4291158437),
    Color(4291728344),
  ];

  final gradientList = <List<Color>>[
    [
      Color.fromRGBO(223, 250, 92, 1),
      Color.fromRGBO(129, 250, 112, 1),
    ],
    [
      Color.fromRGBO(129, 182, 205, 1),
      Color.fromRGBO(91, 253, 199, 1),
    ],
    [
      Color.fromRGBO(175, 63, 62, 1.0),
      Color.fromRGBO(254, 154, 92, 1),
    ]
  ];

  bool _firstTime = true;
  int count;
  double countScores;
  List<StudySet> _studySets = [];
  List<QuizResult> _quizResults = [];
  Map<String, double> _numQuizPerSet = {"tteesstt": 1};
  List<BarChartData> _barChartDataList = [
    BarChartData(
        "tttteeeesssstttt", 0, "tttteeeesssstttt", 0, "tttteeeesssstttt", 0, 0)
  ];
  Map<String, List<String>> _correctListPerSet = {};
  Map<String, List<String>> _wrongListPerSet = {};
  Map<String, String> _nameMostCorrect = {};
  Map<String, int> _numFlashcardMostCorrect = {};
  Map<String, String> _nameMostWrong = {};
  Map<String, int> _numFlashcardMostWrong = {};

  @override
  void initState() {
    super.initState();
    loadQuizResultData();
  }

  void loadQuizResultData() async {
    final studySets = await widget.database.setsStream().first;
    _studySets = List.from(studySets);

    final quizResults = await widget.database.quizResultsStream().first;
    _quizResults = List.from(quizResults);

    final _random = Random();
    Color _randomColor = Color(0xC084EE);

    for (int i = 0; i < studySets.length; ++i) {
      _numQuizPerSet[studySets[i].name] = 0;
      count = 0;
      countScores = 0;
      List<String> _correctAns = [];
      List<String> _wrongAns = [];
      for (int j = 0; j < quizResults.length; ++j) {
        if (quizResults[j].setId == studySets[i].setId) {
          _numQuizPerSet[_studySets[i].name]++;
          count++;
          countScores += quizResults[j].score;

          _correctAns.addAll(quizResults[j].correctAns);
          _wrongAns.addAll(quizResults[j].wrongAns);
        }
      }
      _correctListPerSet[_studySets[i].name] = _correctAns;
      _wrongListPerSet[_studySets[i].name] = _wrongAns;

      Map<String, int> mostCorrect = Map();
      Map<String, int> mostWrong = Map();
      _correctAns.forEach((e) {
        if (!mostCorrect.containsKey(e)) {
          mostCorrect[e] = 1;
        } else {
          mostCorrect[e] += 1;
        }
      });
      int theValue = 0;
      String theKey = "(No Data)";

      mostCorrect.forEach((k, v) {
        if (v > theValue) {
          theValue = v;
          theKey = k;
        }
      });

      _nameMostCorrect[_studySets[i].name] = theKey;
      _numFlashcardMostCorrect[_studySets[i].name] = theValue;

      _wrongAns.forEach((e) {
        if (!mostWrong.containsKey(e)) {
          mostWrong[e] = 1;
        } else {
          mostWrong[e] += 1;
        }
      });

      theValue = 0;
      theKey = "(No Data)";

      mostWrong.forEach((k, v) {
        if (v > theValue) {
          theValue = v;
          theKey = k;
        }
      });

      _nameMostWrong[_studySets[i].name] = theKey;
      _numFlashcardMostWrong[_studySets[i].name] = theValue;

      if (_numQuizPerSet[studySets[i].name] != 0) {
        await _barChartDataList.add(BarChartData(
            studySets[i].name,
            countScores / count,
            _nameMostCorrect[_studySets[i].name],
            _numFlashcardMostCorrect[_studySets[i].name],
            _nameMostWrong[_studySets[i].name],
            _numFlashcardMostWrong[_studySets[i].name],
            _numQuizPerSet[_studySets[i].name]));

        if (colorList.length < studySets.length) {
          // Using Color.fromARGB
          do {
            _randomColor = Color.fromARGB(
                _random.nextInt(256),
                _random.nextInt(256),
                _random.nextInt(256),
                _random.nextInt(256));
          } while (colorList.contains(_randomColor) ||
              _randomColor == Colors.black ||
              _randomColor == Colors.white ||
              _randomColor == Colors.grey[850]);
          colorList.add(_randomColor);
        }
      } else {
        _numQuizPerSet
            .removeWhere((key, value) => key == "${_studySets[i].name}");
      }
    }
    _numQuizPerSet.removeWhere((key, value) => key == "tteesstt");
    if (_barChartDataList.length > 1) _barChartDataList.removeAt(0);

    _seriesBarData.add(charts.Series(
      domainFn: (BarChartData specificSet, _) => specificSet.setName,
      measureFn: (BarChartData specificSet, _) => specificSet.avgScore,
      id: 'barchart',
      data: _barChartDataList,
      fillPatternFn: (_, __) => charts.FillPatternType.solid,
      fillColorFn: (BarChartData specificSet, _) =>
          charts.ColorUtil.fromDartColor(Color.fromARGB(240, 51, 187, 255)),
      outsideLabelStyleAccessorFn: (BarChartData specificSet, _) =>
          charts.TextStyleSpec(color: charts.MaterialPalette.white),
      insideLabelStyleAccessorFn: (BarChartData specificSet, _) =>
          charts.TextStyleSpec(color: charts.MaterialPalette.white),
    ));
    setState(() {
      _firstTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Quiz Statistics"),
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
    MediaQueryData queryData = MediaQuery.of(context);
    final _screenWidth = queryData.size.width;
    final _screenHeight = queryData.size.height;
    final _blockSize = _screenHeight / 100;

    if (_quizResults.length == 0)
      return Center(
        child: Material(
          color: Colors.grey[900],
          child: Container(
            width: _blockSize * 30,
            height: _blockSize * 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey[400],
                  blurRadius: 5,
                  spreadRadius: 50,
                  offset: Offset(0, 1),
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
            child: Image(
              colorBlendMode: BlendMode.modulate,
              color: Colors.grey[900],
              image: AssetImage("images/listEmpty.png"),
            ),
          ),
        ),
      );

    final pieChart = PieChart(
      key: ValueKey(0),
      dataMap: _numQuizPerSet,
      animationDuration: Duration(milliseconds: 1000),
      chartLegendSpacing: 45,
      chartRadius: _screenWidth / 3.2 > 200 ? 200 : _screenWidth / 1.5,
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      centerText: "Quiz Taken",
      centerTextStyle: TextStyle(
          fontSize: 21, color: Colors.black, fontWeight: FontWeight.bold),
      legendOptions: LegendOptions(
        showLegendsInRow: true,
        legendPosition: LegendPosition.top,
        showLegends: true,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: false,
        showChartValuesOutside: true,
        decimalPlaces: 0,
      ),
      ringStrokeWidth: 40,
      emptyColor: Colors.grey,
    );
    return TabBarView(children: [
      Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _screenWidth - 50,
                height: _screenHeight / 1.8,
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.lightGreen[300].withOpacity(1),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: Offset(0, 1),
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: Card(
                  elevation: 20,
                  color: Colors.grey[850],
                  child:
                      Wrap(direction: Axis.horizontal, spacing: 10, children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 28),
                      child: SingleChildScrollView(child: pieChart),
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          child: Center(
            child: Column(
              children: [
                Text(
                  'Average Scores of Each Study Set / %',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
                Expanded(
                  child: Barchart(
                    context: context,
                    seriesBarData: _seriesBarData,
                    studySet: widget.studySet,
                    database: widget.database,
                  ),
                )
              ],
            ),
          ),
        ),
      )
    ]);
  }
}
