import 'package:flutter/material.dart';

class AddTermDefCard extends StatefulWidget {
  const AddTermDefCard({
    Key key,
    this.flashcardID,
    this.focusNode,
    this.termController,
    this.defController,
  }) : super(key: key);

  final String flashcardID;
  final FocusNode focusNode;
  final TextEditingController termController;
  final TextEditingController defController;

  @override
  _AddTermDefCardState createState() => _AddTermDefCardState();
}

class _AddTermDefCardState extends State<AddTermDefCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: "Term",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey[200]),
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen[200])),
                ),
                onChanged: (term) {
                  setState(() {});
                },
                controller: widget.termController,
                focusNode: widget.focusNode,
              ),
              TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: "Definition",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey[200]),
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen[200])),
                ),
                onChanged: (definition) {
                  setState(() {});
                },
                controller: widget.defController,
              )
            ],
          ),
        ),
      ),
    );
  }
}
