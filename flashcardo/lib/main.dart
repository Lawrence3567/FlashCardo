import 'package:flashcardo/app/landing_page.dart';
import 'package:flashcardo/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    runApp(MyApp());
  } catch (e) {
    print(e.toString());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthBase>(
      create: (context) => Auth(),
      child: GetMaterialApp(
        title: "FlashCardo",
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
          hintColor: Colors.blueGrey[200],
          scaffoldBackgroundColor: Colors.grey[900],
        ),
        home: LandingPage(),
      ),
    );
  }
}
