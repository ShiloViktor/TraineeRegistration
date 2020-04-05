import 'package:flutter/material.dart';
import 'package:testappdns/UploadDataScreen.dart';
import 'package:testappdns/SignUpScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TextFieldApp',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: UploadDataScreen(),
    );
  }
}
