import 'package:firebase_core/firebase_core.dart';
import 'package:flashcardo/common_widget/show_alert_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showExceptionAlertDialog(
  BuildContext context, {
  @required String title,
  @required Exception exception,
}) =>
    showAlertDialog(
      context,
      title: title,
      content: _message(exception),
      defaultActionText: "OK",
    );

String _message(Exception exception) {
  if (exception is FirebaseException) {
    return exception.message;
  }
  return exception.toString();
}
