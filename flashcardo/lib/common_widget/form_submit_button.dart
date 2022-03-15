import 'package:flutter/material.dart';
import 'package:flashcardo/common_widget/custom_raised_button.dart';

class FormSubmitButton extends CustomRaisedButton {
  FormSubmitButton({
    @required String text,
    VoidCallback onPressed,
  }) : super(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          height: 44,
          color: Colors.green,
          disabledColor: Colors.grey,
          borderRadius: 20,
          onPressed: onPressed,
        );
}
