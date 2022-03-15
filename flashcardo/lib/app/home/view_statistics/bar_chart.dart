import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/common_widget/show_alert_dialog.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Barchart extends StatefulWidget {
  Barchart({
    this.context,
    this.seriesBarData,
    this.studySet,
    this.database,
  });

  final BuildContext context;
  final List<charts.Series<BarChartData, String>> seriesBarData;
  final StudySet studySet;
  final Database database;

  @override
  State<Barchart> createState() => _BarchartState();
}

class _BarchartState extends State<Barchart> {
  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      widget.seriesBarData,
      primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
        labelStyle: charts.TextStyleSpec(
          fontSize: 10,
          color: charts.MaterialPalette.white,
        ),
      )),
      domainAxis: charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
        labelStyle: charts.TextStyleSpec(
          fontSize: 10,
          color: charts.MaterialPalette.white,
        ),
      )),
      animate: true,
      vertical: false,
      barGroupingType: charts.BarGroupingType.grouped,
      animationDuration: Duration(seconds: 1),
      selectionModels: [
        new charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  void _onSelectionChanged(charts.SelectionModel<String> model) {
    final selectedDatum = model.selectedDatum;

    if (selectedDatum.isNotEmpty) {
      showAlertDialog(context,
          title: "${selectedDatum.first.datum.setName}",
          content:
              "Average Score: ${selectedDatum.first.datum.avgScore}\n\nQuiz Taken: ${(selectedDatum.first.datum.quizTaken).round()}\n\nMost Correct Flashcard: ${selectedDatum.first.datum.mostCorrectFlashcard}\nAmount: ${selectedDatum.first.datum.correctAmount}\n\nMost Wrong Flashcard: ${selectedDatum.first.datum.mostWrongFlashcard}\nAmount: ${selectedDatum.first.datum.wrongAmount}",
          defaultActionText: "OK");
    }
  }
}

class BarChartData {
  String setName;
  double avgScore;
  String mostCorrectFlashcard;
  int correctAmount;
  String mostWrongFlashcard;
  int wrongAmount;
  double quizTaken;

  BarChartData(
      this.setName,
      this.avgScore,
      this.mostCorrectFlashcard,
      this.correctAmount,
      this.mostWrongFlashcard,
      this.wrongAmount,
      this.quizTaken);

  @override
  String toString() {
    return "$setName + $avgScore";
  }
}
