import 'package:flutter/material.dart';

class FlashcardBackview extends StatelessWidget {
  const FlashcardBackview({
    Key key,
    @required this.text,
    @required this.fontSize,
    @required this.color,
    @required this.elevationColor,
    this.url,
  }) : super(key: key);

  final String text;
  final double fontSize;
  final Color color;
  final Color elevationColor;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: elevationColor.withOpacity(1),
            blurRadius: 8,
            spreadRadius: 5,
            offset: Offset(0, 1),
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Card(
        elevation: 15,
        color: color,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (url != "empty")
                    Image.network(
                      url,
                      width: 250,
                      height: 230,
                    ),
                  if (url != "empty") SizedBox(height: 20),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
