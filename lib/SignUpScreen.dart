import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testappdns/Helpers.dart';
import 'package:testappdns/SignUpResponse.dart';
import 'package:http/http.dart' as http;
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignUpScreen extends StatefulWidget {
  String firstName;
  String lastName;
  String phone;
  String email;
  String token;

  SignUpScreen(
      {Key key,
      @required this.firstName,
      @required this.lastName,
      @required this.email,
      @required this.phone,
      @required this.token})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SignUpScreenState();
  }
}

class SignUpScreenState extends State<SignUpScreen> {
  String gitHubLink;
  String summaryLink;
  String transformedMessage;

  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SignUpResponse signInResponse;

  final TextEditingController _gitHubLinkController = TextEditingController();
  final TextEditingController _summaryLinkController = TextEditingController();

  //MARK: Create TextFormFields

  Widget buildgitHubTextField() {
    return TextFormField(
      controller: _gitHubLinkController,
      decoration: InputDecoration(labelText: 'Ссылка на github'),
      validator: (String value) {
        if (value.isEmpty) {
          return "GitHub Link is required";
        }
      },
    );
  }

  Widget buildSummaryTextField() {
    return TextFormField(
      controller: _summaryLinkController,
      decoration: InputDecoration(labelText: 'Ссылка на резюме'),
      validator: (String value) {
        if (value.isEmpty) {
          return "Summary Link is required";
        }
      },
    );
  }

  //MARK: Networking

  Future<SignUpResponse> sendData(
      String firstName,
      String lastName,
      String phone,
      String email,
      String gitHubLink,
      String summaryLink,
      String token) async {
    final http.Response response = await http.post(
        'https://vacancy.dns-shop.ru/api/candidate/test/summary',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': "Bearer $token",
        },
        body: jsonEncode(<String, String>{
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
          'githubProfileUrl': gitHubLink,
          'summary': summaryLink,
        }));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      signInResponse = SignUpResponse.fromJson(jsonResponse);
      transformedMessage =
          Helpers.transformMessageToString(signInResponse.message);
      if (transformedMessage.isNotEmpty) {
        showWarning(transformedMessage);
      } else {
        final success = signInResponse.data;
        showWarning('$success');
      }
      isLoading = false;
      return signInResponse;
    } else if (response.statusCode == 401) {
      showWarning('Error 401');
      throw Exception('Error 401');
    } else {
      showWarning('Undocumented Error');
      throw Exception('Undocumented Error');
    }
  }

  //MARK: SignUp

  signUp() {
    if (_formKey.currentState.validate()) {
      isLoading = true;
      sendData(
          widget.firstName,
          widget.lastName,
          widget.phone,
          widget.email,
          _gitHubLinkController.text,
          _summaryLinkController.text,
          widget.token);
    } else {
      return;
    }
  }

  //MARK: Check Network Connection

  checkConnection() async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true) {
      print('Network connection is ok');
    } else {
      showWarning('Интернет соединение отсутствует');
      print('No internet :( Reason:');
      print(DataConnectionChecker().lastTryResults);
    }
  }

  //MARK: Create AlertDialog with server response message

  Future<Null> showWarning(String message) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[Text('$message')],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Ok'),
              onPressed: () {
                setState(() {
                  isLoading = false;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  //Mark: Build form Widget

  Widget buildWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildgitHubTextField(),
              buildSummaryTextField(),
              SizedBox(height: 100),
              RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.orange, width: 2)),
                  color: Colors.orange,
                  child: Text(
                    'Зарегистрироваться',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () {
                    setState(() {
                      checkConnection();
                      signUp();
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }

  //MARK: Build widget tree

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Отправка данных',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(0),
          child: ModalProgressHUD(inAsyncCall: isLoading, child: buildWidget()),
        ),
      ),
    );
  }
}
