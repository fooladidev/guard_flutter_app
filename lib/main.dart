
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project2_app/screens/login_screen.dart';
import 'constants.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: KPrimaryColor, // status bar color
    statusBarBrightness: Brightness.dark,//status bar brigtness
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guard',
      theme: ThemeData(
        primaryColor: KPrimaryColor,
        scaffoldBackgroundColor: Colors.white,

      ),
      home: LoginScreen(),
    );
  }
}