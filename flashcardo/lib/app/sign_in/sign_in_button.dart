import 'package:flashcardo/common_widget/custom_raised_button.dart';
import 'package:flutter/material.dart';

class SignInButton extends CustomRaisedButton {
  SignInButton({
    @required String text,
    Color color,
    Color textColor,
    VoidCallback onPressed,
  })  : assert(text != null),
        super(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 15),
          ),
          color: color,
          disabledColor: color,
          borderRadius: 15,
          onPressed: onPressed,
        );
}
