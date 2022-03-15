import 'package:flashcardo/app/home/quiz/choose_quiz_page.dart';
import 'package:flashcardo/app/home/study_set/add_set_page.dart';
import 'package:flashcardo/app/home/view_statistics/view_statistics_page.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text("Home"),
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
    );
    return Scaffold(
      appBar: appBar,
      body: _buildContent(context, appBar),
    );
  }

  Widget _buildContent(BuildContext context, AppBar appBar) {
    final database = Provider.of<Database>(context, listen: false);
    MediaQueryData queryData = MediaQuery.of(context);
    final _screenWidth = queryData.size.width;
    final _screenHeight = queryData.size.height;
    final _usableHeight = _screenHeight -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;
    final _blockSize = _screenWidth / 100;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/greybkg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Image.asset('images/flashcard.png'),
              iconSize: _usableHeight * 0.3,
              splashColor: Colors.lightGreen.withOpacity(0.5),
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                  builder: (context) => AddSetPage(database: database),
                  fullscreenDialog: true,
                ));
              },
            ),
          ),
          Text(
            "Create Flashcards",
            style: TextStyle(
              fontSize: _blockSize * 5,
              color: Colors.grey[300],
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _usableHeight * 0.01),
          SizedBox(
            height: _usableHeight * 0.3,
            width: _screenWidth * 0.8,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Column(
                    children: [
                      Flexible(
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: Image.asset('images/quiz.png'),
                            iconSize: _usableHeight * 0.3,
                            splashColor: Colors.lightGreen.withOpacity(0.5),
                            onPressed: () => ChooseQuizPage.show(context,
                                database: database),
                          ),
                        ),
                      ),
                      Text(
                        "Take a Quiz",
                        style: TextStyle(
                          fontSize: _blockSize * 4.5,
                          color: Colors.grey[300],
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    children: [
                      Flexible(
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: Image.asset('images/performance.png'),
                            iconSize: _usableHeight * 0.3,
                            splashColor: Colors.lightGreen.withOpacity(0.5),
                            onPressed: () => ViewStatisticsPage.show(context,
                                database: database),
                          ),
                        ),
                      ),
                      Text(
                        "Track Your Progress",
                        style: TextStyle(
                          fontSize: _blockSize * 4.5,
                          color: Colors.grey[300],
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(child: SizedBox(height: _usableHeight * 0.08)),
        ],
      ),
    );
  }
}
