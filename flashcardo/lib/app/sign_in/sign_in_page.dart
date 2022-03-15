import 'package:firebase_core/firebase_core.dart';
import 'package:flashcardo/app/sign_in/email_sign_in_page.dart';
import 'package:flashcardo/app/sign_in/sign_in_manager.dart';
import 'package:flashcardo/app/sign_in/sign_in_button.dart';
import 'package:flashcardo/app/sign_in/social_sign_in_button.dart';
import 'package:flashcardo/common_widget/show_exception_alert_dialog.dart';
import 'package:flashcardo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({
    Key key,
    @required this.manager,
    @required this.isLoading,
  }) : super(key: key);
  final SignInManager manager;
  final bool isLoading;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<SignInManager>(
          create: (_) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
            builder: (_, manager, __) =>
                SignInPage(manager: manager, isLoading: isLoading.value),
          ),
        ),
      ),
    );
  }

  void _showSignInError(BuildContext context, Exception exception) {
    if (exception is FirebaseException &&
        exception.code == "ERROR_ABORTED_BY_USER") {
      return;
    }
    showExceptionAlertDialog(
      context,
      title: "Sign in failed",
      exception: exception,
    );
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await manager.signInAnonymously();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await manager.signInWithGoogle();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await manager.signInWithFacebook();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  void _signInWithEmail(BuildContext context) {
    //Show EmailSignInPage
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => EmailSignInPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('FlashCardo'),
      //   elevation: 20,
      //   backgroundColor: Colors.lightGreen[400],
      // ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      color: Colors.grey[850],
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 50,
            child: _buildHeader(),
          ),
          SizedBox(height: 50),
          Flexible(
            child: SocialSignInButton(
              assetName: "images/google-logo.png",
              text: "Sign in with Google",
              color: Colors.white,
              textColor: Colors.black87,
              onPressed: isLoading ? null : () => _signInWithGoogle(context),
            ),
          ),
          SizedBox(height: 8),
          Flexible(
            child: SocialSignInButton(
              assetName: "images/facebook-logo.png",
              text: "Sign in with Facebook",
              color: Color(0xFF334D92),
              textColor: Colors.white,
              onPressed: isLoading ? null : () => _signInWithFacebook(context),
            ),
          ),
          SizedBox(height: 8),
          Flexible(
            child: SocialSignInButton(
              assetName: "images/gmail-logo.png",
              text: "Sign in with Email",
              color: Colors.teal[700],
              textColor: Colors.white,
              onPressed: isLoading ? null : () => _signInWithEmail(context),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "or",
            style: TextStyle(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Flexible(
            child: SignInButton(
              text: "Go Anonymous",
              color: Colors.lightGreen[300],
              textColor: Colors.black,
              onPressed: isLoading ? null : () => _signInAnonymously(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      "FlashCardo",
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.lime[300],
          fontSize: 45,
          fontWeight: FontWeight.w900,
          shadows: <Shadow>[
            Shadow(
              offset: Offset(10.0, 10.0),
              blurRadius: 4.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ]),
    );
  }
}
