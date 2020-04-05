import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testappdns/Helpers.dart';
import 'package:testappdns/GetTokenResponse.dart';
import 'package:testappdns/SignUpScreen.dart';
import 'package:http/http.dart' as http;
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class UploadDataScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UploadDataScreenState();
  }
}

class UploadDataScreenState extends State<UploadDataScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailNameController = TextEditingController();

  SignUpScreenState signInScreenState;
  GetTokenResponse getTokenResponse;

  bool isLoading = false;

  String transformedMessage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //MARK: Create TextFormFields

  Widget buildFirstName() {
    return TextFormField(
      controller: _firstNameController,
      decoration: InputDecoration(labelText: 'Имя'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Введите имя';
        }
      },
    );
  }

  Widget buildLastName() {
    return TextFormField(
      controller: _lastNameController,
      decoration: InputDecoration(labelText: 'Фамилия'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Введите фамилию';
        }
      },
    );
  }

  Widget buildEmail() {
    return TextFormField(
      controller: _emailNameController,
      decoration: InputDecoration(labelText: 'Email'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Введите Email';
        }
      },
    );
  }

  Widget buildPhoneNumber() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(labelText: 'Телефон'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Введите номер телефона';
        }
      },
    );
  }

  //MARK: Networking

  Future<GetTokenResponse> transferDataToServer(
      String firstName, String lastName, String phone, String email) async {
    final http.Response response =
        await http.post('https://vacancy.dns-shop.ru/api/candidate/token',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'firstName': firstName,
              'lastName': lastName,
              'phone': phone,
              'email': email,
            }));
    if (response.statusCode == 200) {
      getTokenResponse = GetTokenResponse.fromJson(json.decode(response.body));
      transformedMessage =
          Helpers.transformMessageToString(getTokenResponse.message);
      if (transformedMessage != '') {
        showWarning(transformedMessage);
        print('show warning');
      }
      isLoading = false;
      return getTokenResponse;
    } else {
      isLoading = false;
      throw Exception('Fail to upload data');
    }
  }

  //MARK: Get token then go to the SignInScreen

  getToken() async {
    if (_formKey.currentState.validate()) {
      isLoading = true;
      await transferDataToServer(
          _firstNameController.text,
          _lastNameController.text,
          _phoneController.text,
          _emailNameController.text);
    } else {
      return;
    }
    goToTheSignInScreen();
  }

  goToTheSignInScreen() {
    if (getTokenResponse.data != null && getTokenResponse.data != '') {
      print(getTokenResponse.data);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SignUpScreen(
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    email: _emailNameController.text,
                    phone: _phoneController.text,
                    token: getTokenResponse.data,
                  )));
    } else {
      print('Can not get token');
    }
  }

  //MARK: Check Network Connection

  checkConnection() async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true) {
      print('Network connection is ok');
    } else {
      // ignore: unnecessary_statements
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

  //MARK: Build Form Widget

  Widget buildFormWidget() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildFirstName(),
              buildLastName(),
              buildEmail(),
              buildPhoneNumber(),
              SizedBox(height: 50),
              RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.orange, width: 2)),
                  color: Colors.orange,
                  child: Text(
                    'Получить ключ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () {
                    setState(() {
                      checkConnection();
                      getToken();
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
          title: Text(
            "Ввод данных",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(0),
          child: ModalProgressHUD(
            child: buildFormWidget(),
            inAsyncCall: isLoading,
          ),
        ),
      ),
    );
  }
}
