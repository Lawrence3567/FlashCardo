import 'package:flashcardo/app/home/quiz/question_controller.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    Key key,
    @required this.preferredDuration,
    @required this.questionAmount,
    @required this.score,
    @required this.database,
  }) : super(key: key);

  final int preferredDuration;
  final int questionAmount;
  final int score;
  final Database database;
  //final String setId;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<String> images = [
    "images/perfect.png",
    "images/excellent.png",
    "images/good.png",
    "images/bad.png"
  ];

  String message;
  String image;
  int count = 0;

  @override
  void initState() {
    super.initState();
    if (widget.score < 50) {
      image = images[3];
      message = "Failure is the mother of success! Try harder next time!";
    } else if (widget.score < 75) {
      image = images[2];
      message = "Good Job! Keep it up!";
    } else if (widget.score < 100) {
      image = images[1];
      message = "Excellent! You are almost there!";
    } else {
      image = images[0];
      message = "Perfecto! You are unbelievable!";
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final _screenHeight = queryData.size.height;
    final _blockSize = _screenHeight / 100;

    QuestionController _qnController = Get.put(QuestionController(
        widget.preferredDuration, widget.questionAmount, widget.database, ""));
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text("Quiz Result"),
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
            leading: BackButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: _blockSize * 5,
              ),
              Material(
                color: Colors.grey[900],
                child: Container(
                  width: _blockSize * 50,
                  height: _blockSize * 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.amber,
                        blurRadius: 5,
                        spreadRadius: 5,
                        offset: Offset(0, 1),
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                  ),
                  child: Image(
                    image: AssetImage(image),
                  ),
                ),
              ),
              SizedBox(
                height: _blockSize * 4,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SizedBox(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: _blockSize * 3,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(
                height: _blockSize * 4,
              ),
              Text.rich(
                TextSpan(
                    text: "You scored ",
                    style: TextStyle(
                        fontSize: _blockSize * 3,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: "${widget.score}%",
                        style: TextStyle(
                            fontSize: _blockSize * 3,
                            color: widget.score >= 50
                                ? Colors.lightGreen[300]
                                : Colors.red,
                            fontWeight: FontWeight.w500),
                      ),
                    ]),
              ),
              SizedBox(
                height: _blockSize * 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(100, 15)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.lightGreenAccent[100].withOpacity(1),
                          blurRadius: 5,
                          spreadRadius: 5,
                          offset: Offset(0, 1),
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.lightGreen,
                        ),
                        Opacity(
                          opacity: 0,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.lightGreen,
                            size: _blockSize * 1,
                          ),
                        ),
                        Text(
                          "${_qnController.numOfCorrectAns} Correct",
                          style: TextStyle(
                              color: Colors.white, fontSize: _blockSize * 2.5),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(100, 15)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.lightGreenAccent[100].withOpacity(1),
                          blurRadius: 5,
                          spreadRadius: 5,
                          offset: Offset(0, 1),
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        Opacity(
                          opacity: 0,
                          child: Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: _blockSize * 1,
                          ),
                        ),
                        Text(
                          "${_qnController.questionAmount - _qnController.numOfCorrectAns} Wrong",
                          style: TextStyle(
                              color: Colors.white, fontSize: _blockSize * 2.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: _blockSize * 20,
                    height: _blockSize * 8,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) {
                          return count++ == 2;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return Colors.lightGreen[400];
                          },
                        ),
                        shadowColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return Colors.lightGreen[200];
                          },
                        ),
                        overlayColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return states.contains(MaterialState.pressed)
                                ? Colors.lightGreenAccent[100]
                                : null;
                          },
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        )),
                      ),
                      child: Text("Retake Quiz",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: _blockSize * 1.8,
                            fontWeight: FontWeight.w800,
                          )),
                    ),
                  ),
                  Container(
                    width: _blockSize * 20,
                    height: _blockSize * 8,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return Colors.lightGreen[400];
                          },
                        ),
                        shadowColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return Colors.lightGreen[200];
                          },
                        ),
                        overlayColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return states.contains(MaterialState.pressed)
                                ? Colors.lightGreenAccent[100]
                                : null;
                          },
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        )),
                      ),
                      child: Text("Back to Home",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: _blockSize * 1.8,
                            fontWeight: FontWeight.w800,
                          )),
                    ),
                  ),
                ],
              )),
            ],
          )),
    );
  }
}
